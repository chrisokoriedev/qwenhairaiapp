import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/usecases/usecase.dart';
import 'package:qwenhairaiapp/core/entities/style_image.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';

class ProcessCameraImage implements UseCase<StyleImage, ProcessCameraImageParams> {
  final StyleTryOnRepository repository;

  ProcessCameraImage(this.repository);

  @override
  Future<Result<StyleImage, Failure>> call(ProcessCameraImageParams params) async {
    return await repository.processCameraImage(params.imagePath, params.styleId);
  }
}

class ProcessCameraImageParams {
  final String imagePath;
  final String styleId;

  const ProcessCameraImageParams({
    required this.imagePath,
    required this.styleId,
  });
}
