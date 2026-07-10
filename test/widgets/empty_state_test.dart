import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/empty_state.dart';

void main() {
  testWidgets('renders title, description, illustration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            illustration: Icon(Icons.image, size: 80),
            title: 'No scans yet',
            description: 'Start your first scan to see it here.',
          ),
        ),
      ),
    );
    expect(find.text('No scans yet'), findsOneWidget);
    expect(find.text('Start your first scan to see it here.'), findsOneWidget);
    expect(find.byIcon(Icons.image), findsOneWidget);
  });

  testWidgets('action button renders when provided', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            illustration: const Icon(Icons.image, size: 80),
            title: 'No scans',
            description: 'Start one.',
            action: (label: 'Start scan', onPressed: () => tapped = true),
          ),
        ),
      ),
    );
    expect(find.text('Start scan'), findsOneWidget);
    await tester.tap(find.text('Start scan'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
