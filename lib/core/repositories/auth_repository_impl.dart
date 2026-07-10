import 'package:dio/dio.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  AuthRepositoryImpl({required this.dio});

  @override
  Future<Result<bool, Failure>> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return const FailureResult(ServerFailure('Invalid credentials.'));
      }
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await dio.post('/auth/logout');
      return const Success(null);
    } on DioException catch (e) {
      return FailureResult(ServerFailure(e.message ?? 'Network error occurred.'));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
