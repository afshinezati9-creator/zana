import 'package:equatable/equatable.dart';

/// نتیجهٔ ذخیره‌شدهٔ مسیر آگاهی (فقط روی دستگاه)
class PathResult extends Equatable {
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// کلیدهای q1…q5 و مقدار id گزینه
  final Map<String, String> answers;

  /// مسیر گره‌های طی‌شده، مثلاً Q0, Q1, Q2_fatigue, …
  final List<String> path;

  final bool crisis;

  /// یک خط خلاصه برای کارت خانه
  final String summaryLine;

  final List<String> suggestedProblemIds;
  final List<int> suggestedMethodIds;
  final List<String> primaryCats;

  const PathResult({
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    required this.answers,
    required this.path,
    this.crisis = false,
    required this.summaryLine,
    this.suggestedProblemIds = const [],
    this.suggestedMethodIds = const [],
    this.primaryCats = const [],
  });

  factory PathResult.create({
    required Map<String, String> answers,
    required List<String> path,
    required String summaryLine,
    bool crisis = false,
    List<String> suggestedProblemIds = const [],
    List<int> suggestedMethodIds = const [],
    List<String> primaryCats = const [],
  }) {
    final now = DateTime.now().toUtc();
    return PathResult(
      createdAt: now,
      updatedAt: now,
      answers: Map<String, String>.from(answers),
      path: List<String>.from(path),
      crisis: crisis,
      summaryLine: summaryLine,
      suggestedProblemIds: List<String>.from(suggestedProblemIds),
      suggestedMethodIds: List<int>.from(suggestedMethodIds),
      primaryCats: List<String>.from(primaryCats),
    );
  }

  factory PathResult.fromJson(Map<String, dynamic> json) {
    final answersRaw = json['answers'];
    final answers = <String, String>{};
    if (answersRaw is Map) {
      answersRaw.forEach((k, v) {
        answers['$k'] = '$v';
      });
    }

    final pathRaw = json['path'];
    final path = <String>[];
    if (pathRaw is List) {
      for (final e in pathRaw) {
        path.add('$e');
      }
    }

    final problemIds = <String>[];
    final pr = json['suggestedProblemIds'];
    if (pr is List) {
      for (final e in pr) {
        problemIds.add('$e');
      }
    }

    final methodIds = <int>[];
    final mr = json['suggestedMethodIds'];
    if (mr is List) {
      for (final e in mr) {
        if (e is int) {
          methodIds.add(e);
        } else {
          final n = int.tryParse('$e');
          if (n != null) methodIds.add(n);
        }
      }
    }

    final cats = <String>[];
    final cr = json['primaryCats'];
    if (cr is List) {
      for (final e in cr) {
        cats.add('$e');
      }
    }

    DateTime parseTs(dynamic v) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v)?.toUtc() ?? DateTime.now().toUtc();
      }
      return DateTime.now().toUtc();
    }

    // سازگاری با ذخیرهٔ قدیمی مسیر (فقط category)
    if (answers.isEmpty && json['category'] != null) {
      answers['legacy_category'] = '${json['category']}';
    }

    return PathResult(
      version: json['version'] is int ? json['version'] as int : 1,
      createdAt: parseTs(json['createdAt']),
      updatedAt: parseTs(json['updatedAt'] ?? json['createdAt']),
      answers: answers,
      path: path,
      crisis: json['crisis'] == true,
      summaryLine: json['summaryLine'] as String? ??
          json['summary'] as String? ??
          (answers['legacy_category'] != null
              ? 'مسیر قبلی (نسخهٔ قدیم)'
              : 'نتیجهٔ مسیر'),
      suggestedProblemIds: problemIds,
      suggestedMethodIds: methodIds,
      primaryCats: cats.isNotEmpty
          ? cats
          : (json['category'] != null ? ['${json['category']}'] : const []),
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'answers': answers,
        'path': path,
        'crisis': crisis,
        'summaryLine': summaryLine,
        'suggestedProblemIds': suggestedProblemIds,
        'suggestedMethodIds': suggestedMethodIds,
        'primaryCats': primaryCats,
      };

  PathResult copyWith({
    DateTime? updatedAt,
    Map<String, String>? answers,
    List<String>? path,
    bool? crisis,
    String? summaryLine,
    List<String>? suggestedProblemIds,
    List<int>? suggestedMethodIds,
    List<String>? primaryCats,
  }) {
    return PathResult(
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answers: answers ?? this.answers,
      path: path ?? this.path,
      crisis: crisis ?? this.crisis,
      summaryLine: summaryLine ?? this.summaryLine,
      suggestedProblemIds: suggestedProblemIds ?? this.suggestedProblemIds,
      suggestedMethodIds: suggestedMethodIds ?? this.suggestedMethodIds,
      primaryCats: primaryCats ?? this.primaryCats,
    );
  }

  bool get hasSuggestions =>
      suggestedMethodIds.isNotEmpty || suggestedProblemIds.isNotEmpty;

  String get q1 => answers['q1'] ?? '';
  String get q2 => answers['q2'] ?? '';
  String get q3 => answers['q3'] ?? '';
  String get q4 => answers['q4'] ?? '';
  String get q5 => answers['q5'] ?? '';

  @override
  List<Object?> get props => [
        version,
        createdAt,
        updatedAt,
        answers,
        path,
        crisis,
        summaryLine,
        suggestedProblemIds,
        suggestedMethodIds,
        primaryCats,
      ];
}
