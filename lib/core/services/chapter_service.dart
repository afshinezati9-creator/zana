import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/chapter.dart';
import '../../domain/entities/method.dart';
import 'local_content_store.dart';

/// بارگذاری اسلاید ابزار از لایه محلی، سپس فایل واحد، سپس پشتیبان قدیمی.
class ChapterService {
  static final ChapterService _instance = ChapterService._();
  factory ChapterService() => _instance;
  ChapterService._();

  Map<int, List<Chapter>>? _cache;
  bool _legacyLoaded = false;
  Map<String, dynamic>? _legacyMap;

  void invalidateCache() {
    _cache = {};
  }

  Future<void> ensureLoaded() async {
    if (_legacyLoaded) return;
    _legacyLoaded = true;
    _cache ??= {};
    try {
      final raw = await rootBundle.loadString('content/method_slides.json');
      _legacyMap = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      _legacyMap = {};
    }
  }

  Future<List<Chapter>> loadChapters(int methodId) async {
    await ensureLoaded();
    if (_cache != null && _cache!.containsKey(methodId)) {
      return _cache![methodId]!;
    }

    List<dynamic>? slideList;

    try {
      final local =
          await LocalContentStore().getMethodUnit(methodId.toString());
      if (local != null) {
        final slides = local['slides'];
        if (slides is List && slides.isNotEmpty) slideList = slides;
      }
    } catch (_) {}

    if (slideList == null || slideList.isEmpty) {
      try {
        final raw = await rootBundle
            .loadString('content/units/methods/$methodId.json');
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final slides = map['slides'];
        if (slides is List) slideList = slides;
      } catch (_) {}
    }

    if (slideList == null || slideList.isEmpty) {
      final legacy = _legacyMap?['$methodId'];
      if (legacy is List) slideList = legacy;
    }

    final chapters = _mapSlides(slideList);
    _cache ??= {};
    _cache![methodId] = chapters;
    return chapters;
  }

  List<Chapter> getChapters(Method method) {
    final cached = _cache?[method.id];
    if (cached != null && cached.isNotEmpty) return cached;
    final legacy = _legacyMap?['${method.id}'];
    if (legacy is List && legacy.isNotEmpty) {
      final chapters = _mapSlides(legacy);
      _cache ??= {};
      _cache![method.id] = chapters;
      return chapters;
    }
    return [
      Chapter(
        tag: 'pending',
        tagLabel: 'اسلاید ۱',
        title: method.title,
        lead: method.description,
        blocks: [
          ChapterBlock(
            type: BlockType.concept,
            text: method.description,
          ),
        ],
      ),
    ];
  }

  List<Chapter> _mapSlides(List<dynamic>? slideList) {
    final chapters = <Chapter>[];
    if (slideList == null) return chapters;
    for (var i = 0; i < slideList.length; i++) {
      final item = slideList[i];
      if (item is! Map) continue;
      final n = item['n'] as int? ?? (i + 1);
      final title = (item['title'] as String?)?.trim() ?? 'اسلاید $n';
      final body = (item['body'] as String?)?.trim() ?? '';
      chapters.add(
        Chapter(
          tag: 'slide_$n',
          tagLabel: 'اسلاید $n',
          title: title,
          lead: null,
          cliff: n < slideList.length ? 'ادامه: اسلاید بعدی' : null,
          blocks: [
            ChapterBlock(
              type: BlockType.concept,
              text: body,
            ),
          ],
        ),
      );
    }
    return chapters;
  }
}
