import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurokey/main.dart';

void main() {
  testWidgets('NeuroKey initial smoke test & theme toggle test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NeuroKeyApp(),
      ),
    );

    // Verify brand title and tagline
    expect(find.text('NeuroKey'), findsOneWidget);
    expect(find.text('Your mind, secured.'), findsOneWidget);
    expect(find.byIcon(Icons.lock_person), findsOneWidget);

    // Initial theme is Dark Mode, so the button prompts switching to Light Mode
    expect(find.text('Switch to Light Mode'), findsOneWidget);

    // Tap theme toggle
    await tester.tap(find.text('Switch to Light Mode'));
    await tester.pumpAndSettle();

    // After toggle, it prompts switching to Dark Mode
    expect(find.text('Switch to Dark Mode'), findsOneWidget);
  });
}
