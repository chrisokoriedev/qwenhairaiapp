import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/features/hair_health/domain/repositories/hair_health_repository.dart';

class HairHealthRepositoryImpl implements HairHealthRepository {
  final Dio dio;

  HairHealthRepositoryImpl({required this.dio});

  @override
  Future<Result<String, Failure>> getDiagnosticsReport() async {
    try {
      final response = await dio.get('/hair-health/diagnostics');
      if (response.statusCode == 200) {
        return Success(response.data.toString());
      } else {
        return const FailureResult(ServerFailure('Failed to load diagnostics report.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
