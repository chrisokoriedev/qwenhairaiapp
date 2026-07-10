import 'package:qwenhairaiapp/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Result<bool, Failure>> login(String email, String password);
  Future<Result<void, Failure>> logout();
}
