import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:parse_gql_ci/constants.dart';
import 'package:parse_gql_ci/domain/user.dart';
import 'package:parse_gql_ci/pages/dashboard.dart';
import 'package:parse_gql_ci/pages/login.dart';
import 'package:parse_gql_ci/pages/logout.dart';
import 'package:parse_gql_ci/pages/register.dart';
import 'package:parse_gql_ci/providers/auth.dart';
import 'package:parse_gql_ci/providers/user_provider.dart';
import 'package:parse_gql_ci/util/shared_preference.dart';
import 'package:parse_gql_ci/util/widgets.dart';
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

class MockLogin extends Mock implements Login {

  //Source : https://github.com/dart-lang/mockito/issues/228#issuecomment-578400083
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }

    final formKey = GlobalKey<FormState>();

  late String _username = "", _password = "";

  Widget build(BuildContext context) {
    MockAuth auth = Provider.of<MockAuth>(context);

        final usernameField = TextFormField(
      key: const ValueKey('UsernameField'),
      autofocus: false,
      //  validator: validateEmail,
      onSaved: (value) => _username = value as String,
      decoration: buildInputDecoration("Confirm password", Icons.person),
    );

    final passwordField = TextFormField(
      key: const ValueKey('PasswordField'),
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? "Please enter password" : null,
      onSaved: (value) => _password = value as String,
      decoration: buildInputDecoration("Confirm password", Icons.lock),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        CircularProgressIndicator(),
        Text(" Authenticating ... Please wait")
      ],
    );

    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton(
          child: const Text("Forgot password?",
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/reset-password');
          },
        ),
        ElevatedButton(
          child: const Text("Sign up",
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/register');
          },
        ),
      ],
    );

    var doLogin = () {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulLogin =
            auth.login(_username, _password);

        successfulLogin.then((response) {
          if (response['status']) {
            User user = response['user'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Flushbar(
              title: "Failed Login",
              message: response['message'].toString(),
              duration: const Duration(seconds: 3),
            ).show(context);
          }
        });
      } else {
        print("form is invalid");
      }
    };

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15.0),
                label("Username"),
                const SizedBox(height: 5.0),
                usernameField,
                const SizedBox(height: 20.0),
                label("Password"),
                const SizedBox(height: 5.0),
                passwordField,
                const SizedBox(height: 20.0),
                auth.loggedInStatus == Status.Authenticating
                    ? loading
                    : longButtons("Login", doLogin),
                const SizedBox(height: 5.0),
                forgotLabel
              ],
            ),
          ),
        ),
      ),
    );
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
              "objectId": "test",
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

  MockAuth mockAuth = MockAuth();

  mockClient.setCache(GraphQLCache());
  mockClient.setLink(mockLink);

  ValueNotifier<MockClient> client = ValueNotifier(mockClient);

  testWidgets('Test the login / logout ', (WidgetTester tester) async {
    await tester.pumpWidget(Builder(
        builder: ((context) => GraphQLProvider(
              client: client,
              child: ChangeNotifierProvider<MockAuth>(
                create: (_) => mockAuth,
                builder: (context, child) => MaterialApp(
                  home: MockLogin(),
                  routes: {
                    '/dashboard': (context) => const DashBoard(),
                    '/login': (context) => const Login(),
                    '/register': (context) => const Register(),
                    '/logout': (context) => Logout(),
                  },
                ),
                //child: const Login(),
              ),
            ))));

    await tester.enterText(find.byKey(const ValueKey('UsernameField')), 'test');

    await tester.enterText(
        find.byKey(const ValueKey('PasswordField')), 'testtest');

    await tester.tap(find.text('Login'));

    await tester.pumpAndSettle();

    expect(find.text("thomnico+b4p@gmail.com"), findsOneWidget);
  });
}
