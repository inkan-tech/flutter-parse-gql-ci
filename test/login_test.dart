import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:parse_gql_ci/constants.dart';
import 'package:parse_gql_ci/pages/login.dart';
import 'package:parse_gql_ci/providers/auth.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart' as app;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements GraphQLClient {
  @override
  late final Link link;
  @override
  late final GraphQLCache cache;

  void setLink(HttpLink httpLink) {
    link = httpLink;
  }

  void setCache(GraphQLCache graphQLCache) {
    cache = graphQLCache;
  }
}

void main() {
  final HttpLink httpLink = HttpLink(kParseApiUrl, defaultHeaders: {
    'X-Parse-Application-Id': kParseApplicationId,
    'X-Parse-Client-Key': kParseClientKey,
    //      'X-Parse-Session-Token': 'r:8e26ccce46ec4650cc79e2b969c50674'
  });

  MockClient mockClient = MockClient();

  mockClient.setCache(GraphQLCache());
  mockClient.setLink(httpLink);

  ValueNotifier<MockClient> client = ValueNotifier(mockClient);

  testWidgets('Test the login / logout ', (WidgetTester tester) async {
    await tester.pumpWidget(Builder(
        builder: ((context) => MaterialApp(
                home: GraphQLProvider(
              client: client,
              child: ChangeNotifierProvider<AuthProvider>(
                create: (_) => AuthProvider(),
                child: const Login(),
              ),
            )))));

    await tester.enterText(
        find.byKey(const ValueKey('UsernameField')), 'test');

    await tester.enterText(
        find.byKey(const ValueKey('PasswordField')), 'testtest');

    await tester.tap(find.text('Login'));

    expect(find.text("thomnico+b4p@gmail.com"), findsOneWidget);
  });
}
