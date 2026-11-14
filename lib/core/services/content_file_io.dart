import 'content_file_io_stub.dart'
    if (dart.library.html) 'content_file_io_web.dart' as impl;

/// بعد از ذخیره در تب مدیریت، فایل JSON را برای قرار دادن در ریپو می‌دهد.
Future<bool> downloadContentFile(String filename, String contents) =>
    impl.downloadContentFile(filename, contents);
