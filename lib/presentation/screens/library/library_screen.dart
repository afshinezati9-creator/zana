import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../../domain/entities/method.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/inset_h_scroll.dart';
import '../method_journey/method_journey_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _search = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    ref.watch(contentRevisionProvider);

    final tab = ref.watch(currentTabProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(tab, isDark: isDark);
    final content = ContentService();
    final progress = ProgressService();

    var methods = _filter == 'all'
        ? content.rankedMethods()
        : content.methodsByCategory(_filter);
    if (_search.trim().isNotEmpty) {
      methods = content.searchMethods(_search);
      if (_filter != 'all') {
        methods = content.rankedMethods(
          methods.where((m) => m.categoryId == _filter).toList(),
        );
      }
    }

    return Column(
      children: [
        // جستجو
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: TextStyle(color: palette.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'جستجو در روش‌ها...',
              hintStyle: TextStyle(color: palette.muted),
              prefixIcon: Icon(Icons.search_rounded, color: palette.muted, size: 20),
              filled: true,
              fillColor: palette.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: palette.primary, width: 1.5),
              ),
            ),
          ),
        ),

        // فیلتر دسته‌ها — داخل کارت با فاصله از لبه
        InsetHScroll(
          palette: palette,
          height: 56,
          children: [
            _FilterPill(
              label: 'همه',
              active: _filter == 'all',
              palette: palette,
              onTap: () => setState(() => _filter = 'all'),
            ),
            ...content.categories.map((c) => _FilterPill(
                  label: c.name,
                  active: _filter == c.id,
                  palette: palette,
                  onTap: () => setState(() => _filter = c.id),
                )),
          ],
        ),

        const SizedBox(height: 8),

        // لیست
        Expanded(
          child: methods.isEmpty
              ? Center(
                  child: Text(
                    'روش‌ای پیدا نشد',
                    style: TextStyle(color: palette.muted, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: methods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, i) {
                    final m = methods[i];
                    final p = progress.getProgress(m.id);
                    final cat = content.categoryById(m.categoryId);
                    return _MethodItem(
                      method: m,
                      categoryName: cat?.name ?? '',
                      chaptersDone: p.chaptersCompleted,
                      isDone: p.isCompleted,
                      palette: palette,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final ZanaPalette palette;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: active ? palette.primary : palette.surface,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: active ? palette.primary : palette.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : palette.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodItem extends StatelessWidget {
  final Method method;
  final String categoryName;
  final int chaptersDone;
  final bool isDone;
  final ZanaPalette palette;

  const _MethodItem({
    required this.method,
    required this.categoryName,
    required this.chaptersDone,
    required this.isDone,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MethodJourneyScreen(methodId: method.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 16,
                      color: palette.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: palette.text,
                          ),
                        ),
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: palette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDone)
                    Icon(Icons.check_circle_rounded,
                        color: ZanaColors.success, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                method.description,
                style: TextStyle(
                  fontSize: 12.5,
                  color: palette.muted,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  _Chip(label: method.time, palette: palette),
                  if (method.isAdult)
                    _Chip(label: '۱۸+', palette: palette, danger: true),
                  if (chaptersDone > 0 && !isDone)
                    _Chip(
                      label: '$chaptersDone اسلاید',
                      palette: palette,
                      primary: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final ZanaPalette palette;
  final bool primary;
  final bool danger;

  const _Chip({
    required this.label,
    required this.palette,
    this.primary = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = palette.surface2;
    Color fg = palette.muted;
    if (primary) {
      bg = palette.primarySoft;
      fg = palette.primaryDark;
    }
    if (danger) {
      bg = const Color(0xFFFBE4DD);
      fg = const Color(0xFFE07856);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
