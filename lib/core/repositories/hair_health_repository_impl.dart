import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'package:qwenhairaiapp/core/entities/hair_diagnostics.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/core/network/qwen_cloud_client.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository.dart';

/// Parses a Qwen Vision analysis text into structured [HairDiagnostics].
HairDiagnostics _parseAnalysis(String rawText) {
  final lower = rawText.toLowerCase();

  // Extract hair type
  String hairType = 'Not specified';
  for (final type in [
    '2a', '2b', '2c', '3a', '3b', '3c', '4a', '4b', '4c'
  ]) {
    if (lower.contains(type)) {
      hairType = type.toUpperCase();
      break;
    }
  }
  // Fallback: look for wavy/curly/coily keywords
  if (hairType == 'Not specified') {
    if (lower.contains('wavy')) {
      hairType = '2 — Wavy';
    } else if (lower.contains('curly')) {
      hairType = '3 — Curly';
    } else if (lower.contains('coily') || lower.contains('kinky')) {
      hairType = '4 — Coily';
    }
  }

  // Extract density
  String hairDensity = 'Not specified';
  for (final d in ['thin', 'low density', 'fine', 'medium', 'thick', 'high density', 'dense']) {
    if (lower.contains(d)) {
      hairDensity = d[0].toUpperCase() + d.substring(1);
      break;
    }
  }

  // Extract texture
  String hairTexture = 'Not specified';
  for (final t in ['fine', 'medium', 'coarse', 'silky', 'rough', 'dry']) {
    if (lower.contains(t)) {
      hairTexture = t[0].toUpperCase() + t.substring(1);
      break;
    }
  }

  // Extract scalp condition
  String scalpCondition = 'Not specified';
  for (final s in ['healthy', 'dry', 'oily', 'flaky', 'irritated', 'normal']) {
    if (lower.contains('scalp') && lower.contains(s)) {
      scalpCondition = s[0].toUpperCase() + s.substring(1);
      break;
    }
  }
  if (scalpCondition == 'Not specified') {
    if (lower.contains('scalp')) {
      // Try to find what's said about the scalp
      final scalpIdx = lower.indexOf('scalp');
      final snippet = lower.substring(
        scalpIdx.clamp(0, lower.length),
        (scalpIdx + 80).clamp(0, lower.length),
      );
      if (snippet.contains('health')) {
        scalpCondition = 'Healthy';
      } else if (snippet.contains('dry')) {
        scalpCondition = 'Dry';
      } else if (snippet.contains('oil')) {
        scalpCondition = 'Oily';
      }
    }
  }

  // Calculate health score from keywords
  int healthScore = 70; // default moderate
  if (lower.contains('excellent') || lower.contains('very healthy')) {
    healthScore = 92;
  } else if (lower.contains('healthy') && !lower.contains('unhealthy')) {
    healthScore = 82;
  } else if (lower.contains('moderate') || lower.contains('average')) {
    healthScore = 65;
  } else if (lower.contains('damage') || lower.contains('brittle') || lower.contains('breakage')) {
    healthScore = 45;
  } else if (lower.contains('severe') && (lower.contains('damage') || lower.contains('drought'))) {
    healthScore = 25;
  }

  // Extract damage concerns
  String? damageConcerns;
  for (final c in ['damage', 'breakage', 'split ends', 'dryness', 'brittle', 'thinning', 'hair loss']) {
    if (lower.contains(c)) {
      damageConcerns = damageConcerns == null
          ? c[0].toUpperCase() + c.substring(1)
          : '$damageConcerns, ${c[0].toUpperCase()}${c.substring(1)}';
    }
  }

  // Extract recommendations
  final List<String> recommendations = [];
  // Look for numbered lists or bullet points after "recommend" keywords
  final lines = rawText.split('\n');
  bool inRecommendations = false;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final lowerLine = trimmed.toLowerCase();
    if (lowerLine.contains('recommend') ||
        lowerLine.contains('suggestion') ||
        lowerLine.contains('tip') ||
        lowerLine.contains('advice')) {
      inRecommendations = true;
      continue;
    }
    if (inRecommendations) {
      // Remove numbering/bullets
      final clean = trimmed
          .replaceFirst(RegExp(r'^[\d\.\-\*\•\s]+'), '')
          .trim();
      if (clean.isNotEmpty && clean.length > 10) {
        recommendations.add(clean);
      }
    }
  }
  // Fallback: common recommendations based on detected issues
  if (recommendations.isEmpty) {
    if (damageConcerns != null && damageConcerns.contains('dry')) {
      recommendations.add('Use a deep conditioning treatment weekly');
    }
    if (damageConcerns != null && damageConcerns.contains('breakage')) {
      recommendations.add('Minimize heat styling and use protective styles');
    }
    if (hairType.startsWith('4')) {
      recommendations.add('Moisturize regularly with water-based products');
      recommendations.add('Protect hair at night with a satin bonnet or pillowcase');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Continue your current hair care routine');
      recommendations.add('Schedule a follow-up scan in 4 weeks');
    }
  }

  return HairDiagnostics(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    timestamp: DateTime.now(),
    hairType: hairType,
    hairDensity: hairDensity,
    hairTexture: hairTexture,
    scalpCondition: scalpCondition,
    healthScore: healthScore.clamp(0, 100),
    damageConcerns: damageConcerns,
    recommendations: recommendations,
    rawAnalysis: rawText,
  );
}

