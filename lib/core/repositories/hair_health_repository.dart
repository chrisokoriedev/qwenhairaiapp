import 'package:qwenhairaiapp/core/entities/hair_diagnostics.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';

abstract class HairHealthRepository {
  /// Analyzes a hair photo using Qwen Vision and returns structured diagnostics.
  Future<Result<HairDiagnostics, Failure>> analyzeHairPhoto(String imagePath);

  /// Generates a PDF dossier from diagnostics and returns the file path.
  Future<Result<String, Failure>> generateDiagnosticsPdf(
    HairDiagnostics diagnostics,
  );
}
