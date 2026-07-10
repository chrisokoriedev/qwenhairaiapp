import 'package:flutter/material.dart';

import '../../../core/design_system/components/empty_state.dart';
import '../../../core/design_system/components/hair_brand_app_bar.dart';

class CoachingShell extends StatelessWidget {
  const CoachingShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Coaching'),
      body: const EmptyState(
        illustration: Icon(Icons.chat_bubble_outline, size: 80),
        title: 'Coaching coming soon',
        description:
            'Daily routines and WhatsApp history will appear here once connected.',
      ),
    );
  }
}
