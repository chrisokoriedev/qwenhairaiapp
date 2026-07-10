import 'package:flutter/material.dart';

import '../../../core/design_system/components/empty_state.dart';
import '../../../core/design_system/components/hair_brand_app_bar.dart';

class DiagnosticsShell extends StatelessWidget {
  const DiagnosticsShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Diagnostics'),
      body: const EmptyState(
        illustration: Icon(Icons.health_and_safety_outlined, size: 80),
        title: 'Diagnostics coming soon',
        description:
            'Qwen Vision analysis + PDF dossiers will be available in the next release.',
      ),
    );
  }
}
