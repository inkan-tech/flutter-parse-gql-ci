import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Test the login / logout ', (WidgetTester tester) async {
      /// assume there is a test/testtest user in the database.
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      // Find the first textField and type in the username
      final Finder textFieldFinder = find.byType(TextFormField);
      // expect(textFieldFinderU, findsOneWidget);
      await tester.enterText(textFieldFinder.first, 'test');

      // Find the next textField and type in the password

      await tester.enterText(textFieldFinder.last, 'testtest');
      await tester.tap(find.byType(MaterialButton));

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify we go to next frame
      expect(find.text('thomnico+b4p@gmail.com'), findsOneWidget);

      // Then we logout
      await tester.tap(find.byType(ElevatedButton));
      // TODO verify the database is empty

      // Trigger a frame.
      await tester.pumpAndSettle();

      // check we are at login again
      expect(find.text('Logged out'), findsNWidgets(2));
    });
  });
}
