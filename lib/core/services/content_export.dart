import 'dart:convert';

/// ساخت متن قابل کپی برای انتقال واحد محتوا به ریپو / فایل سیستم.
class ContentExport {
  ContentExport._();

  static String methodUnitPretty(Map<String, dynamic> unit) {
    return const JsonEncoder.withIndent('  ').convert(unit);
  }

  static String problemUnitPretty(Map<String, dynamic> unit) {
    return const JsonEncoder.withIndent('  ').convert(unit);
  }

  static String methodSeedPath(String id) =>
      'content/units/methods/$id.json';

  static String problemSeedPath(String id) =>
      'content/units/problems/$id.json';
}
