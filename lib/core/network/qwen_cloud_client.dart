import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/constants/api_keys.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';

class QwenCloudClient {
  final Dio _dio;

  QwenCloudClient(this._dio);

  /// Call a multimodal Qwen model (e.g., qwen3.6-plus) for vision understanding.
  Future<Result<String, Failure>> analyzeImage({
    required String prompt,
    required String imageUrl,
    String model = 'qwen3.6-plus',
  }) async {
    try {
      final response = await _dio.post(
        'https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiKeys.qwenCloudApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'input': {
            'messages': [
              {
                'role': 'user',
                'content': [
                  {'text': prompt},
                  {'image': imageUrl},
                ]
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

  /// Call a Wan text-to-image or image-edit model to generate style try-ons.
  Future<Result<String, Failure>> generateImage({
    required String prompt,
    String model = 'wan2.6-t2i',
    String size = '1280*1280',
  }) async {
    try {
      final response = await _dio.post(
        'https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiKeys.qwenCloudApiKey}',
            'Content-Type': 'application/json',
          },
        ),
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
}
