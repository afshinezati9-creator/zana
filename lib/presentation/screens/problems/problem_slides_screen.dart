import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/local_content_store.dart';
import '../../../core/theme/zana_colors.dart';
import '../../../domain/entities/problem.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/rich_slide_body.dart';

class ProblemSlidesScreen extends ConsumerStatefulWidget {
  final String problemId;

  const ProblemSlidesScreen({super.key, required this.problemId});

  @override
  ConsumerState<ProblemSlidesScreen> createState() =>
      _ProblemSlidesScreenState();
}

class _ProblemSlide {
  final int n;
  final String title;
  final String body;

  const _ProblemSlide({
    required this.n,
    required this.title,
    required this.body,
  });
}

class _ProblemSlidesScreenState extends ConsumerState<ProblemSlidesScreen> {
  Problem? problem;
  List<_ProblemSlide> slides = [];
  int current = 0;
  bool loading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = ContentService().problemById(widget.problemId);
    if (p == null) {
      setState(() {
        loading = false;
        loadError = 'این مشکل پیدا نشد.';
      });
      return;
    }
    problem = p;

    // ۱) حافظه محلی
    final local = await LocalContentStore().getProblemUnit(widget.problemId);
    var rawSlides = local?['slides'];

    // ۲) فایل دارایی
    if (rawSlides is! List || rawSlides.isEmpty) {
      try {
        final s = await rootBundle
            .loadString('content/units/problems/${widget.problemId}.json');
        final map = jsonDecode(s) as Map<String, dynamic>;
        rawSlides = map['slides'];
      } catch (_) {}
    }

    final list = <_ProblemSlide>[];
    if (rawSlides is List && rawSlides.isNotEmpty) {
      for (var i = 0; i < rawSlides.length; i++) {
        final m = Map<String, dynamic>.from(rawSlides[i] as Map);
        list.add(_ProblemSlide(
          n: m['n'] as int? ?? (i + 1),
          title: (m['title'] as String?)?.trim() ?? 'اسلاید ${i + 1}',
          body: (m['body'] as String?)?.trim() ?? '',
        ));
      }
    }

    // فال‌بک: فقط متن what به‌عنوان یک اسلاید
    if (list.isEmpty && p.what.isNotEmpty) {
      list.add(_ProblemSlide(n: 1, title: 'این چیست؟', body: p.what));
    }

    setState(() {
      slides = list;
      loading = false;
      if (list.isEmpty) {
        loadError =
            'برای این مشکل اسلایدی ثبت نشده. از تب مدیریت دوباره ذخیره کن.';
      }
    });
  }

  void _next() {
    if (current < slides.length - 1) {
      setState(() => current++);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (current > 0) setState(() => current--);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.problems, isDark: isDark);

    if (loading) {
      return Scaffold(
        backgroundColor: palette.background,
        body: Center(child: CircularProgressIndicator(color: palette.primary)),
      );
    }

    if (loadError != null || problem == null || slides.isEmpty) {
      return Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          title: Text(problem?.name ?? 'مشکل'),
          backgroundColor: palette.surface,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              loadError ?? 'اسلایدی نیست',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.text, height: 1.6),
            ),
          ),
        ),
      );
    }

    final slide = slides[current];
    final isLast = current == slides.length - 1;

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 12,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(bottom: BorderSide(color: palette.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_forward, color: palette.primary),
                      label: Text('بازگشت',
                          style: TextStyle(color: palette.primary)),
                    ),
                    const Spacer(),
                    Builder(builder: (context) {
                      final prog = ProgressService();
                      final pinned = prog.isProblemPinned(widget.problemId);
                      return IconButton(
                        tooltip: pinned ? 'برداشتن پین' : 'پین کردن',
                        onPressed: () async {
                          final wasPinned = prog.isProblemPinned(widget.problemId);
                          await prog.toggleProblemPin(widget.problemId);
                          if (!mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                wasPinned
                                    ? 'پین این مطلب برداشته شد'
                                    : 'این مطلب پین شد — در خانه می‌بینی',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(
                          pinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          color: pinned ? palette.primary : palette.muted,
                        ),
                      );
                    }),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        problem!.categoryId,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  problem!.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'متن بر پایه منابع معتبر؛ جایگزین تشخیص یا درمان نیست.',
                  style: TextStyle(fontSize: 11, color: palette.muted),
                ),
              ],
            ),
          ),
          // نقاط اسلاید — اسکرول افقی
          if (slides.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: SizedBox(
                height: 18,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: slides.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final active = i == current;
                    return GestureDetector(
                      onTap: () => setState(() => current = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? palette.primary
                              : palette.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'اسلاید ${slide.n} از ${slides.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: palette.text,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    RichSlideBody(
                      text: slide.body,
                      palette: palette,
                      fontSize: 14.5,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.primarySoft.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'زانا تشخیص نمی‌دهد و جایگزین درمانگر نیست.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  if (current > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prev,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.primary,
                          side: BorderSide(color: palette.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('قبلی'),
                      ),
                    ),
                  if (current > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(isLast ? 'پایان' : 'بعدی'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
