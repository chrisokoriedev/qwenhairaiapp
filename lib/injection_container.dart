import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository_impl.dart';
import 'package:qwenhairaiapp/core/usecases/process_camera_image.dart';
import 'package:qwenhairaiapp/core/usecases/generate_hair_3d_render.dart';
import 'package:qwenhairaiapp/features/style_try_on/controller/style_try_on_controller.dart';
import 'package:qwenhairaiapp/core/repositories/auth_repository.dart';
import 'package:qwenhairaiapp/core/repositories/auth_repository_impl.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository_impl.dart';
import 'package:qwenhairaiapp/core/network/qwen_cloud_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Style Try On
  // Bloc
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

  // Repositories
  sl.registerLazySingleton<StyleTryOnRepository>(
    () => StyleTryOnRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<HairHealthRepository>(
    () => HairHealthRepositoryImpl(dio: sl()),
  );

  // External / Core Network Client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://api.qwenhairai.com/v1';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    return dio;
  });

  sl.registerLazySingleton(() => QwenCloudClient(sl()));
}
