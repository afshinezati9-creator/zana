import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/method.dart';
import '../../domain/entities/problem.dart';
import '../../domain/entities/problem_category.dart';
import 'chapter_service.dart';
import 'local_content_store.dart';

/// بارگذاری محتوا — ایندکس + فایل واحد + لایهٔ محلی تب مدیریت.
class ContentService {
  static final ContentService _instance = ContentService._();
  factory ContentService() => _instance;
  ContentService._();

  List<Category>? _categories;
  List<Method>? _methods;
  List<Problem>? _problems;
  List<ProblemCategory>? _problemCategories;
  List<Map<String, dynamic>>? _questions;
  Map<String, dynamic>? _crisis;
  List<Map<String, dynamic>>? _sources;

  final Map<String, String> _methodUpdatedAt = {};
  final Map<String, String> _problemUpdatedAt = {};

  bool get isLoaded =>
      _categories != null &&
      _methods != null &&
      _problems != null &&
      _questions != null &&
      _crisis != null &&
      _sources != null &&
      _problemCategories != null;

  Future<void> loadAll() async {
    final results = await Future.wait([
      rootBundle.loadString('content/categories.json'),
      _loadMethodsMerged(),
      _loadProblemsMerged(),
      rootBundle.loadString('content/questions.json'),
      rootBundle.loadString('content/crisis.json'),
      rootBundle.loadString('content/sources.json'),
      rootBundle.loadString('content/problem_categories.json'),
    ]);
    await ChapterService().ensureLoaded();

    _categories = (jsonDecode(results[0] as String) as List)
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    _methods = results[1] as List<Method>;
    _problems = results[2] as List<Problem>;

    _questions = (jsonDecode(results[3] as String) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    _crisis = Map<String, dynamic>.from(jsonDecode(results[4] as String));

    _sources = (jsonDecode(results[5] as String) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    _problemCategories = (jsonDecode(results[6] as String) as List)
        .map((e) => ProblemCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> reloadContent() async {
    _methods = null;
    _problems = null;
    _methodUpdatedAt.clear();
    _problemUpdatedAt.clear();
    ChapterService().invalidateCache();
    await loadAll();
  }

  Future<List<Method>> _loadMethodsMerged() async {
    final seed = await _loadMethodsSeed();
    final deleted = await LocalContentStore().loadDeletedMethodIds();
    final localUnits = await LocalContentStore().loadMethodUnits();

    final byId = <String, Method>{};
    for (final m in seed) {
      final id = '${m.id}';
      if (deleted.contains(id)) continue;
      byId[id] = m;
    }

    for (final entry in localUnits.entries) {
      final id = entry.key;
      final meta = Map<String, dynamic>.from(
          entry.value['meta'] as Map? ?? entry.value);
      byId[id] = Method.fromJson(meta);
      _methodUpdatedAt[id] = meta['updatedAt'] as String? ?? '';
    }

    final list = byId.values.toList();
    list.sort((a, b) {
      final ua = _methodUpdatedAt['${a.id}'] ?? '';
      final ub = _methodUpdatedAt['${b.id}'] ?? '';
      if (ua.isNotEmpty || ub.isNotEmpty) {
        final c = ub.compareTo(ua);
        if (c != 0) return c;
      }
      return a.id.compareTo(b.id);
    });
    return list;
  }

  Future<List<Method>> _loadMethodsSeed() async {
    final byId = <String, Method>{};

    // 1) از ایندکس + فایل واحد
    try {
      final raw = await rootBundle.loadString('content/methods_index.json');
      final list = jsonDecode(raw) as List;
      for (final item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = '${map['id']}';
        try {
          final unitRaw =
              await rootBundle.loadString('content/units/methods/$id.json');
          final unit = jsonDecode(unitRaw) as Map<String, dynamic>;
          final meta = Map<String, dynamic>.from(unit['meta'] as Map? ?? unit);
          byId[id] = Method.fromJson(meta);
          _methodUpdatedAt[id] = meta['updatedAt'] as String? ?? '';
        } catch (_) {
          byId[id] = Method.fromJson(map);
          _methodUpdatedAt[id] = map['updatedAt'] as String? ?? '';
        }
      }
    } catch (_) {}

    // 2) کشف همهٔ فایل‌های units/methods در باندل (حتی اگر در ایندکس نباشند)
    try {
      final manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final key in manifest.listAssets()) {
        if (!key.startsWith('content/units/methods/') ||
            !key.endsWith('.json')) {
          continue;
        }
        final id = key.split('/').last.replaceAll('.json', '');
        if (byId.containsKey(id)) continue;
        try {
          final unitRaw = await rootBundle.loadString(key);
          final unit = jsonDecode(unitRaw) as Map<String, dynamic>;
          final meta = Map<String, dynamic>.from(unit['meta'] as Map? ?? unit);
          if (!meta.containsKey('id')) meta['id'] = id;
          byId[id] = Method.fromJson(meta);
          _methodUpdatedAt[id] = meta['updatedAt'] as String? ?? '';
        } catch (_) {}
      }
    } catch (_) {}

    if (byId.isNotEmpty) return byId.values.toList();

    // 3) فال‌بک methods.json یک‌تکه
    try {
      final raw = await rootBundle.loadString('content/methods.json');
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Method.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Problem>> _loadProblemsMerged() async {
    final seed = await _loadProblemsSeed();
    final deleted = await LocalContentStore().loadDeletedProblemIds();
    final localUnits = await LocalContentStore().loadProblemUnits();

    final byId = <String, Problem>{};
    for (final p in seed) {
      if (deleted.contains(p.id)) continue;
      byId[p.id] = p;
    }

    for (final entry in localUnits.entries) {
      final id = entry.key;
      final unit = entry.value;
      byId[id] = Problem.fromJson(unit);
      _problemUpdatedAt[id] = unit['updatedAt'] as String? ?? '';
    }

    final list = byId.values.toList();
    list.sort((a, b) {
      final ua = _problemUpdatedAt[a.id] ?? '';
      final ub = _problemUpdatedAt[b.id] ?? '';
      if (ua.isNotEmpty || ub.isNotEmpty) {
        final c = ub.compareTo(ua);
        if (c != 0) return c;
      }
      return a.name.compareTo(b.name);
    });
    return list;
  }

  Future<List<Problem>> _loadProblemsSeed() async {
    final byId = <String, Problem>{};

    // 1) ایندکس + فایل واحد
    try {
      final indexRaw =
          await rootBundle.loadString('content/problems_index.json');
      final index = jsonDecode(indexRaw) as List;
      for (final item in index) {
        final id = '${(item as Map)['id']}';
        try {
          final unitRaw =
              await rootBundle.loadString('content/units/problems/$id.json');
          final map = jsonDecode(unitRaw) as Map<String, dynamic>;
          if (!map.containsKey('id')) map['id'] = id;
          byId[id] = Problem.fromJson(map);
          _problemUpdatedAt[id] = map['updatedAt'] as String? ?? '';
        } catch (_) {}
      }
    } catch (_) {}

    // 2) کشف همهٔ فایل‌های units/problems در باندل
    try {
      final manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final key in manifest.listAssets()) {
        if (!key.startsWith('content/units/problems/') ||
            !key.endsWith('.json')) {
          continue;
        }
        final fileName = key.split('/').last;
        final idGuess = fileName.replaceAll('.json', '');
        if (byId.containsKey(idGuess)) continue;
        try {
          final unitRaw = await rootBundle.loadString(key);
          final map = jsonDecode(unitRaw) as Map<String, dynamic>;
          final id = '${map['id'] ?? idGuess}';
          if (!map.containsKey('id')) map['id'] = id;
          byId[id] = Problem.fromJson(map);
          _problemUpdatedAt[id] = map['updatedAt'] as String? ?? '';
        } catch (_) {}
      }
    } catch (_) {}

    if (byId.isNotEmpty) return byId.values.toList();

    // 3) فال‌بک problems.json یک‌تکه
    try {
      final raw = await rootBundle.loadString('content/problems.json');
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Problem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  int nextMethodId() {
    var max = 0;
    for (final m in methods) {
      if (m.id > max) max = m.id;
    }
    return max + 1;
  }

  /// شمارهٔ بعدی برای مشکل جدید (مثل ابزارها: ۱، ۲، ۳ …)
  /// فقط idهای عددی را حساب می‌کند؛ slugهای انگلیسی نادیده گرفته می‌شوند.
  int nextProblemId() {
    var max = 0;
    for (final p in problems) {
      final n = int.tryParse(p.id);
      if (n != null && n > max) max = n;
    }
    // اگر همه slug بودند، از تعداد + ۱ شروع نکن؛ از ۱۰۰۱ تا با ابزارها قاطی نشود
    if (max == 0) return 1001;
    return max + 1;
  }

  List<Category> get categories => _categories ?? [];
  List<Method> get methods => _methods ?? [];
  List<Problem> get problems => _problems ?? [];
  List<ProblemCategory> get problemCategories => _problemCategories ?? [];
  List<ProblemCategory> get pinnedProblemCategories =>
      problemCategories.where((c) => c.pinned).toList();

  ProblemCategory? problemCategoryById(String id) {
    try {
      return problemCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Problem> problemsByCategory(String categoryId) {
    if (categoryId == 'all') return rankedProblems(problems);
    return rankedProblems(
      problems.where((p) => p.categoryId == categoryId).toList(),
    );
  }

  List<Map<String, dynamic>> get questions => _questions ?? [];
  Map<String, dynamic> get crisis => _crisis ?? {};
  List<Map<String, dynamic>> get sources => _sources ?? [];

  Method? methodById(int id) {
    try {
      return methods.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Category? categoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Problem? problemById(String id) {
    try {
      return problems.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Method> methodsByCategory(String categoryId) {
    if (categoryId == 'all') return rankedMethods(methods);
    return rankedMethods(
      methods.where((m) => m.categoryId == categoryId).toList(),
    );
  }

  List<Method> searchMethods(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return rankedMethods(methods);
    return rankedMethods(methods.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.description.toLowerCase().contains(q);
    }).toList());
  }

  /// ابزارهای شناخته‌شده / پرکاربرد جلوتر (نه بر اساس تازگی فایل)
  static const List<int> _popularMethodIds = [
    1, // پومودورو
    16, // SWOT
    36, // قورباغه
    39, // دو دقیقه
    35, // دیپ ورک
    42, // پارکینسون
    43, // شروع ۵ دقیقه
    5, // استرس
    8, // ذهنی
    46, // مدیریت انرژی
    50, // کانبان
    31, // satisficing
    27, // ترس
    38, // حذف حواس‌پرتی
    37, // بلوک زمانی
    11, 20, 9, 18, 14, 6, 3, 7, 4, 2,
  ];

  static const List<String> _popularProblemIds = [
    'job_burnout',
    'rumination',
    'chronic_procrastination',
    'anticipatory_anxiety',
    'anxiety_palpitations_and_choking',
    'decision_fatigue',
    'caregiver_burnout',
    'parental_burnout',
    'social_media_burnout',
    'anxious_attachment',
    'avoidant_attachment',
    'difficulty_starting_tasks',
    'analysis_paralysis',
    'emotional_eating',
    'feeling_stuck_in_life',
    'feeling_left_behind',
    'anger_burst',
    'compulsive_checking',
    'what_if_thoughts',
    'persistent_lethargy',
  ];

  static const List<String> _popularProblemCats = [
    'burnout',
    'storm',
    'intrusive',
    'impulse',
    'relation',
    'shame',
    'body_signal',
    'neuro',
    'cultural',
    'inner_world',
  ];

  int _methodRank(Method m) {
    final i = _popularMethodIds.indexOf(m.id);
    if (i >= 0) return i;
    // دسته‌های پرطرفدار بعد از لیست ثابت
    const catBoost = {
      'time': 100,
      'habit': 110,
      'stress': 120,
      'mental': 130,
      'self': 140,
      'dec': 150,
      'goal': 160,
      'rel': 170,
      'career': 180,
    };
    return 500 + (catBoost[m.categoryId] ?? 300) + m.id;
  }

  int _problemRank(Problem p) {
    final i = _popularProblemIds.indexOf(p.id);
    if (i >= 0) return i;
    final c = _popularProblemCats.indexOf(p.categoryId);
    if (c >= 0) return 100 + c;
    return 500 + p.name.hashCode.abs() % 200;
  }

  List<Method> rankedMethods([List<Method>? source]) {
    final list = List<Method>.from(source ?? methods);
    list.sort((a, b) => _methodRank(a).compareTo(_methodRank(b)));
    return list;
  }

  List<Problem> rankedProblems([List<Problem>? source]) {
    final list = List<Problem>.from(source ?? problems);
    list.sort((a, b) => _problemRank(a).compareTo(_problemRank(b)));
    return list;
  }
}
