import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../../domain/entities/method.dart';
import '../../../domain/entities/problem.dart';
import '../../../domain/entities/path_result.dart';
import '../../providers/app_state_provider.dart';
import '../method_journey/method_journey_screen.dart';
import '../problems/problem_slides_screen.dart';
import '../sources/sources_screen.dart';
import '../dilemmas/dilemmas_screen.dart';
import '../../widgets/inset_h_scroll.dart';


IconData _iconForMethod(Method m) {
  switch (m.categoryId) {
    case 'time':
      return Icons.timer_outlined;
    case 'habit':
      return Icons.repeat_rounded;
    case 'stress':
      return Icons.spa_outlined;
    case 'mental':
    case 'mind':
      return Icons.psychology_alt_outlined;
    case 'self':
      return Icons.person_outline_rounded;
    case 'rel':
      return Icons.people_outline_rounded;
    case 'goal':
      return Icons.flag_outlined;
    case 'career':
      return Icons.work_outline_rounded;
    case 'dec':
      return Icons.balance_outlined;
    default:
      return Icons.lightbulb_outline_rounded;
  }
}

List<Method> _trendingMethods(List<Method> all) {
  if (all.isEmpty) return const [];
  const prefer = ['time', 'habit', 'stress', 'mental', 'self', 'dec', 'goal'];
  final picked = <Method>[];
  final seen = <int>{};
  for (final cat in prefer) {
    for (final m in all) {
      if (m.categoryId == cat && seen.add(m.id)) {
        picked.add(m);
        if (picked.length >= 8) return picked;
      }
    }
  }
  for (final m in all) {
    if (seen.add(m.id)) {
      picked.add(m);
      if (picked.length >= 8) break;
    }
  }
  return picked;
}

