import 'package:equatable/equatable.dart';

class TriggerReportModel extends Equatable {
  const TriggerReportModel({
    required this.id,
    required this.coupleId,
    required this.summaryText,
    required this.patterns,
    required this.recommendations,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    this.conflictRiskScore = 0.0,
  });

  final String id;
  final String coupleId;
  final String summaryText;
  final List<TriggerPattern> patterns;
  final List<String> recommendations;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double conflictRiskScore;

  Map<String, dynamic> toJson() => {
        'id': id,
        'coupleId': coupleId,
        'summaryText': summaryText,
        'patterns': patterns.map((p) => p.toJson()).toList(),
        'recommendations': recommendations,
        'generatedAt': generatedAt.toIso8601String(),
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'conflictRiskScore': conflictRiskScore,
      };

  factory TriggerReportModel.fromJson(Map<String, dynamic> json) =>
      TriggerReportModel(
        id: json['id'] as String,
        coupleId: json['coupleId'] as String,
        summaryText: json['summaryText'] as String,
        patterns: (json['patterns'] as List<dynamic>)
            .map((e) => TriggerPattern.fromJson(e as Map<String, dynamic>))
            .toList(),
        recommendations: List<String>.from(json['recommendations'] as List),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        periodStart: DateTime.parse(json['periodStart'] as String),
        periodEnd: DateTime.parse(json['periodEnd'] as String),
        conflictRiskScore:
            (json['conflictRiskScore'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [
        id,
        coupleId,
        summaryText,
        patterns,
        recommendations,
        generatedAt,
        periodStart,
        periodEnd,
        conflictRiskScore,
      ];
}

class TriggerPattern extends Equatable {
  const TriggerPattern({
    required this.description,
    required this.dayOfWeek,
    required this.hour,
    required this.frequency,
    required this.intensity,
  });

  final String description;
  final int dayOfWeek;
  final int hour;
  final double frequency;
  final double intensity;

  Map<String, dynamic> toJson() => {
        'description': description,
        'dayOfWeek': dayOfWeek,
        'hour': hour,
        'frequency': frequency,
        'intensity': intensity,
      };

  factory TriggerPattern.fromJson(Map<String, dynamic> json) => TriggerPattern(
        description: json['description'] as String,
        dayOfWeek: json['dayOfWeek'] as int,
        hour: json['hour'] as int,
        frequency: (json['frequency'] as num).toDouble(),
        intensity: (json['intensity'] as num).toDouble(),
      );

  @override
  List<Object?> get props =>
      [description, dayOfWeek, hour, frequency, intensity];
}
