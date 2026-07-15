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
    required String faceScanPath,
    required String targetHairStylePath,
  }) async {
    try {
      // Step 1: Analyze the face scan image to extract facial features and structure using Qwen Vision.
      final analysisResult = await qwenCloud.analyzeImageFromFile(
        prompt:
            'You are a professional AI hair stylist. Analyze this face photo and provide:\n'
            '1. Face shape classification (round, oval, square, heart, oblong)\n'
            '2. Hairline position and forehead structure\n'
            '3. Skin tone and undertones\n'
            '4. A summary of facial proportions (symmetry, chin, cheekbones)',
        filePath: faceScanPath,
      );

      switch (analysisResult) {
        case Success(value: final analysis):
          // Step 2: Use the facial analysis and style description to generate the final try-on rendering.
          // In a production setup, we would upload both faceScanPath and targetHairStylePath as reference images
          // to wan2.7-image-pro. Here we request the Wan generator to render the custom hairstyle onto the analyzed face.
          final renderResult = await qwenCloud.generateImage(
            prompt:
                'Generate a highly realistic professional 3D hair try-on rendering for a person with this facial analysis: $analysis. '
                'The hair styling must accurately match the custom hairstyle from the reference image. '
                'Show a high-quality 3D portrait model showing how this hair fits their face shape and features perfectly.',
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
