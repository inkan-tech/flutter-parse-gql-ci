// check this https://itnext.io/flutter-1-17-no-more-flavors-no-more-ios-schemas-command-argument-that-solves-everything-8b145ed4285d 
// Idea is to use environment variables to set access to B4APP to ease CI/CD
// https://github.com/marketplace/actions/flutter-action for github actions


class AppUrl {
  static const String liveBaseURL = "https://shiny-awful-wildebeast.gigalixirapp.com/api/v1";
  static const String localBaseURL = "http://10.0.2.2:4000/api/v1";

  static const String baseURL = liveBaseURL;
  static const String login = baseURL + "/session";
  static const String register = baseURL + "/registration";
  static const String forgotPassword = baseURL + "/forgot-password";
}
