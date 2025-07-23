import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intern_hub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and shows login screen', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsWidgets);
  });
} 