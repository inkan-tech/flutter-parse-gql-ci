class User {
  String? userId;
  String? email;
  bool? emailVerified;
  String? token;

  User({
    this.userId,
    this.email,
    this.emailVerified,
    this.token,
  });

  factory User.fromJson(Map<String?, dynamic> responseData) {
    return User(
        userId: responseData['id'],
        email: responseData['email'],
        token: responseData['token'],
        emailVerified: responseData['emailVerified']);
  }
}
