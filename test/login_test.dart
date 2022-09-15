import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:parse_gql_ci/constants.dart';
import 'package:parse_gql_ci/domain/user.dart';
import 'package:parse_gql_ci/pages/login.dart';
import 'package:parse_gql_ci/providers/auth.dart';
import 'package:parse_gql_ci/util/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:parse_gql_ci/graphql-configurator.dart';
import '../lib/main.dart' as app;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements GraphQLClient {
  @override
  late final Link link;
  @override
  late final GraphQLCache cache;

  void setLink(HttpLink httpLink) {
    link = httpLink;
  }

  void setCache(GraphQLCache graphQLCache) {
    cache = graphQLCache;
  }
}

class MockLink extends Mock implements HttpLink {}

class MockQueryResult extends Mock implements QueryResult {}

class MockAuth extends Mock implements AuthProvider {
  @override
  Status get loggedInStatus => _loggedInStatus;
  Status _loggedInStatus = Status.NotLoggedIn;
  @override
  GraphQlConfiguration configuration = GraphQlConfiguration();
  @override
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
    //modif QueryResult
    QueryResult loginResult = QueryResult(
      source: QueryResultSource.network,
      options: options,
      data: {
        "logIn": {
          "viewer": {
            'user': {
              "objectId": "aaabbb",
              "id": "bbbbbbbbbccccc",
              "emailVerified": true,
              "email": "thomnico+b4p@gmail.com"
            },
            'sessionToken': 'testtest'
          }
        }
      },
    );

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
}

void main() {
  // final HttpLink httpLink = HttpLink(kParseApiUrl, defaultHeaders: {
  //   'X-Parse-Application-Id': kParseApplicationId,
  //   'X-Parse-Client-Key': kParseClientKey,
  //   //      'X-Parse-Session-Token': 'r:8e26ccce46ec4650cc79e2b969c50674'
  // });

  MockLink mockLink = MockLink();

  MockClient mockClient = MockClient();

  mockClient.setCache(GraphQLCache());
  mockClient.setLink(mockLink);

  ValueNotifier<MockClient> client = ValueNotifier(mockClient);

  testWidgets('Test the login / logout ', (WidgetTester tester) async {
    await tester.pumpWidget(Builder(
        builder: ((context) => MaterialApp(
                home: GraphQLProvider(
              client: client,
              child: ChangeNotifierProvider<AuthProvider>(
                create: (_) => MockAuth(),
                child: const Login(),
              ),
            )))));

    await tester.enterText(find.byKey(const ValueKey('UsernameField')), 'test');

    await tester.enterText(
        find.byKey(const ValueKey('PasswordField')), 'testtest');

    await tester.tap(find.text('Login'));

    await tester.pumpAndSettle();

    expect(find.text("thomnico+b4p@gmail.com"), findsOneWidget);
  });
}
