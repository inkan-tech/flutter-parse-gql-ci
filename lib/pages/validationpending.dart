import 'package:flutter/material.dart';

class Logout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logged out"),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          Center(child: Text("Good Bye")),
          const SizedBox(height: 100),
          RaisedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Login"),
            color: Colors.lightBlueAccent,
          )
        ],
      ),
    );
  }
}
