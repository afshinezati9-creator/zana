import 'package:equatable/equatable.dart';

/// انواع بلاک‌های داخل هر فصل
enum BlockType {
  story,
  checklist,
  promise,
  concept,
  sci,
  quote,
  actionSteps,
  timer,
  days,
  mirrorBefore,
  mirrorAfter,
  mirrorSigns,
  exit,
  evidence,
  sources,
  limits,
  ending,
}

class ChapterBlock extends Equatable {
  final BlockType type;
  final String? label;
  final String? text;
  final List<String>? items;
  final List<Map<String, dynamic>>? dayItems; // for days type
  final int? minutes; // for timer
  final String? level; // for evidence

  const ChapterBlock({
    required this.type,
    this.label,
    this.text,
    this.items,
    this.dayItems,
    this.minutes,
    this.level,
  });

  factory ChapterBlock.fromJson(Map<String, dynamic> json) {
    return ChapterBlock(
      type: _parseType(json['t'] as String? ?? json['type'] as String?),
      label: json['label'] as String?,
      text: json['text'] as String?,
      items: (json['items'] as List?)?.map((e) => e.toString()).toList(),
      dayItems: (json['items'] as List?)
          ?.whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      minutes: json['minutes'] as int?,
      level: json['level'] as String?,
    );
  }

  static BlockType _parseType(String? v) {
    switch (v) {
      case 'story':
        return BlockType.story;
      case 'checklist':
        return BlockType.checklist;
      case 'promise':
        return BlockType.promise;
      case 'concept':
        return BlockType.concept;
      case 'sci':
        return BlockType.sci;
      case 'quote':
        return BlockType.quote;
      case 'action-steps':
      case 'actionSteps':
        return BlockType.actionSteps;
      case 'timer':
        return BlockType.timer;
      case 'days':
        return BlockType.days;
      case 'mirror-before':
      case 'mirrorBefore':
        return BlockType.mirrorBefore;
      case 'mirror-after':
      case 'mirrorAfter':
        return BlockType.mirrorAfter;
      case 'mirror-signs':
      case 'mirrorSigns':
        return BlockType.mirrorSigns;
      case 'exit':
        return BlockType.exit;
      case 'evidence':
        return BlockType.evidence;
      case 'sources':
        return BlockType.sources;
      case 'limits':
        return BlockType.limits;
      case 'ending':
        return BlockType.ending;
      default:
        return BlockType.story;
    }
  }

  @override
  List<Object?> get props => [type, label, text];
}

class Chapter extends Equatable {
  final String tag;
  final String tagLabel;
  final String title;
  final String? lead;
  final String? origin;
  final String? cliff;
  final List<ChapterBlock> blocks;

  const Chapter({
    required this.tag,
    required this.tagLabel,
    required this.title,
    this.lead,
    this.origin,
    this.cliff,
    required this.blocks,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      tag: json['tag'] as String? ?? 'hook',
      tagLabel: json['tagL'] as String? ?? json['tagLabel'] as String? ?? '',
      title: json['title'] as String,
      lead: json['lead'] as String?,
      origin: json['origin'] as String?,
      cliff: json['cliff'] as String?,
      blocks: (json['blocks'] as List? ?? [])
          .map((e) => ChapterBlock.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [tag, title, blocks];
}
