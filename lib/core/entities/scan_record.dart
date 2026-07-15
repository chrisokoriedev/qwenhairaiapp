/// A single scan history entry persisted across sessions.
class ScanRecord {
  final String id;
  final DateTime dateTime;
  final String? imagePath;
  final String type; // 'diagnostics', 'style_try_on'
  final String summary;
  final int? healthScore;

  const ScanRecord({
    required this.id,
    required this.dateTime,
    this.imagePath,
    required this.type,
    required this.summary,
    this.healthScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'imagePath': imagePath,
        'type': type,
        'summary': summary,
        'healthScore': healthScore,
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        imagePath: json['imagePath'] as String?,
        type: json['type'] as String,
        summary: json['summary'] as String,
        healthScore: json['healthScore'] as int?,
      );
}
