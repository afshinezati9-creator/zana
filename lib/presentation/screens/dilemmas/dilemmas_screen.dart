import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/zana_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/rich_slide_body.dart';

class DilemmasScreen extends ConsumerStatefulWidget {
  final int? initialId;
  const DilemmasScreen({super.key, this.initialId});

  @override
  ConsumerState<DilemmasScreen> createState() => _DilemmasScreenState();
}

class _DilemmasScreenState extends ConsumerState<DilemmasScreen> {
  List<Map<String, dynamic>> items = [];
  int? openId;
  int slide = 0;

  @override
  void initState() {
    super.initState();
    openId = widget.initialId;
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('content/dilemmas.json');
      final list = (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() => items = list);
    } catch (_) {
      setState(() => items = []);
    }
  }

  Map<String, dynamic>? _byId(int id) {
    for (final e in items) {
      if (e['id'] == id) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.home, isDark: isDark);

    if (openId != null) {
      final d = _byId(openId!);
      if (d == null) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(title: const Text('دوراهی‌های اخلاقی و چالش‌برانگیز')),
          body: const Center(child: Text('مورد پیدا نشد')),
        );
      }
      final slides = (d['slides'] as List?) ?? [];
      final s = slides.isNotEmpty
          ? Map<String, dynamic>.from(slides[slide.clamp(0, slides.length - 1)] as Map)
          : <String, dynamic>{
              'title': '',
              'body': d['challenge'] ?? d['blurb'] ?? '',
            };

      return Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          backgroundColor: palette.surface,
          title: Text(d['title'] as String? ?? 'دوراهی'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => setState(() {
              openId = null;
              slide = 0;
            }),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _Seg(
                    label: 'این چالش چیست؟',
                    active: slide == 0,
                    palette: palette,
                    onTap: () => setState(() => slide = 0),
                  ),
                  const SizedBox(width: 8),
                  _Seg(
                    label: 'چرا مطرح شده؟',
                    active: slide == 1,
                    palette: palette,
                    onTap: () => setState(() => slide = 1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if ((d['en'] as String?)?.isNotEmpty == true)
                    Text(
                      d['en'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    s['title'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.border),
                    ),
                    child: RichSlideBody(
                      text: s['body'] as String? ?? '',
                      palette: palette,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'این‌ها ابزار فکرند، نه حکم نهایی. هدف دیدن زاویه‌های مختلف یک انتخاب سخت است.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: palette.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        title: const Text('دوراهی‌های اخلاقی و چالش‌برانگیز'),
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = items[i];
                return Material(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() {
                      openId = d['id'] as int;
                      slide = 0;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  palette.primary.withValues(alpha: 0.2),
                                  palette.primary.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${d['id']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: palette.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['title'] as String? ?? '',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: palette.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d['blurb'] as String? ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.45,
                                    color: palette.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_left, color: palette.muted),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool active;
  final ZanaPalette palette;
  final VoidCallback onTap;
  const _Seg({
    required this.label,
    required this.active,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: active
            ? palette.primary.withValues(alpha: 0.15)
            : palette.surface2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? palette.primaryDark : palette.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
