import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../../domain/entities/problem.dart';
import '../../../domain/entities/problem_category.dart';
import '../../providers/app_state_provider.dart';
import 'problem_slides_screen.dart';
import '../../widgets/inset_h_scroll.dart';

class ProblemsScreen extends ConsumerStatefulWidget {
  const ProblemsScreen({super.key});

  @override
  ConsumerState<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends ConsumerState<ProblemsScreen> {
  String _filter = 'all';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    ref.watch(contentRevisionProvider);

    final tab = ref.watch(currentTabProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(tab, isDark: isDark);
    final content = ContentService();
    final cats = content.problemCategories;
    final pinned = content.pinnedProblemCategories;
    final q = _query.trim().toLowerCase();
    var problems = _filter == 'all'
        ? content.rankedProblems()
        : content.problemsByCategory(_filter);
    if (q.isNotEmpty) {
      problems = content.rankedProblems(problems.where((p) {
        final cat = content.problemCategoryById(p.categoryId);
        final blob = [
          p.name,
          p.what,
          p.common,
          p.honest,
          ...p.signs,
          ...p.examples,
          cat?.name ?? '',
          cat?.description ?? '',
        ].join(' ').toLowerCase();
        return blob.contains(q);
      }).toList());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'مشکلات',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: palette.text,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اینجا برای شناخت تجربه است، نه تشخیص. زانا جایگزین روان‌شناس یا روان‌پزشک نیست.',
          style: TextStyle(fontSize: 13.5, color: palette.muted, height: 1.65),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'جستجو در نام، نشانه، دسته...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: palette.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        if (pinned.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'دسته‌های پین‌شده',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: pinned.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = pinned[i];
                final selected = _filter == c.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _filter = selected ? 'all' : c.id;
                  }),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? c.color.withValues(alpha: 0.25)
                          : palette.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? c.color : palette.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.push_pin_rounded,
                                size: 14, color: c.color),
                            const SizedBox(width: 4),
                            if (c.adult)
                              const Text(
                                '۱۸+',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: ZanaColors.danger,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            c.name,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: palette.text,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 14),
        InsetHScroll(
          palette: palette,
          height: 56,
          outerPadding: EdgeInsets.zero,
          children: [
            _CatChip(
              label: 'همه',
              selected: _filter == 'all',
              color: palette.primary,
              onTap: () => setState(() => _filter = 'all'),
            ),
            ...cats.map((c) => _CatChip(
                  label: c.name,
                  selected: _filter == c.id,
                  color: c.color,
                  onTap: () => setState(() => _filter = c.id),
                )),
          ],
        ),
        const SizedBox(height: 16),
        if (problems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              q.isNotEmpty
              ? 'چیزی با این جستجو پیدا نشد. کلمه دیگری امتحان کن.'
              : 'در این دسته هنوز مدخلی نیست. به‌زودی کامل می‌شود.',
              style: TextStyle(color: palette.muted, fontSize: 13.5),
            ),
          )
        else
          ...problems.map((p) {
            final cat = content.problemCategoryById(p.categoryId);
            return _ProblemCard(
              problem: p,
              category: cat,
              palette: palette,
              pinned: ProgressService().isProblemPinned(p.id),
              onPin: () async {
                final was = ProgressService().isProblemPinned(p.id);
                await ProgressService().toggleProblemPin(p.id);
                setState(() {});
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      was ? 'پین برداشته شد' : 'پین شد — در داشبورد خانه می‌آید',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onTap: () async {
                if (p.isAdult) {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('محتوای ۱۸+'),
                      content: const Text(
                        'این بخش فقط برای بزرگسالان است و با زبان بالینی درباره الگوهای حساس صحبت می‌کند. آیا ۱۸ سال یا بیشتر داری و می‌خواهی ادامه دهی؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('خیر'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('بله، ادامه'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true || !context.mounted) return;
                }
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProblemSlidesScreen(problemId: p.id),
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: selected ? color.withValues(alpha: 0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? color : color.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? color : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final Problem problem;
  final ProblemCategory? category;
  final ZanaPalette palette;
  final VoidCallback onTap;
  final bool pinned;
  final VoidCallback onPin;

  const _ProblemCard({
    required this.problem,
    required this.category,
    required this.palette,
    required this.onTap,
    required this.pinned,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final accent = category?.color ?? palette.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.favorite_rounded,
                          size: 18, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            problem.name,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: palette.text,
                            ),
                          ),
                          if (category != null)
                            Text(
                              category!.name,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: pinned ? 'برداشتن پین' : 'پین کردن',
                      onPressed: onPin,
                      icon: Icon(
                        pinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 20,
                        color: pinned ? palette.primary : palette.muted,
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded, color: palette.muted),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      label: problem.severityLabel,
                      palette: palette,
                      color: problem.severity == Severity.urgent
                          ? ZanaColors.danger
                          : accent,
                    ),
                    if (problem.crisisRequired)
                      _Chip(
                        label: 'ارجاع فوری',
                        palette: palette,
                        color: ZanaColors.danger,
                      ),
                    _Chip(
                      label: problem.sourceCount > 0
                          ? '${problem.sourceCount} منبع'
                          : 'منبع در حال تکمیل',
                      palette: palette,
                    ),
                    if (problem.isAdult)
                      _Chip(
                        label: '۱۸+',
                        palette: palette,
                        color: ZanaColors.danger,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final ZanaPalette palette;
  final Color? color;

  const _Chip({required this.label, required this.palette, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? palette.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c,
        ),
      ),
    );
  }
}
