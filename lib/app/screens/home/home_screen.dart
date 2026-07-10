import 'package:flutter/material.dart';

import '../../../core/design_system/components/empty_state.dart';
import '../../../core/design_system/components/hair_brand_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Home'),
      body: const EmptyState(
        illustration: Icon(Icons.waving_hand_outlined, size: 80),
        title: 'Welcome back',
        description:
            'Your recent scans and upcoming routines will show up here once you start using HairPredict.',
      ),
    );
  }
}
