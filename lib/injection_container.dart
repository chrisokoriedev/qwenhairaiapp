import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qwenhairaiapp/core/design_system/connectivity/connectivity_cubit.dart';
import 'package:qwenhairaiapp/core/design_system/persistence/onboarding_cubit.dart';
import 'package:qwenhairaiapp/core/design_system/retry/retry_queue.dart';
import 'package:qwenhairaiapp/core/design_system/theme/theme_controller.dart';
import 'package:qwenhairaiapp/core/network/qwen_cloud_client.dart';
import 'package:qwenhairaiapp/core/repositories/auth_repository.dart';
import 'package:qwenhairaiapp/core/repositories/auth_repository_impl.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository_impl.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository_impl.dart';
import 'package:qwenhairaiapp/core/usecases/generate_hair_3d_render.dart';
import 'package:qwenhairaiapp/core/usecases/process_camera_image.dart';
import 'package:qwenhairaiapp/features/diagnostics/controller/diagnostics_cubit.dart';
import 'package:qwenhairaiapp/features/style_try_on/controller/style_try_on_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Design system cubits ────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<ThemeController>(() => ThemeController(sl()));
  sl.registerLazySingleton<OnboardingCubit>(() => OnboardingCubit(sl()));
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(sl()));
  sl.registerLazySingleton<RetryQueue>(() => NoopRetryQueue());

  // ── Features - Style Try On ─────────────────────────────────────────
  sl.registerFactory(
    () => StyleTryOnController(
      repository: sl(),
      processCameraImageUseCase: sl(),
      generateHair3DRenderUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ProcessCameraImage(sl()));
  sl.registerLazySingleton(() => GenerateHair3DRender(sl()));

  // ── Diagnostics ────────────────────────────────────────────────────
  sl.registerFactory(() => DiagnosticsCubit(sl()));

  // QwenCloudClient — must be registered before repositories that depend on it
  sl.registerLazySingleton(() => QwenCloudClient(sl()));

  // Repositories
  sl.registerLazySingleton<StyleTryOnRepository>(
    () => StyleTryOnRepositoryImpl(dio: sl(), qwenCloud: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<HairHealthRepository>(
    () => HairHealthRepositoryImpl(dio: sl(), qwenCloud: sl()),
  );

  // ── External / Core Network Client ──────────────────────────────────
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://api.qwenhairai.com/v1';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    return dio;
  });
}
