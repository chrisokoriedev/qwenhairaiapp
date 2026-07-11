import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/diagnostics/controller/diagnostics_cubit.dart';
import '../../../features/diagnostics/presentation/diagnostics_screen.dart';
import '../../../injection_container.dart';

class DiagnosticsShell extends StatelessWidget {
  const DiagnosticsShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiagnosticsCubit>(
      create: (_) => sl<DiagnosticsCubit>(),
      child: const DiagnosticsScreen(),
    );
  }
}
