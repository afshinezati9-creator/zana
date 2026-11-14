import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/path_result.dart';
import '../../domain/entities/progress.dart';
import '../constants/app_constants.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._();
  factory ProgressService() => _instance;
  ProgressService._();

  SharedPreferences? _prefs;
  final Map<int, MethodProgress> _cache = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromDisk();
  }

  void _loadFromDisk() {
    final raw = _prefs?.getString(AppConstants.keyProgress);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map.forEach((key, value) {
        final id = int.tryParse(key);
        if (id != null && value is Map) {
          _cache[id] = MethodProgress.fromJson(Map<String, dynamic>.from(value));
        }
      });
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    final map = <String, dynamic>{};
    _cache.forEach((id, p) {
      map[id.toString()] = p.toJson();
    });
    await _prefs?.setString(AppConstants.keyProgress, jsonEncode(map));
  }

  MethodProgress getProgress(int methodId) {
    return _cache[methodId] ??
        MethodProgress(methodId: methodId, chaptersCompleted: 0);
  }

  int chaptersCompleted(int methodId) => getProgress(methodId).chaptersCompleted;

  bool isCompleted(int methodId) => getProgress(methodId).isCompleted;

  Future<void> updateChapter(int methodId, int chapterIndex) async {
    final current = getProgress(methodId);
    final newCompleted = chapterIndex + 1;
    if (newCompleted > current.chaptersCompleted) {
      _cache[methodId] = current.copyWith(
        chaptersCompleted: newCompleted,
        lastOpened: DateTime.now(),
      );
      await _saveToDisk();
    }
  }

  Future<void> markCompleted(int methodId) async {
    final current = getProgress(methodId);
    _cache[methodId] = current.copyWith(
      chaptersCompleted: AppConstants.chaptersPerMethod,
      isCompleted: true,
      lastOpened: DateTime.now(),
    );
    await _saveToDisk();
  }

  /// روش‌هایی که کاربر شروع کرده ولی کامل نکرده
  List<MethodProgress> get inProgressMethods {
    return _cache.values
        .where((p) => p.chaptersCompleted > 0 && !p.isCompleted)
        .toList()
      ..sort((a, b) => (b.lastOpened ?? DateTime(2000))
          .compareTo(a.lastOpened ?? DateTime(2000)));
  }

  /// ذخیرهٔ نتیجهٔ مسیر (نسخهٔ typed)
  Future<void> savePathResultEntity(PathResult result) async {
    await _prefs?.setString(
      AppConstants.keyPathResult,
      jsonEncode(result.toJson()),
    );
  }

  /// سازگاری با کد قدیمی که Map می‌فرستاد
  Future<void> savePathResult(Map<String, dynamic> result) async {
    try {
      final entity = PathResult.fromJson(result);
      await savePathResultEntity(entity);
    } catch (_) {
      await _prefs?.setString(AppConstants.keyPathResult, jsonEncode(result));
    }
  }

  PathResult? getPathResultEntity() {
    final raw = _prefs?.getString(AppConstants.keyPathResult);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return PathResult.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// سازگاری با PathScreen فعلی
  Map<String, dynamic>? getPathResult() {
    final entity = getPathResultEntity();
    if (entity != null) return entity.toJson();
    final raw = _prefs?.getString(AppConstants.keyPathResult);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearPathResult() async {
    await _prefs?.remove(AppConstants.keyPathResult);
  }

  bool get hasPathResult => getPathResultEntity() != null;

  bool isDarkMode() {
    return _prefs?.getBool(AppConstants.keyThemeMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(AppConstants.keyThemeMode, value);
  }

  /// مقیاس فونت: 0.85 · 1.0 · 1.15 · 1.3
  double fontScale() {
    return _prefs?.getDouble(AppConstants.keyFontScale) ?? 1.0;
  }

  Future<void> setFontScale(double value) async {
    await _prefs?.setDouble(AppConstants.keyFontScale, value);
  }

  List<int> getRecentMethodIds({int limit = 8}) {
    final raw = _prefs?.getString(AppConstants.keyRecent);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).map((e) => e as int).toList();
      return list.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addRecent(int methodId) async {
    final list = getRecentMethodIds(limit: 50);
    list.remove(methodId);
    list.insert(0, methodId);
    await _prefs?.setString(
      AppConstants.keyRecent,
      jsonEncode(list.take(20).toList()),
    );
  }

  List<int> getPinnedMethodIds() {
    final raw = _prefs?.getString(AppConstants.keyPinned);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  bool isPinned(int methodId) => getPinnedMethodIds().contains(methodId);

  Future<void> togglePin(int methodId) async {
    final list = getPinnedMethodIds();
    if (list.contains(methodId)) {
      list.remove(methodId);
    } else {
      list.insert(0, methodId);
    }
    await _prefs?.setString(AppConstants.keyPinned, jsonEncode(list));
  }

  /// پاک کردن پیشرفت، مسیر، بازدیدها و پین‌ها — بازگشت داشبورد به حالت اول
  Future<void> resetDashboard() async {
    _cache.clear();
    await _prefs?.remove(AppConstants.keyProgress);
    await _prefs?.remove(AppConstants.keyPathResult);
    await _prefs?.remove(AppConstants.keyRecent);
    await _prefs?.remove(AppConstants.keyPinned);
    await _prefs?.remove(AppConstants.keyPinnedProblems);
  }

  List<String> getPinnedProblemIds() {
    final raw = _prefs?.getString(AppConstants.keyPinnedProblems);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  bool isProblemPinned(String problemId) =>
      getPinnedProblemIds().contains(problemId);

  Future<void> toggleProblemPin(String problemId) async {
    final list = getPinnedProblemIds();
    if (list.contains(problemId)) {
      list.remove(problemId);
    } else {
      list.insert(0, problemId);
    }
    await _prefs?.setString(
      AppConstants.keyPinnedProblems,
      jsonEncode(list),
    );
  }
}
