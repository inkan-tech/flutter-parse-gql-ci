import 'dart:async';

import 'package:flutter/material.dart';
import '../domain/user.dart';
import '../util/shared_preference.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
      result = Future<Map<String, dynamic>>.value(
          {'status': false, 'message': loginResult.exception!.toString()});
    } else {
      // get UserData directly from user: under viewer
      var userData = loginResult.data!['logIn']['viewer']['user'];
      // add the sessionToken
      userData['token'] = loginResult.data!['logIn']['viewer']['sessionToken'];
      // transform in the right format
      User authUser = User.fromJson(userData);
      // Save the user in the sharedPreferences
      UserPreferences().saveUser(authUser);

      if (authUser.emailVerified == true) {
        _loggedInStatus = Status.LoggedIn;
        result = Future<Map<String, dynamic>>.value({
          'status': true,
          'message': 'Logged in successfully',
          'user': authUser
        });
      } else {
        // Use status registering for after Signup but email not verified.
        _loggedInStatus = Status.Registering;
        result = Future<Map<String, dynamic>>.value({
          'status': false,
          'message': 'Please verify your email',
          'user': authUser
        });
      }
      // TODO: Add the session token to the graphql client
      notifyListeners();
    }
    return result;
  }

  /// Implement the signup function with a Mutation and a GraphQLClient
  Future<Map<String, dynamic>> register(
      String? username, String? email, String? password) async {
    Future<Map<String, dynamic>> result;
    _loggedInStatus = Status.Registering;
    // ref:
    String signupMutation =
        '''mutation SignUp(\$username: String!, \$password: String!, \$email: String!)
          {signUp(input: {
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

    final QueryOptions options = QueryOptions(
      document: gql(signupMutation),
      variables: <String, dynamic>{
        'username': username,
        'password': password,
        'email': email
      },
    );
    GraphQLClient client = configuration.clientToQuery();

    QueryResult signupResult = await client.query(options);
    if (signupResult.hasException) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = Future<Map<String, dynamic>>.value(
          {'status': false, 'message': signupResult.exception!.toString()});
    } else {
      // TODO get the objectId linked with the token or getuser
      // once logged in but might not be possible before emailVerified
      // ..
      var userData = {
        'id': username,
        'email': email,
        'token': signupResult.data!['signUp']['viewer']['sessionToken'],
        'emailVerified': false,
        'objectId': ""
      };

      // transform in the right format
      User authUser = User.fromJson(userData);
      // Save the user in the sharedPreferences
      UserPreferences().saveUser(authUser);

      // Use status registering for after Signup but email not verified.
      _loggedInStatus = Status.Registering;
      result = Future<Map<String, dynamic>>.value({
        'status': true,
        'message': 'Please verify your email',
        'user': authUser
      });

      // TODO: Add the session token to the graphql client
      notifyListeners();
    }
    return result;
  }
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

  /// see https://www.back4app.com/docs/parse-graphql/graphql-logout-mutation
  /// we can keep the id of the session which is different then the session.

  String logoutMutate = ''' 
  mutation logOutButton (\$objectId: String!) {
	logOut(input: { clientMutationId: \$objectId }) {
		clientMutationId
  	}
  }
  ''';

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
}