List<Problem> _commonProblems(List<Problem> problems) {
  if (problems.isEmpty) return const [];
  const preferCats = [
    'burnout',
    'storm',
    'intrusive',
    'relation',
    'impulse',
    'shame',
    'body_signal',
  ];
  final picked = <Problem>[];
  final seen = <String>{};
  for (final cat in preferCats) {
    for (final p in problems) {
      if (p.categoryId == cat && seen.add(p.id)) {
        picked.add(p);
        if (picked.length >= 10) return picked;
      }
    }
  }
  for (final p in problems) {
    if (seen.add(p.id)) {
      picked.add(p);
      if (picked.length >= 10) break;
    }
  }
  return picked;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(tab, isDark: isDark);
    final content = ContentService();
    final progress = ProgressService();
    final inProgress = progress.inProgressMethods;
    final methods = content.methods;
    final pathResult = ref.watch(pathResultProvider);
    ref.watch(pathRevisionProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // خوش‌آمدگویی
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: palette.headerGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خوش آمدی به زانا',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اینجا برای معجزه نیستیم؛ برای یک قدم کوچک و واقعی. ابزار بخوان، با بحران‌هایت آشناتر شو، از همان‌جایی که رها کردی ادامه بده.',
                  style: TextStyle(
                    fontSize: 13.2,
                    height: 1.65,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ),

        // مسیر اخیر
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _PathHomeCard(
            result: pathResult,
            palette: palette,
            onOpen: () =>
                ref.read(currentTabProvider.notifier).state = ZanaTab.path,
            onDelete: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('حذف نتیجه مسیر؟'),
                  content: const Text(
                    'خلاصه مسیر از خانه پاک می‌شود. هر وقت خواستی دوباره از تب مسیر شروع کن.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('انصراف'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ProgressService().clearPathResult();
                ref.read(pathRevisionProvider.notifier).state++;
              }
            },
          ),
        ),

        // رها شده‌ها — ادامه از همان‌جا
        if (inProgress.isNotEmpty) ...[
          _SectionTitle(title: 'رها شده‌ها · ادامه بده', palette: palette),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: inProgress.length.clamp(0, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final pr = inProgress[i];
                final m = content.methodById(pr.methodId);
                if (m == null) return const SizedBox.shrink();
                final pct = (pr.chaptersCompleted / 7).clamp(0.0, 1.0);
                return _ResumeCard(
                  title: m.title,
                  subtitle:
                      'فصل ${pr.chaptersCompleted} از ۷ · از همین‌جا ادامه بده',
                  progress: pct,
                  palette: palette,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MethodJourneyScreen(methodId: m.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],

        // تازه‌های بازدید
        if (progress.getRecentMethodIds().isNotEmpty) ...[
          _SectionTitle(title: 'تازه‌ترین بازدیدها', palette: palette),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: progress.getRecentMethodIds().length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final id = progress.getRecentMethodIds()[i];
                final m = content.methodById(id);
                if (m == null) return const SizedBox.shrink();
                final done = progress.chaptersCompleted(id);
                final sub = done > 0 && done < 7
                    ? 'نیمه‌کاره · فصل $done'
                    : m.time;
                return _SmallMethodCard(
                  title: m.title,
                  subtitle: sub,
                  icon: Icons.schedule_rounded,
                  palette: palette,
                  accent: const Color(0xFF5B8DEF),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MethodJourneyScreen(methodId: m.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],

        // پین‌شده
        if (progress.getPinnedMethodIds().isNotEmpty) ...[
          _SectionTitle(title: 'پین‌شده‌ها', palette: palette),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: progress.getPinnedMethodIds().length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final id = progress.getPinnedMethodIds()[i];
                final m = content.methodById(id);
                if (m == null) return const SizedBox.shrink();
                return _SmallMethodCard(
                  title: m.title,
                  subtitle: 'پین شده',
                  icon: Icons.bookmark_rounded,
                  palette: palette,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MethodJourneyScreen(methodId: m.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],

        // ابزارهای معروف / ترند (کتابخانه)
                // پین مشکلات
        if (progress.getPinnedProblemIds().isNotEmpty) ...[
          _SectionTitle(title: 'پین مشکلات', subtitle: 'برای بازگشت سریع', palette: palette),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: progress.getPinnedProblemIds().length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final id = progress.getPinnedProblemIds()[i];
                final pr = content.problemById(id);
                if (pr == null) return const SizedBox.shrink();
                return _SmallMethodCard(
                  title: pr.name,
                  subtitle: 'پین شده',
                  icon: Icons.push_pin_rounded,
                  palette: palette,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProblemSlidesScreen(problemId: pr.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],

_SectionTitle(
          title: 'ابزارهای پیشنهادی',
          subtitle: 'از کتابخانه',
          palette: palette,
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _trendingMethods(methods).length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final m = _trendingMethods(methods)[i];
              return _FeaturedCard(
                method: m,
                icon: _iconForMethod(m),
                palette: palette,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MethodJourneyScreen(methodId: m.id),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // بحران‌های رایج (مشکلات)
        _SectionTitle(
          title: 'بحران‌های رایج',
          subtitle: 'از بخش مشکلات',
          palette: palette,
        ),
        SizedBox(
          height: 158,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _commonProblems(content.problems).length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final p = _commonProblems(content.problems)[i];
              return _ProblemMini(
                name: p.name,
                what: p.what.isNotEmpty ? p.what : 'مطالعه الگو · نه تشخیص',
                palette: palette,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProblemSlidesScreen(problemId: p.id),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // دسته‌بندی کتابخانه
        _SectionTitle(
          title: 'دسته‌های کتابخانه',
          subtitle: 'ابزارها و روش‌ها',
          palette: palette,
        ),
        InsetHScroll(
          palette: palette,
          height: 52,
          children: content.categories.map((cat) {
            return ActionChip(
              avatar: Icon(Icons.menu_book_rounded,
                  size: 16, color: palette.primaryDark),
              label: Text(cat.name),
              onPressed: () {
                ref.read(currentTabProvider.notifier).state = ZanaTab.library;
              },
              backgroundColor: palette.surface2,
              side: BorderSide(color: palette.border),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            );
          }).toList(),
        ),

        // دسته‌بندی مشکلات
        _SectionTitle(
          title: 'دسته‌های مشکلات',
          subtitle: 'الگوهای قابل‌مطالعه',
          palette: palette,
        ),
        InsetHScroll(
          palette: palette,
          height: 52,
          children: content.problemCategories.map((cat) {
            return ActionChip(
              avatar: Icon(Icons.favorite_border_rounded,
                  size: 16, color: palette.accentDark),
              label: Text(cat.name),
              onPressed: () {
                ref.read(currentTabProvider.notifier).state = ZanaTab.problems;
              },
              backgroundColor: palette.surface2,
              side: BorderSide(color: palette.border),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            );
          }).toList(),
        ),

        // بنر دوراهی‌های اخلاقی
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DilemmasScreen()),
                );
              },
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      palette.primaryDark,
                      palette.primary,
                      palette.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.balance_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'دوراهی‌های اخلاقی و چالش‌برانگیز',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left,
                        color: Colors.white.withValues(alpha: 0.9), size: 28),
                  ],
                ),
              ),
            ),
          ),
        ),


        _SectionTitle(title: 'منابع علمی معتبر', palette: palette),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SourcesScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        color: palette.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_book_rounded,
                          color: palette.primaryDark, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'انجمن‌ها و نهادهای معتبر',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: palette.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'بیش از سی منبع داخلی و بین‌المللی با لینک مستقیم',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded, color: palette.muted),
                  ],
                ),
              ),
            ),
          ),
        ),

        // دسترسی سریع
        _SectionTitle(title: 'دسترسی سریع', palette: palette),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              _QuickTile(
                icon: Icons.explore_rounded,
                title: 'مسیر من',
                subtitle: 'مصاحبه کوتاه',
                palette: palette,
                onTap: () =>
                    ref.read(currentTabProvider.notifier).state = ZanaTab.path,
              ),
              _QuickTile(
                icon: Icons.priority_high_rounded,
                title: 'کمک فوری',
                subtitle: 'خطوط بحران',
                palette: palette,
                isDanger: true,
                onTap: () =>
                    ref.read(crisisModalOpenProvider.notifier).state = true,
              ),
              _QuickTile(
                icon: Icons.menu_book_rounded,
                title: 'کتابخانه',
                subtitle: 'همه روش‌ها',
                palette: palette,
                onTap: () =>
                    ref.read(currentTabProvider.notifier).state = ZanaTab.library,
              ),
              _QuickTile(
                icon: Icons.info_rounded,
                title: 'درباره',
                subtitle: 'چرا زانا؟',
                palette: palette,
                onTap: () =>
                    ref.read(currentTabProvider.notifier).state = ZanaTab.about,
              ),
            ],
          ),
        ),

        // ریست داشبورد
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('بازنشانی داشبورد؟'),
                  content: const Text(
                    'پیشرفت ابزارها، نتیجه مسیر، بازدیدهای اخیر و پین ها پاک می شود و خانه به حالت اول برمی گردد. تم و اندازه فونت عوض نمی شود.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('انصراف'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('بازنشانی'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ProgressService().resetDashboard();
                ref.read(pathRevisionProvider.notifier).state++;
              }
            },
            icon: Icon(Icons.restart_alt_rounded, color: palette.muted, size: 18),
            label: Text(
              'بازنشانی کامل داشبورد',
              style: TextStyle(
                color: palette.muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: palette.border),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ZanaPalette palette;
  const _SectionTitle({
    required this.title,
    required this.palette,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.text,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11.5,
                color: palette.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _PathHomeCard extends StatelessWidget {
  final PathResult? result;
  final ZanaPalette palette;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _PathHomeCard({
    required this.result,
    required this.palette,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final has = result != null;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: has
                  ? palette.primary.withValues(alpha: 0.35)
                  : palette.border,
            ),
            gradient: has
                ? LinearGradient(
                    colors: [
                      palette.primary.withValues(alpha: 0.08),
                      palette.surface,
                    ],
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: has
                      ? palette.primary.withValues(alpha: 0.15)
                      : palette.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  has
                      ? (result!.crisis
                          ? Icons.health_and_safety_rounded
                          : Icons.explore_rounded)
                      : Icons.explore_outlined,
                  color: has ? palette.primaryDark : palette.muted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      has
                          ? (result!.crisis
                              ? 'مسیر · کمک فوری پیشنهاد شد'
                              : 'مسیر اخیر تو')
                          : 'مسیر آگاهی',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      has
                          ? result!.summaryLine
                          : 'چند سؤال کوتاه تا ببینی الان بیشتر با چه الگویی طرفی — بدون تشخیص پزشکی.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: palette.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          has ? 'مشاهده نتیجه' : 'شروع مسیر',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: palette.primaryDark,
                          ),
                        ),
                        if (has) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: onDelete,
                            child: Text(
                              'حذف',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: palette.muted),
            ],
          ),
        ),
      ),
    );
  }
}


