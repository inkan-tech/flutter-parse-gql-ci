import 'package:graphql_flutter/graphql_flutter.dart';
import 'constants.dart';

class GraphQlConfiguration {
  HttpLink httpLink = HttpLink(
    kParseApiUrl,
    defaultHeaders: {
      'X-Parse-Application-Id': kParseApplicationId,
      'X-Parse-Client-Key': kParseClientKey,
    },
  );

  void addToken(String sessionToken) {
    httpLink.defaultHeaders['X-Parse-Session-Token'] = sessionToken;
  }
  void removeToken() {
    httpLink.defaultHeaders.remove('X-Parse-Session-Token');
  }
  
  GraphQLClient clientToQuery({String? sessionToken}) {
    if (sessionToken != null) {
      httpLink.defaultHeaders['X-Parse-Session-Token'] = sessionToken;
    }

    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: httpLink,
    );
  }
}
