import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intern_hub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can create a post', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Log in first (replace with a real test account)
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Navigate to Post tab
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    // Enter post content
    await tester.enterText(find.byType(TextField).first, 'Hello from integration test!');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    // Expect to see a confirmation or the post in the feed
    expect(find.text('Post created successfully! 🎉'), findsOneWidget);
  });
} 