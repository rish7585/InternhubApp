import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intern_hub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can log in and see home screen', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Enter email and password (replace with a real test account)
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    // Tap login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Expect to see the home screen
    expect(find.text('Home'), findsOneWidget);
  });
} 