import 'package:flutter/material.dart';

import '../../../core/design_system/components/empty_state.dart';
import '../../../core/design_system/components/hair_brand_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Profile'),
      body: const EmptyState(
        illustration: Icon(Icons.person_outline, size: 80),
        title: 'Your profile',
        description:
            'Hair type, chemical history, and preferences will live here.',
      ),
    );
  }
}
