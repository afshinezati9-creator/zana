import 'package:equatable/equatable.dart';

/// پیشرفت کاربر برای هر روش
/// chaptersCompleted: تعداد فصل‌هایی که کاربر به آن‌ها رسیده (۰ تا ۷)
class MethodProgress extends Equatable {
  final int methodId;
  final int chaptersCompleted;
  final DateTime? lastOpened;
  final bool isCompleted;

  const MethodProgress({
    required this.methodId,
    required this.chaptersCompleted,
    this.lastOpened,
    this.isCompleted = false,
  });

  MethodProgress copyWith({
    int? chaptersCompleted,
    DateTime? lastOpened,
    bool? isCompleted,
  }) {
    return MethodProgress(
      methodId: methodId,
      chaptersCompleted: chaptersCompleted ?? this.chaptersCompleted,
      lastOpened: lastOpened ?? this.lastOpened,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory MethodProgress.fromJson(Map<String, dynamic> json) {
    return MethodProgress(
      methodId: json['methodId'] as int,
      chaptersCompleted: json['chaptersCompleted'] as int? ?? 0,
      lastOpened: json['lastOpened'] != null
          ? DateTime.tryParse(json['lastOpened'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'methodId': methodId,
        'chaptersCompleted': chaptersCompleted,
        if (lastOpened != null) 'lastOpened': lastOpened!.toIso8601String(),
        'isCompleted': isCompleted,
      };

  @override
  List<Object?> get props => [methodId, chaptersCompleted, isCompleted];
}
