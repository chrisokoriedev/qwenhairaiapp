import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/entities/style_image.dart';
import 'package:qwenhairaiapp/core/models/style_image_model.dart';
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';
import 'package:qwenhairaiapp/core/models/hair_3d_render_model.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';

class StyleTryOnRepositoryImpl implements StyleTryOnRepository {
  final Dio dio;

  StyleTryOnRepositoryImpl({required this.dio});

  @override
  Future<Result<List<StyleImage>, Failure>> getAvailableStyles() async {
    try {
      final response = await dio.get('/styles');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final styles = data
            .map((json) => StyleImageModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Success(styles);
      } else {
        return const FailureResult(ServerFailure('Failed to load styles from server.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<StyleImage, Failure>> processCameraImage(
    String imagePath,
    String styleId,
  ) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'styleId': styleId,
      });

      final response = await dio.post('/try-on', data: formData);
      if (response.statusCode == 200) {
        final model = StyleImageModel.fromJson(response.data as Map<String, dynamic>);
        return Success(model);
      } else {
        return const FailureResult(ServerFailure('Failed to process image on server.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Hair3DRender, Failure>> generate3DModel({
    required String frontPath,
    required String backPath,
    required String leftPath,
    required String rightPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'front': await MultipartFile.fromFile(frontPath),
        'back': await MultipartFile.fromFile(backPath),
        'left': await MultipartFile.fromFile(leftPath),
        'right': await MultipartFile.fromFile(rightPath),
      });

      final response = await dio.post('/hair/3d-reconstruct', data: formData);
      if (response.statusCode == 200) {
        final model = Hair3DRenderModel.fromJson(response.data as Map<String, dynamic>);
        return Success(model);
      } else {
        return const FailureResult(ServerFailure('Failed to construct 3D hair model.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
