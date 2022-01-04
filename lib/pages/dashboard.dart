import 'package:flutter/material.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;

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
