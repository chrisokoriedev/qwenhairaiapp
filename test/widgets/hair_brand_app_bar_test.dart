import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/hair_brand_app_bar.dart';

void main() {
  testWidgets('renders title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: HairBrandAppBar(title: 'Welcome'),
        ),
      ),
    );
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('taller than default AppBar (kToolbarHeight + 16)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: HairBrandAppBar(title: 'Welcome'),
        ),
      ),
    );
    final bar = tester.widget<HairBrandAppBar>(find.byType(HairBrandAppBar));
    expect(bar.preferredSize.height, kToolbarHeight + 16);
  });
}
