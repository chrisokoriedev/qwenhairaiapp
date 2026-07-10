import 'package:qwenhairaiapp/core/errors/failures.dart';

abstract class UseCase<T, Params> {
  Future<Result<T, Failure>> call(Params params);
}

class NoParams {
  const NoParams();
}
