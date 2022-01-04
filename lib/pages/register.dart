import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../util/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../domain/user.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:email_validator/email_validator.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();

  String? _username, _password, _email;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final emailField = TextFormField(
      autofocus: false,
      validator: (value) => EmailValidator.validate(value as String)
          ? null
          : "Please enter a valid email",
      onSaved: (value) => _email = value,
      decoration: buildInputDecoration("Enter a valid email", Icons.email),
    );

    final usernameField = TextFormField(
      autofocus: false,
      onSaved: (value) => _username = value,
      validator: (value) => value!.isEmpty ? "Please enter username" : null,
      decoration: buildInputDecoration("Choose a username", Icons.person),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value!.isEmpty ? "Please enter password" : null,
      onSaved: (value) => _password = value,
      decoration: buildInputDecoration("Password", Icons.lock),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        CircularProgressIndicator(),
        Text(" Registering ... Please wait")
      ],
    );

    var doRegister = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        auth.register(_username, _email, _password).then((response) {
          if (response['status']) {
            User user = response['user'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Flushbar(
              title: "Registration Failed",
              message: response.toString(),
              duration: const Duration(seconds: 10),
            ).show(context);
          }
        });
      } else {
        Flushbar(
          title: "Invalid form",
          message: "Please Complete the form properly",
          duration: const Duration(seconds: 10),
        ).show(context);
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
                const SizedBox(height: 10.0),
                usernameField,
                const SizedBox(height: 15.0),
                label("Email"),
                const SizedBox(height: 5.0),
                emailField,
                const SizedBox(height: 15.0),
                label("Password"),
                const SizedBox(height: 10.0),
                passwordField,
                const SizedBox(height: 20.0),
                auth.loggedInStatus == Status.Authenticating
                    ? loading
                    : longButtons("Signup", doRegister),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
