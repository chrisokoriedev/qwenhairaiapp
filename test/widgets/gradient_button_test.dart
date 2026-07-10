import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/gradient_button.dart';
import 'package:qwenhairaiapp/core/design_system/components/loading_dots.dart';

void main() {
  testWidgets('renders label and responds to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('isLoading swaps label for LoadingDots', (tester) async {
    await tester.pumpWidget(
       MaterialApp(
        home: Scaffold(body: GradientButton(label: 'Continue', isLoading: true, onPressed: () {  },)),
      ),
    );
    expect(find.text('Continue'), findsNothing);
    // LoadingDots renders 3 animated containers.
    expect(find.byType(LoadingDots), findsOneWidget);
  });

  testWidgets('null onPressed disables button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GradientButton(label: 'Continue', onPressed: null)),
      ),
    );
    final button = tester.widget<GradientButton>(find.byType(GradientButton));
    expect(button.onPressed, isNull);
  });
}
