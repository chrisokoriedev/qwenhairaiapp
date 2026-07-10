import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/loading_dots.dart';

void main() {
  testWidgets('pumps through animation cycle without exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: LoadingDots()))),
    );
    // Pump through the full 600ms animation cycle.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sm size renders smaller dots than lg', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LoadingDots(size: LoadingDotsSize.sm),
              SizedBox(width: 16),
              LoadingDots(size: LoadingDotsSize.lg),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(LoadingDots), findsNWidgets(2));
  });
}
