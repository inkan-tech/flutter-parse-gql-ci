import '../domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", user.userId as String);
    prefs.setString("email", user.email as String);
    prefs.setString("token", user.token as String);

    print("object prefere");
    print(user.token);

    return prefs.commit();
  }

  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString("userId");
    String? email = prefs.getString("email" as String);
    String? token = prefs.getString("token" as String);

    if (userId != null) {
      return User(userId: userId, email: email, token: token);
    } else {
      return null;
    }
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("userID");
    prefs.remove("email");
    prefs.remove("token");
  }

  Future<String> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    return token;
  }
}
