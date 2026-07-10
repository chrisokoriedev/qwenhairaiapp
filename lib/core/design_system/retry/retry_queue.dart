import 'dart:async';


/// Queues failed write operations and retries them when connectivity returns.
///
/// Interface only — concrete queue implementation lands when the first
/// write-path consumer (3D reconstruction, diagnostic submission) needs it.
abstract class RetryQueue {
  Future<void> enqueue(Future<void> Function() op);
  Future<void> retryAll();
}

class NoopRetryQueue implements RetryQueue {
  @override
  Future<void> enqueue(Future<void> Function() op) async {}

  @override
  Future<void> retryAll() async {}
}
