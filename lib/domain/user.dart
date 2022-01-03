class User {
  String? userId;
  String? email;
  bool? emailVerified;
  String? token;
  String? sessionId;

  User(
      {this.userId,
      this.email,
      this.emailVerified,
      this.token,
      this.sessionId});

  factory User.fromJson(Map<String?, dynamic> responseData) {
    return User(
        sessionId: responseData['objectId'],
        userId: responseData['id'],
        email: responseData['email'],
        token: responseData['token'],
        emailVerified: responseData['emailVerified']);
  }
}
