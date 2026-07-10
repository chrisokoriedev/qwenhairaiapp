import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwenhairaiapp/core/constants/app_colors.dart';
import 'package:qwenhairaiapp/injection_container.dart' as di;
import 'package:qwenhairaiapp/features/style_try_on/presentation/pages/hair_capture_screen.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StyleTryOnBloc>(
          create: (context) => di.sl<StyleTryOnBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Qwen Hair AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const HairCaptureScreen(),
      ),
    );
  }
}
