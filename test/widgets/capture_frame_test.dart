import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/capture_frame.dart';

void main() {
  testWidgets('empty state shows angle label + tap hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CaptureFrame(
                angleLabel: 'Front',
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Tap to capture'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });

  testWidgets('onTap fires when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CaptureFrame(
                angleLabel: 'Front',
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CaptureFrame));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
