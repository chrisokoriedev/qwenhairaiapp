import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/usecases/usecase.dart';
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';

class GenerateHair3DRender implements UseCase<Hair3DRender, GenerateHair3DRenderParams> {
  final StyleTryOnRepository repository;

  GenerateHair3DRender(this.repository);

  @override
  Future<Result<Hair3DRender, Failure>> call(GenerateHair3DRenderParams params) async {
    return await repository.generate3DModel(
      frontPath: params.frontPath,
      backPath: params.backPath,
      leftPath: params.leftPath,
      rightPath: params.rightPath,
    );
  }
}

class GenerateHair3DRenderParams {
  final String frontPath;
  final String backPath;
  final String leftPath;
  final String rightPath;

  const GenerateHair3DRenderParams({
    required this.frontPath,
    required this.backPath,
    required this.leftPath,
    required this.rightPath,
  });
}
