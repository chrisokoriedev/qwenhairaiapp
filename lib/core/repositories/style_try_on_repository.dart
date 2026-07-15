import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/entities/style_image.dart';
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';

abstract class StyleTryOnRepository {
  Future<Result<List<StyleImage>, Failure>> getAvailableStyles();
  Future<Result<StyleImage, Failure>> processCameraImage(String imagePath, String styleId);
  Future<Result<Hair3DRender, Failure>> generate3DModel({
    required String faceScanPath,
    required String targetHairStylePath,
  });
}
