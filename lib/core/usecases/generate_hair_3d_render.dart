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
      faceScanPath: params.faceScanPath,
      targetHairStylePath: params.targetHairStylePath,
    );
  }
}

class GenerateHair3DRenderParams {
  final String faceScanPath;
  final String targetHairStylePath;

  const GenerateHair3DRenderParams({
    required this.faceScanPath,
    required this.targetHairStylePath,
  });
}
