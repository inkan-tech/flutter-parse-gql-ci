import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/login.dart';
import 'pages/logout.dart';
import 'pages/register.dart';
import 'providers/auth.dart';
import 'providers/user_provider.dart';
import 'util/shared_preference.dart';
import 'package:provider/provider.dart';

import './domain/user.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'constants.dart';

void main() async {
  // We're using HiveStore for persistence,
  // so we need to initialize Hive.
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(kParseApiUrl, defaultHeaders: {
      'X-Parse-Application-Id': kParseApplicationId,
      'X-Parse-Client-Key': kParseClientKey,
      //      'X-Parse-Session-Token': 'r:8e26ccce46ec4650cc79e2b969c50674'
    });

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(store: HiveStore()),
        link: httpLink,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
          home: GraphQLProvider(
            child: const MyHomePage(),
            client: client,
          ),
          routes: {
            '/dashboard': (context) => DashBoard(),
            '/login': (context) => Login(),
            '/register': (context) => Register(),
            '/logout': (context) => Logout(),
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // UserData is using the shared preferences module
  Future<User?> getUserData() => UserPreferences().getUser();

  String? name;
  String? saveFormat;
  String? objectId;

  ///THIS IS A SAMPLE FOR MAKING MUTABLE REQUEST

/////// check https://blog.logrocket.com/using-graphql-with-flutter-a-tutorial-with-examples/
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
            future: getUserData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if ((snapshot.hasData && snapshot.data == null) ||
                        (!snapshot.hasData)) {
                      return Login();
                    } else {
                      UserPreferences().removeUser();
                    }
                  }
                  return DashBoard();
              }
            }));
  }
}
