class ServerException implements Exception {
  final String? message;
  const ServerException([this.message]);

  @override
  String toString() => message ?? 'ServerException';
}

class CacheException implements Exception {
  final String? message;
  const CacheException([this.message]);

  @override
  String toString() => message ?? 'CacheException';
}

class ConnectionException implements Exception {
  final String? message;
  const ConnectionException([this.message]);

  @override
  String toString() => message ?? 'ConnectionException';
}
