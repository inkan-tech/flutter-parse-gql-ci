import 'package:flutter/material.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import 'package:another_flushbar/flushbar.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    var doLogout = () {
      final Future<Map<String, dynamic>> successfulLogout = auth.logout();

      successfulLogout.then((response) {
        if (response['status']) {
          Flushbar(
            title: "Logged out",
            message: response['message'].toString(),
            duration: const Duration(seconds: 5),
          ).show(context);
        } else {
          Flushbar(
            title: "Problem logging out",
            message: response['message'].toString(),
            duration: const Duration(seconds: 7),
          ).show(context);
        }
      });
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("DASHBOARD PAGE"),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          Center(
              child: Text((user.email != null
                  ? user.email as String
                  : "not logged in"))),
          const SizedBox(height: 100),
          RaisedButton(
            onPressed: () {
              doLogout();
              Navigator.pushReplacementNamed(context, '/logout');
            },
            child: const Text("Logout"),
            color: Colors.lightBlueAccent,
          )
        ],
      ),
    );
  }
}