class HairHealthRepositoryImpl implements HairHealthRepository {
  final Dio dio;
  final QwenCloudClient qwenCloud;

  HairHealthRepositoryImpl({required this.dio, required this.qwenCloud});

  @override
  Future<Result<HairDiagnostics, Failure>> analyzeHairPhoto(
    String imagePath,
  ) async {
    try {
      final result = await qwenCloud.analyzeImageFromFile(
        prompt:
            'You are a professional trichologist and hair health expert. '
            'Analyze this hair photo in detail and provide:\n'
            '1. Hair type classification (2A-4C hair typing system)\n'
            '2. Hair density (thin, medium, thick)\n'
            '3. Hair texture (fine, medium, coarse)\n'
            '4. Scalp condition\n'
            '5. Overall hair health score (0-100)\n'
            '6. Any visible damage or concerns (split ends, breakage, dryness, thinning)\n'
            '7. Specific, actionable recommendations for hair care improvements\n\n'
            'Format your response with clear sections and bullet-point recommendations.',
        filePath: imagePath,
      );

      switch (result) {
        case Success(value: final analysisText):
          final diagnostics = _parseAnalysis(analysisText);
          return Success(diagnostics);
        case FailureResult(failure: final failure):
          return FailureResult(failure);
      }
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<String, Failure>> generateDiagnosticsPdf(
    HairDiagnostics diagnostics,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'HairPredict — Hair Diagnostics Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Paragraph(
              text: 'Generated on ${diagnostics.timestamp.toLocal()}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // Summary
            pw.Header(level: 1, text: 'Summary'),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _pdfInfoCard('Hair Type', diagnostics.hairType),
                _pdfInfoCard('Health Score', '${diagnostics.healthScore}/100'),
              ],
            ),
            pw.SizedBox(height: 24),

            // Detailed Analysis
            pw.Header(level: 1, text: 'Detailed Analysis'),
            _pdfDetailRow('Hair Type', diagnostics.hairType),
            _pdfDetailRow('Density', diagnostics.hairDensity),
            _pdfDetailRow('Texture', diagnostics.hairTexture),
            _pdfDetailRow('Scalp Condition', diagnostics.scalpCondition),
            if (diagnostics.damageConcerns != null)
              _pdfDetailRow('Concerns', diagnostics.damageConcerns!),
            pw.SizedBox(height: 24),

            // Recommendations
            pw.Header(level: 1, text: 'Recommendations'),
            for (final rec in diagnostics.recommendations)
              pw.Bullet(text: rec),
            pw.SizedBox(height: 24),

            // Raw Analysis
            pw.Header(level: 1, text: 'Full AI Analysis'),
            pw.Paragraph(
              text: diagnostics.rawAnalysis,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final fileName =
          'hair_diagnostics_${diagnostics.id}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return Success(file.path);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to generate PDF: $e'));
    }
  }

  pw.Widget _pdfInfoCard(String label, String value) {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _pdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
