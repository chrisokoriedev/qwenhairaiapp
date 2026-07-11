import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/constants/api_keys.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/utils/image_utils.dart';

class QwenCloudClient {
  final Dio _dio;

  QwenCloudClient(this._dio);

  /// Build the common headers for DashScope API calls.
  Options get _authOptions => Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.qwenCloudApiKey}',
          'Content-Type': 'application/json',
        },
      );

  /// Call a multimodal Qwen model (e.g., qwen3.6-plus) for vision understanding.
  ///
  /// [imageUrl] can be a URL or a base64 data URI (e.g., `data:image/jpeg;base64,...`).
  Future<Result<String, Failure>> analyzeImage({
    required String prompt,
    required String imageUrl,
    String model = 'qwen3.6-plus',
  }) async {
    return _callMultimodalGeneration(
      model: model,
      messages: [
        {'text': prompt},
        {'image': imageUrl},
      ],
    );
  }

  /// Same as [analyzeImage] but reads the image from a local file path,
  /// converts it to a base64 data URI, and sends it to DashScope.
  ///
  /// This eliminates the need for a separate image upload backend.
  Future<Result<String, Failure>> analyzeImageFromFile({
    required String prompt,
    required String filePath,
    String model = 'qwen3.6-plus',
  }) async {
    try {
      final dataUri = await ImageUtils.fileToDataUri(filePath);
      return analyzeImage(
        prompt: prompt,
        imageUrl: dataUri,
        model: model,
      );
    } on ArgumentError catch (e) {
      return FailureResult(ServerFailure(e.message));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  /// Call a Wan text-to-image or image-edit model to generate style try-ons.
  Future<Result<String, Failure>> generateImage({
    required String prompt,
    String model = 'wan2.6-t2i',
    String size = '1280*1280',
  }) async {
    try {
      final response = await _dio.post(
        'https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation',
        options: _authOptions,
        data: {
          'model': model,
          'input': {
            'messages': [
              {
                'role': 'user',
                'content': [
                  {'text': prompt}
                ]
              }
            ]
          },
          'parameters': {
            'size': size,
            'n': 1,
          }
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['output']['choices'][0]['message']['content'];
        if (content is List) {
          final imageItem = content.firstWhere(
            (item) => item['image'] != null,
            orElse: () => null,
          );
          if (imageItem != null) {
            return Success(imageItem['image'] as String);
          }
        }
        return const FailureResult(ServerFailure('Image URL not found in response.'));
      } else {
        return const FailureResult(ServerFailure('Failed to generate image.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  /// Shared logic for multimodal generation calls to DashScope.
  Future<Result<String, Failure>> _callMultimodalGeneration({
    required String model,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final response = await _dio.post(
        'https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation',
        options: _authOptions,
        data: {
          'model': model,
          'input': {
            'messages': [
              {
                'role': 'user',
                'content': messages,
              }
            ]
          }
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['output']['choices'][0]['message']['content'];
        if (content is List) {
          final textItem = content.firstWhere(
            (item) => item['text'] != null,
            orElse: () => null,
          );
          if (textItem != null) {
            return Success(textItem['text'] as String);
          }
        }
        return Success(content.toString());
      } else {
        return const FailureResult(ServerFailure('Failed to call Qwen Vision API.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
