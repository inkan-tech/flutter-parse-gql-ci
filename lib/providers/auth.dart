import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../domain/user.dart';
import '../util/shared_preference.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../constants.dart';
import '../graphql-configurator.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;
  GraphQlConfiguration configuration = GraphQlConfiguration();

  Future<Map<String, dynamic>> login(String username, String password) async {
    Future<Map<String, dynamic>> result;

    final Map<String, dynamic> loginData = {
      'input': {'username': username, 'password': password}
    };
    final variables = {
      "input": {"username": username, "password": password}
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    String loginMutate = '''
      mutation LogIn(\$username: String!, \$password: String!){
        logIn(input: {username: \$username, password: \$password}) {
          viewer{
            sessionToken
            user { 
            objectId
            id
            emailVerified
            email
            }
          }
        }
      }
      ''';

    final QueryOptions options = QueryOptions(
      document: gql(loginMutate),
      variables: <String, dynamic>{'username': username, 'password': password},
    );
    GraphQLClient client = configuration.clientToQuery();

    QueryResult loginResult = await client.query(options);

    if (loginResult.hasException) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = new Future<Map<String, dynamic>>.value(
          {'status': false, 'message': loginResult.exception!.toString()});
      ;
    } else {
// <      final Map<String, dynamic> responseData =
//           json.decode(loginResult.data.toString());
      var userData = loginResult.data!['logIn']['viewer']['user'];
      userData['token'] = loginResult.data!['logIn']['viewer']['sessionToken'];
      print("userdata:" + userData.toString());
      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);
      print(loginResult.data!['logIn']['viewer']);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = new Future<Map<String, dynamic>>.value({
        'status': true,
        'message': 'Successful',
        'user': authUser,
      });
    }
    return result;
  }

  /// see https://www.back4app.com/docs/parse-graphql/graphql-logout-mutation
  String logoutMutate = ''' mutation logOutButton {
	logOut(input: { clientMutationId: "6pgfR7vt38" }) {
		clientMutationId
	}
}
''';

  // Future<Map<String, dynamic>> register(
  //     String? email, String? password, String? passwordConfirmation) async {
  //   final Map<String, dynamic> registrationData = {
  //     'user': {
  //       'email': email,
  //       'password': password,
  //       'password_confirmation': passwordConfirmation
  //     }
  //   };
  String signupMutation =
      '''mutation SignUp(\$username: String!, \$password: String!, \$email: String!){
  signUp(input: {
    fields: {
      username: \$username
      password: \$password
      email: \$email
    }
  }){
    viewer{
      user{
        id
        createdAt
      }
      sessionToken
    }
  }
  }''';
  //   return await post(AppUrl.register,
  //           body: json.encode(registrationData),
  //           headers: {'Content-Type': 'application/json'})
  //       .then(onValue)
  //       .catchError(onError);
  // }

//   static Future<FutureOr> onValue(Response response) async {
//     var result;
//     final Map<String, dynamic> responseData = json.decode(response.body);

//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       var userData = responseData['data'];

//       User authUser = User.fromJson(userData);

//       UserPreferences().saveUser(authUser);
//       result = {
//         'status': true,
//         'message': 'Successfully registered',
//         'data': authUser
//       };
//     } else {
// //      if (response.statusCode == 401) Get.toNamed("/login");
//       result = {
//         'status': false,
//         'message': 'Registration failed',
//         'data': responseData
//       };
//     }

//     return result;
//   }

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
}