class _ResumeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final ZanaPalette palette;
  final VoidCallback onTap;

  const _ResumeCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 210,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: palette.muted,
                  height: 1.35,
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: palette.surface2,
                  valueColor: AlwaysStoppedAnimation(palette.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _FeaturedCard extends StatelessWidget {
  final Method method;
  final ZanaPalette palette;
  final VoidCallback onTap;
  final IconData icon;

  const _FeaturedCard({
    required this.method,
    required this.palette,
    required this.onTap,
    this.icon = Icons.lightbulb_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 180,
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: palette.headerGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  method.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: palette.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ProblemMini extends StatelessWidget {
  final String name;
  final String what;
  final ZanaPalette palette;
  final VoidCallback onTap;

  const _ProblemMini({
    required this.name,
    required this.what,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 148,
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.favorite_rounded, size: 16, color: palette.accentDark),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              what,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: palette.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ZanaPalette palette;
  final VoidCallback onTap;
  final bool isDanger;

  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDanger
                      ? const Color(0xFFFBE4DD)
                      : palette.primarySoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: isDanger
                      ? const Color(0xFFE07856)
                      : palette.primaryDark,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: palette.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ZanaPalette palette;
  final VoidCallback onTap;
  final Color? accent;

  const _SmallMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.palette,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent ?? palette.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 158,
        height: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: a.withValues(alpha: 0.28)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              a.withValues(alpha: 0.12),
              palette.surface,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: a.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: a.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: a),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w800,
                  color: palette.text,
                  height: 1.25,
                ),
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: palette.muted),
            ),
          ],
        ),
      ),
    );
  }
}
