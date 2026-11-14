import 'package:equatable/equatable.dart';

enum EvidenceLevel { strong, moderate, limited, conceptual }

enum Difficulty { easy, medium, hard }

class Method extends Equatable {
  final int id;
  final String title;
  final String categoryId;
  final String time;
  final Difficulty difficulty;
  final EvidenceLevel evidence;
  final String description;
  final bool isAdult;
  final String? subtitle;
  final String? gradient;
  final String? icon;

  const Method({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.time,
    required this.difficulty,
    required this.evidence,
    required this.description,
    this.isAdult = false,
    this.subtitle,
    this.gradient,
    this.icon,
  });

  factory Method.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int id;
    if (rawId is int) {
      id = rawId;
    } else if (rawId is String) {
      id = int.tryParse(rawId) ?? 0;
    } else {
      id = 0;
    }
    return Method(
      id: id,
      title: json['t'] as String? ?? json['title'] as String? ?? '',
      categoryId: json['c'] as String? ?? json['categoryId'] as String? ?? '',
      time: json['time'] as String? ?? '—',
      difficulty: _parseDifficulty(
        json['d'] as String? ??
            json['diff'] as String? ??
            json['difficulty'] as String?,
      ),
      evidence: _parseEvidence(
        json['e'] as String? ??
            json['ev'] as String? ??
            json['evidence'] as String?,
      ),
      description: json['desc'] as String? ?? json['description'] as String? ?? '',
      isAdult: json['adult'] as bool? ?? (json['c'] == 'sexual'),
      subtitle: json['sub'] as String?,
      gradient: json['g'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        't': title,
        'c': categoryId,
        'time': time,
        'd': difficulty.name,
        'e': evidence.name,
        'desc': description,
        if (isAdult) 'adult': true,
        if (subtitle != null) 'sub': subtitle,
        if (gradient != null) 'g': gradient,
        if (icon != null) 'icon': icon,
      };

  static Difficulty _parseDifficulty(String? v) {
    switch (v) {
      case 'آسان':
      case 'easy':
        return Difficulty.easy;
      case 'سخت':
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }

  static EvidenceLevel _parseEvidence(String? v) {
    switch (v) {
      case 'قوی':
      case 'strong':
        return EvidenceLevel.strong;
      case 'متوسط':
      case 'moderate':
      case 'mid':
        return EvidenceLevel.moderate;
      case 'محدود':
      case 'limited':
      case 'low':
        return EvidenceLevel.limited;
      default:
        return EvidenceLevel.conceptual;
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case Difficulty.easy:
        return 'آسان';
      case Difficulty.medium:
        return 'متوسط';
      case Difficulty.hard:
        return 'سخت';
    }
  }

  String get evidenceLabel {
    switch (evidence) {
      case EvidenceLevel.strong:
        return 'قوی';
      case EvidenceLevel.moderate:
        return 'متوسط';
      case EvidenceLevel.limited:
        return 'محدود';
      case EvidenceLevel.conceptual:
        return 'چارچوب مفهومی';
    }
  }

  @override
  List<Object?> get props => [id, title, categoryId];
}
