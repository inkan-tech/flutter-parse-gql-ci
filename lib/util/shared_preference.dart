import '../domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", user.userId as String);
    prefs.setString("email", user.email as String);
    prefs.setString("token", user.token as String);
    // TODO check for Null also
    (user.emailVerified != null)
        ? prefs.setBool("emailVerified", user.emailVerified as bool)
        : prefs.setBool("emailVerified", false);
    prefs.setString("objectId", user.objectId as String);

    return prefs.commit();
  }

  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString("userId");
    String? email = prefs.getString("email");
    String? token = prefs.getString("token");
    bool? emailVerified = prefs.getBool("emailVerified");
    String? objectId = prefs.getString("objectId");

    if (userId != null) {
      return User(
          userId: userId,
          email: email,
          token: token,
          emailVerified: emailVerified,
          objectId: objectId);
    } else {
      return null;
    }
  }

  Future<bool> removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    if ( token.length < 6 ) {
      return null;
    } else {
      return token;
    }
  }
}
