import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ProblemCategory extends Equatable {
  final String id;
  final String name;
  final int layer;
  final Color color;
  final bool pinned;
  final bool adult;
  final String kind;
  final String description;

  const ProblemCategory({
    required this.id,
    required this.name,
    required this.layer,
    required this.color,
    this.pinned = false,
    this.adult = false,
    this.kind = 'experience',
    this.description = '',
  });

  factory ProblemCategory.fromJson(Map<String, dynamic> json) {
    final hex = (json['color'] as String? ?? '#8b9dc3').replaceAll('#', '');
    final value = int.parse('FF$hex', radix: 16);
    return ProblemCategory(
      id: json['id'] as String,
      name: json['n'] as String? ?? json['name'] as String,
      layer: json['layer'] as int? ?? 1,
      color: Color(value),
      pinned: json['pinned'] as bool? ?? false,
      adult: json['adult'] as bool? ?? false,
      kind: json['kind'] as String? ?? 'experience',
      description: json['desc'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id];
}
