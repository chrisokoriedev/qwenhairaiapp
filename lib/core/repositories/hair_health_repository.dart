import 'package:qwenhairaiapp/core/errors/failures.dart';

abstract class HairHealthRepository {
  Future<Result<String, Failure>> getDiagnosticsReport();
}
