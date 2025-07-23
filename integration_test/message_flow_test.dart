import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intern_hub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can send a message', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Log in first (replace with a real test account)
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Navigate to Messages tab
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle();

    // Tap on a chat (assumes at least one chat exists)
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // Enter and send a message
    await tester.enterText(find.byType(TextField).first, 'Hello from integration test!');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // Expect to see the message in the chat
    expect(find.text('Hello from integration test!'), findsWidgets);
  });
} 