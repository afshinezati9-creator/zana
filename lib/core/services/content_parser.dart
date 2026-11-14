/// پارس قالب استاندارد اسلایدها برای تب مدیریت.
class ParsedSlide {
  final int n;
  final String title;
  final String body;

  const ParsedSlide({required this.n, required this.title, required this.body});

  Map<String, dynamic> toJson() => {'n': n, 'title': title, 'body': body};
}

class SlideParseResult {
  final List<ParsedSlide> slides;
  final List<String> errors;
  final List<String> warnings;

  const SlideParseResult({
    required this.slides,
    required this.errors,
    this.warnings = const [],
  });

  bool get ok => errors.isEmpty && slides.isNotEmpty;
}

class ContentParser {
  ContentParser._();

  static final _slideHeader = RegExp(
    r'^\s*SLIDE\s+(\d+)\s*\|\s*(.+?)\s*$',
    multiLine: true,
    caseSensitive: false,
  );

  static SlideParseResult parseSlides(
    String raw, {
    bool requireSourcesSlide = true,
    int minSlides = 1,
    int maxSlides = 100,
  }) {
    final text = raw.replaceAll('\r\n', '\n').trim();
    final errors = <String>[];
    final warnings = <String>[];

    if (text.isEmpty) {
      return const SlideParseResult(
        slides: [],
        errors: ['متن اسلایدها خالی است.'],
      );
    }

    if (text.contains('**')) {
      warnings.add(
          'علامت ** در متن هست؛ در نمایش اپ ممکن است خام دیده شود. بهتر است حذف شود.');
    }

    final matches = _slideHeader.allMatches(text).toList();
    if (matches.isEmpty) {
      return const SlideParseResult(
        slides: [],
        errors: [
          'هیچ اسلایدی پیدا نشد.\nهر اسلاید باید با این خط شروع شود:\nSLIDE 1 | عنوان اسلاید',
        ],
      );
    }

    final slides = <ParsedSlide>[];
    final seenN = <int>{};

    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      final n = int.tryParse(m.group(1)!) ?? (i + 1);
      final title = (m.group(2) ?? '').trim();
      final start = m.end;
      final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
      final body = text.substring(start, end).trim();

      if (seenN.contains(n)) {
        warnings.add('شماره اسلاید $n تکراری است.');
      }
      seenN.add(n);

      if (title.isEmpty) {
        errors.add('اسلاید $n عنوان ندارد.');
      }
      if (body.isEmpty) {
        errors.add('اسلاید $n متن خالی دارد.');
      }

      slides.add(ParsedSlide(
        n: n,
        title: title.isEmpty ? 'اسلاید $n' : title,
        body: body,
      ));
    }

    if (slides.length < minSlides) {
      errors.add('حداقل $minSlides اسلاید لازم است (الان ${slides.length}).');
    }
    if (slides.length > maxSlides) {
      errors.add('حداکثر $maxSlides اسلاید مجاز است (الان ${slides.length}).');
    }

    if (requireSourcesSlide && slides.isNotEmpty) {
      final last = slides.last.title;
      if (!last.contains('منابع') && !last.toLowerCase().contains('source')) {
        warnings.add(
            'اسلاید آخر عنوان «منابع علمی» ندارد. برای ابزارها اکیداً توصیه می‌شود.');
      }
    }

    if (slides.isEmpty) {
      errors.add('پس از پارس هیچ اسلاید معتبری نماند.');
    }

    return SlideParseResult(
      slides: slides,
      errors: errors,
      warnings: warnings,
    );
  }

  static String slidesToPasteText(List<dynamic> slides) {
    final buf = StringBuffer();
    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      if (s is! Map) continue;
      final n = s['n'] ?? (i + 1);
      final title = s['title'] ?? 'اسلاید $n';
      final body = s['body'] ?? '';
      if (i > 0) buf.writeln();
      buf.writeln('SLIDE $n | $title');
      buf.writeln(body);
    }
    return buf.toString().trim();
  }
}
