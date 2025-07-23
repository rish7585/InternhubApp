import 'package:flutter_test/flutter_test.dart';
import 'package:intern_hub/widgets/app_button.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('AppButton displays label and responds to tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Test',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
    await tester.tap(find.text('Test'));
    expect(tapped, isTrue);
  });
} 