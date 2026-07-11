import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwenhairaiapp/core/entities/hair_diagnostics.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository.dart';

sealed class DiagnosticsState {
  const DiagnosticsState();
}

class DiagnosticsInitial extends DiagnosticsState {
  const DiagnosticsInitial();
}

class DiagnosticsAnalyzing extends DiagnosticsState {
  const DiagnosticsAnalyzing();
}

class DiagnosticsLoaded extends DiagnosticsState {
  final HairDiagnostics diagnostics;
  const DiagnosticsLoaded(this.diagnostics);
}

class DiagnosticsPdfGenerating extends DiagnosticsState {
  final HairDiagnostics diagnostics;
  const DiagnosticsPdfGenerating(this.diagnostics);
}

class DiagnosticsPdfReady extends DiagnosticsState {
  final HairDiagnostics diagnostics;
  final String pdfPath;
  const DiagnosticsPdfReady(this.diagnostics, this.pdfPath);
}

class DiagnosticsError extends DiagnosticsState {
  final String message;
  const DiagnosticsError(this.message);
}

/// Manages the hair diagnostics flow: analyze → show results → generate PDF.
class DiagnosticsCubit extends Cubit<DiagnosticsState> {
  final HairHealthRepository _repository;

  DiagnosticsCubit(this._repository) : super(const DiagnosticsInitial());

  /// Analyze a hair photo using Qwen Vision.
  Future<void> analyzeHairPhoto(String imagePath) async {
    emit(const DiagnosticsAnalyzing());
    final result = await _repository.analyzeHairPhoto(imagePath);
    switch (result) {
      case Success(value: final diagnostics):
        emit(DiagnosticsLoaded(diagnostics));
      case FailureResult(failure: final failure):
        emit(DiagnosticsError(failure.message));
    }
  }

  /// Generate a PDF dossier from the current diagnostics.
  Future<void> generatePdf(HairDiagnostics diagnostics) async {
    emit(DiagnosticsPdfGenerating(diagnostics));
    final result = await _repository.generateDiagnosticsPdf(diagnostics);
    switch (result) {
      case Success(value: final pdfPath):
        emit(DiagnosticsPdfReady(diagnostics, pdfPath));
      case FailureResult(failure: final failure):
        emit(DiagnosticsError(failure.message));
    }
  }

  /// Reset back to initial state for a new analysis.
  void reset() => emit(const DiagnosticsInitial());
}
