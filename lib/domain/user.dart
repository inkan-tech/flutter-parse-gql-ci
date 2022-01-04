class User {
  String? userId;
  String? email;
  bool? emailVerified;
  String? token;
  // use objectId as it is the name returned by graphql for the session row in DB
  String? objectId;

  User(
      {this.userId,
      this.email,
      this.emailVerified,
      this.token,
      this.objectId});

  factory User.fromJson(Map<String?, dynamic> responseData) {
    return User(
        objectId: responseData['objectId'],
        userId: responseData['id'],
        email: responseData['email'],
        token: responseData['token'],
        emailVerified: responseData['emailVerified']);
  }
}
