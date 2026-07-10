abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A cache error occurred.']);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'No internet connection.']);
}

sealed class Result<S, E extends Failure> {
  const Result();
}

class Success<S, E extends Failure> extends Result<S, E> {
  final S value;
  const Success(this.value);
}

class FailureResult<S, E extends Failure> extends Result<S, E> {
  final E failure;
  const FailureResult(this.failure);
}

