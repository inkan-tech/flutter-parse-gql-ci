import 'package:graphql_flutter/graphql_flutter.dart';
import 'constants.dart';

class GraphQlConfiguration {
  GraphQLClient clientToQuery({String? sessionToken}) {
    HttpLink httpLink = HttpLink(
      kParseApiUrl,
      defaultHeaders: {
        'X-Parse-Application-Id': kParseApplicationId,
        'X-Parse-Client-Key': kParseClientKey,
      },
    );

    if (sessionToken != null) {
      httpLink.defaultHeaders['X-Parse-Session-Token'] = sessionToken;
    }

    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: httpLink,
    );
  }
}
