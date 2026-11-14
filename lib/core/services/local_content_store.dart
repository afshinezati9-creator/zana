import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// ذخیرهٔ محلی ابزار/مشکل ساخته یا ویرایش‌شده در تب مدیریت.
/// روی وب و موبایل با SharedPreferences کار می‌کند (قابل حذف در انتشار نهایی).
class LocalContentStore {
  static final LocalContentStore _instance = LocalContentStore._();
  factory LocalContentStore() => _instance;
  LocalContentStore._();

  static const _kMethodUnits = 'zana_local_method_units_v1';
  static const _kProblemUnits = 'zana_local_problem_units_v1';
  static const _kDeletedMethods = 'zana_deleted_methods_v1';
  static const _kDeletedProblems = 'zana_deleted_problems_v1';

  SharedPreferences? _prefs;

  Future<void> ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Map<String, Map<String, dynamic>>> loadMethodUnits() async {
    await ensureReady();
    final raw = _prefs!.getString(_kMethodUnits);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  Future<Map<String, Map<String, dynamic>>> loadProblemUnits() async {
    await ensureReady();
    final raw = _prefs!.getString(_kProblemUnits);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  Future<Set<String>> loadDeletedMethodIds() async {
    await ensureReady();
    return (_prefs!.getStringList(_kDeletedMethods) ?? []).toSet();
  }

  Future<Set<String>> loadDeletedProblemIds() async {
    await ensureReady();
    return (_prefs!.getStringList(_kDeletedProblems) ?? []).toSet();
  }

  Future<void> saveMethodUnit(String id, Map<String, dynamic> unit) async {
    await ensureReady();
    final all = await loadMethodUnits();
    all[id] = unit;
    final deleted = await loadDeletedMethodIds();
    deleted.remove(id);
    await _prefs!.setString(_kMethodUnits, jsonEncode(all));
    await _prefs!.setStringList(_kDeletedMethods, deleted.toList());
  }

  Future<void> saveProblemUnit(String id, Map<String, dynamic> unit) async {
    await ensureReady();
    final all = await loadProblemUnits();
    all[id] = unit;
    final deleted = await loadDeletedProblemIds();
    deleted.remove(id);
    await _prefs!.setString(_kProblemUnits, jsonEncode(all));
    await _prefs!.setStringList(_kDeletedProblems, deleted.toList());
  }

  Future<void> deleteMethod(String id) async {
    await ensureReady();
    final all = await loadMethodUnits();
    all.remove(id);
    final deleted = await loadDeletedMethodIds();
    deleted.add(id);
    await _prefs!.setString(_kMethodUnits, jsonEncode(all));
    await _prefs!.setStringList(_kDeletedMethods, deleted.toList());
  }

  Future<void> deleteProblem(String id) async {
    await ensureReady();
    final all = await loadProblemUnits();
    all.remove(id);
    final deleted = await loadDeletedProblemIds();
    deleted.add(id);
    await _prefs!.setString(_kProblemUnits, jsonEncode(all));
    await _prefs!.setStringList(_kDeletedProblems, deleted.toList());
  }

  Future<Map<String, dynamic>?> getMethodUnit(String id) async {
    final all = await loadMethodUnits();
    return all[id];
  }

  Future<Map<String, dynamic>?> getProblemUnit(String id) async {
    final all = await loadProblemUnits();
    return all[id];
  }
}
