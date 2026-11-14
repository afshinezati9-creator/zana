// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// دانلود خودکار فایل JSON در مرورگر (پوشه Downloads).
Future<bool> downloadContentFile(String filename, String contents) async {
  try {
    final bytes = utf8.encode(contents);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return true;
  } catch (_) {
    return false;
  }
}
