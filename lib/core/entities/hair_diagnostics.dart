/// Results from a Qwen Vision hair diagnostic analysis.
class HairDiagnostics {
  final String id;
  final DateTime timestamp;

  // Classification
  final String hairType;
  final String hairDensity;
  final String hairTexture;

  // Scalp & health
  final String scalpCondition;
  final int healthScore; // 0–100
  final String? damageConcerns;

  // Recommendations
  final List<String> recommendations;

  // Raw analysis text from Qwen Vision
  final String rawAnalysis;

  const HairDiagnostics({
    required this.id,
    required this.timestamp,
    required this.hairType,
    required this.hairDensity,
    required this.hairTexture,
    required this.scalpCondition,
    required this.healthScore,
    this.damageConcerns,
    required this.recommendations,
    required this.rawAnalysis,
  });
}
