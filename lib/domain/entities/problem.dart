import 'package:equatable/equatable.dart';

enum Severity { selfHelp, followUp, urgent } // a / b / c

class ProblemSpectrum {
  final String normal;
  final String warning;
  final String crisis;

  const ProblemSpectrum({
    this.normal = '',
    this.warning = '',
    this.crisis = '',
  });

  factory ProblemSpectrum.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProblemSpectrum();
    return ProblemSpectrum(
      normal: json['normal'] as String? ?? '',
      warning: json['warning'] as String? ?? '',
      crisis: json['crisis'] as String? ?? '',
    );
  }

  bool get hasData =>
      normal.isNotEmpty || warning.isNotEmpty || crisis.isNotEmpty;
}

class ProblemSource {
  final String title;
  final String url;

  const ProblemSource({required this.title, required this.url});

  factory ProblemSource.fromJson(Map<String, dynamic> json) {
    return ProblemSource(
      title: json['t'] as String? ?? json['title'] as String? ?? '',
      url: json['u'] as String? ?? json['url'] as String? ?? '',
    );
  }
}

class Problem extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final Severity severity;
  final String icon;
  final List<int> toolIds;
  final String what;
  final String common;
  final List<String> signs;
  final String honest;
  final String danger;
  final bool isAdult;
  final String kind;
  final ProblemSpectrum spectrum;
  final List<String> selfHelp;
  final List<ProblemSource> sources;
  final List<String> examples;

  const Problem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.severity,
    required this.icon,
    required this.toolIds,
    required this.what,
    required this.common,
    required this.signs,
    required this.honest,
    required this.danger,
    this.isAdult = false,
    this.kind = 'experience',
    this.spectrum = const ProblemSpectrum(),
    this.selfHelp = const [],
    this.sources = const [],
    this.examples = const [],
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    final sev = json['sev'] as String? ?? 'a';
    final sourcesRaw = json['sources'] as List? ?? [];
    return Problem(
      id: json['id'] as String,
      name: json['n'] as String? ?? json['name'] as String,
      categoryId: json['cat'] as String? ?? json['categoryId'] as String,
      severity: sev == 'c'
          ? Severity.urgent
          : (sev == 'b' ? Severity.followUp : Severity.selfHelp),
      icon: json['icon'] as String? ?? 'i-heart',
      toolIds: (json['toolIds'] as List? ?? []).map((e) => e as int).toList(),
      what: json['what'] as String? ?? '',
      common: json['common'] as String? ?? '',
      signs: (json['signs'] as List? ?? []).map((e) => e.toString()).toList(),
      honest: json['honest'] as String? ?? '',
      danger: json['danger'] as String? ?? '',
      isAdult: json['adult'] as bool? ?? false,
      kind: json['kind'] as String? ?? 'experience',
      spectrum: ProblemSpectrum.fromJson(
        json['spectrum'] is Map
            ? Map<String, dynamic>.from(json['spectrum'] as Map)
            : null,
      ),
      selfHelp:
          (json['selfHelp'] as List? ?? []).map((e) => e.toString()).toList(),
      sources: sourcesRaw
          .map((e) => ProblemSource.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      examples:
          (json['examples'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  String get severityLabel {
    switch (severity) {
      case Severity.selfHelp:
        return 'طیف · خودیاری';
      case Severity.followUp:
        return 'طیف · هشدار';
      case Severity.urgent:
        return 'طیف · بحران';
    }
  }

  bool get crisisRequired =>
      severity == Severity.urgent || spectrum.crisis.isNotEmpty;

  int get sourceCount => sources.length;

  @override
  List<Object?> get props => [id, name];
}
