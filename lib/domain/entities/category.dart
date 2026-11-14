import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String gradient; // CSS-like or hex pair for UI

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradient,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['n'] as String? ?? json['name'] as String,
      icon: json['icon'] as String? ?? 'i-user',
      gradient: json['g'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'icon': icon,
        'g': gradient,
      };

  @override
  List<Object?> get props => [id, name, icon, gradient];
}
