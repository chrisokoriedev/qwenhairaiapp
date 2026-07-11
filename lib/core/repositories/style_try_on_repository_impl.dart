import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/entities/style_image.dart';
import 'package:qwenhairaiapp/core/models/style_image_model.dart';
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';
import 'package:qwenhairaiapp/core/models/hair_3d_render_model.dart';
import 'package:qwenhairaiapp/core/network/qwen_cloud_client.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';

class StyleTryOnRepositoryImpl implements StyleTryOnRepository {
  final Dio dio;
  final QwenCloudClient qwenCloud;

  StyleTryOnRepositoryImpl({required this.dio, required this.qwenCloud});

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
      // Use QwenCloudClient to analyze the image directly via DashScope,
      // bypassing the need for a backend upload endpoint.
      final result = await qwenCloud.analyzeImageFromFile(
        prompt:
            'Analyze this hair image. Describe the hair type, texture, length, and condition. '
            'Then suggest a hairstyle suitable for this person based on the requested style ID: $styleId.',
        filePath: imagePath,
      );

      switch (result) {
        case Success(value: final description):
          return Success(
            StyleImage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imageUrl: imagePath,
              styleName: description                      .length > 100
                  ? '${description.substring(0, 97)}...'
                  : description,
            ),
          );
        case FailureResult(failure: final failure):
          return FailureResult(failure);
      }
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
      // Analyze the front-facing image with Qwen Vision to extract hair attributes.
      final analysisResult = await qwenCloud.analyzeImageFromFile(
        prompt:
            'You are a professional trichologist. Analyze this front-facing hair photo and provide:\n'
            '1. Hair type classification (2A-4C)\n'
            '2. Hair density (thin, medium, thick)\n'
            '3. Scalp condition\n'
            '4. Texture description\n'
            '5. Any visible damage or concerns',
        filePath: frontPath,
      );

      switch (analysisResult) {
        case Success(value: final analysis):
          // Generate a 3D-style visualization based on the analysis.
          final renderResult = await qwenCloud.generateImage(
            prompt:
                'Create a professional 3D hair visualization based on this hair analysis: $analysis. '
                'Show a realistic 3D model of the hairstyle that suits this hair type and texture.',
          );

          switch (renderResult) {
            case Success(value: final imageUrl):
              return Success(
                Hair3DRenderModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  modelUrl: imageUrl,
                  status: 'completed',
                ),
              );
            case FailureResult(failure: final failure):
              return FailureResult(failure);
          }
        case FailureResult(failure: final failure):
          return FailureResult(failure);
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
