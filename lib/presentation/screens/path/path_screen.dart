import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/path_mapping.dart';
import '../../../core/services/path_tree.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../../domain/entities/method.dart';
import '../../../domain/entities/path_result.dart';
import '../../../domain/entities/problem.dart';
import '../../providers/app_state_provider.dart';
import '../method_journey/method_journey_screen.dart';
import '../problems/problem_slides_screen.dart';

class PathScreen extends ConsumerStatefulWidget {
  const PathScreen({super.key});

  @override
  ConsumerState<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends ConsumerState<PathScreen> {
  /// -1 = معرفی · 0..4 = Q1..Q5 · 5 = نتیجه
  int _stepIndex = -1;
  final Map<String, String> _answers = {};
  final List<String> _pathNodes = ['Q0'];
  PathResult? _result;
  bool _crisis = false;

  @override
  void initState() {
    super.initState();
    final saved = ProgressService().getPathResultEntity();
    if (saved != null && !saved.crisis) {
      _result = saved;
      _answers.addAll(saved.answers);
      _stepIndex = 5;
    } else if (saved != null && saved.crisis) {
      _result = saved;
      _crisis = true;
      _stepIndex = 5;
    }
  }

  String get _currentNodeId {
    if (_stepIndex < 0) return 'Q0';
    if (_stepIndex >= PathTree.stepOrder.length) return 'RESULT';
    return PathTree.stepOrder[_stepIndex];
  }

  PathNode? get _currentNode {
    if (_stepIndex < 0 || _stepIndex >= PathTree.stepOrder.length) return null;
    return PathTree.nodeById(_currentNodeId, _answers);
  }

  void _start() {
    setState(() {
      _stepIndex = 0;
      _answers.clear();
      _pathNodes
        ..clear()
        ..add('Q0')
        ..add('Q1');
      _result = null;
      _crisis = false;
    });
  }

  void _select(PathOption opt) {
    final nodeId = _currentNodeId;
    if (nodeId == 'Q1') {
      _answers['q1'] = opt.id;
      _answers.remove('q2');
    } else if (nodeId == 'Q2' || nodeId.startsWith('Q2')) {
      _answers['q2'] = opt.id;
    } else if (nodeId == 'Q3') {
      _answers['q3'] = opt.id;
    } else if (nodeId == 'Q4') {
      _answers['q4'] = opt.id;
    } else if (nodeId == 'Q5') {
      _answers['q5'] = opt.id;
    }

    if (opt.id == 'safe_crisis') {
      _finish(crisis: true);
      return;
    }

    if (_stepIndex >= PathTree.stepOrder.length - 1) {
      _finish(crisis: false);
      return;
    }

    setState(() {
      _stepIndex++;
      final nextId = PathTree.stepOrder[_stepIndex];
      final actual = nextId == 'Q2'
          ? PathTree.q2For(_answers['q1'] ?? '').id
          : nextId;
      if (!_pathNodes.contains(actual)) _pathNodes.add(actual);
    });
  }

  void _back() {
    if (_stepIndex <= 0) {
      setState(() {
        _stepIndex = -1;
        _answers.clear();
        _pathNodes
          ..clear()
          ..add('Q0');
      });
      return;
    }
    setState(() {
      // پاک کردن جواب قدم فعلی
      final cur = PathTree.stepOrder[_stepIndex];
      if (cur == 'Q1') {
        _answers.remove('q1');
        _answers.remove('q2');
      } else if (cur == 'Q2') {
        _answers.remove('q2');
      } else if (cur == 'Q3') {
        _answers.remove('q3');
      } else if (cur == 'Q4') {
        _answers.remove('q4');
      } else if (cur == 'Q5') {
        _answers.remove('q5');
      }
      _stepIndex--;
    });
  }

  Future<void> _finish({required bool crisis}) async {
    if (!_pathNodes.contains('Q5')) _pathNodes.add('Q5');
    _pathNodes.add(crisis ? 'CRISIS_EXIT' : 'RESULT');

    final result = PathMapping.buildResult(
      answers: Map<String, String>.from(_answers),
      pathNodes: List<String>.from(_pathNodes),
    );

    await ProgressService().savePathResultEntity(result);
    ref.read(pathRevisionProvider.notifier).state++;

    setState(() {
      _result = result;
      _crisis = crisis;
      _stepIndex = 5;
    });
  }

  Future<void> _deleteResult() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف نتیجه مسیر؟'),
        content: const Text(
          'خلاصه و پیشنهادها از روی خانه و این صفحه پاک می‌شود. هر وقت خواستی می‌توانی دوباره مسیر را شروع کنی.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('انصراف')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    await ProgressService().clearPathResult();
    ref.read(pathRevisionProvider.notifier).state++;
    setState(() {
      _result = null;
      _crisis = false;
      _stepIndex = -1;
      _answers.clear();
      _pathNodes
        ..clear()
        ..add('Q0');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.path, isDark: isDark);
    final rev = ref.watch(pathRevisionProvider);
    // همگام با حذف/ذخیره از خانه
    final disk = ProgressService().getPathResultEntity();
    if (disk == null && _result != null && _stepIndex >= 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _result = null;
          _crisis = false;
          _stepIndex = -1;
          _answers.clear();
          _pathNodes
            ..clear()
            ..add('Q0');
        });
      });
    } else if (disk != null && _result == null && _stepIndex < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _result = disk;
          _crisis = disk.crisis;
          _answers
            ..clear()
            ..addAll(disk.answers);
          _stepIndex = 5;
        });
      });
    }
    // silence unused if analyzer complains about rev alone
    assert(rev >= 0);

    if (_stepIndex >= 5 && _result != null) {
      if (_crisis) {
        return _CrisisView(
          palette: palette,
          onOpenCrisis: () {
            ref.read(crisisModalOpenProvider.notifier).state = true;
          },
          onRestart: _start,
          onDelete: _deleteResult,
        );
      }
      return _ResultView(
        result: _result!,
        palette: palette,
        onRestart: _start,
        onDelete: _deleteResult,
      );
    }

    if (_stepIndex < 0) {
      return _IntroView(palette: palette, onStart: _start, saved: _result);
    }

    final node = _currentNode!;
    final progress = (_stepIndex + 1) / PathTree.stepOrder.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Text(
              'قدم ${_stepIndex + 1} از ${PathTree.stepOrder.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: palette.primary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('قبلی'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: palette.surface2,
            valueColor: AlwaysStoppedAnimation(palette.primary),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          node.question,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: palette.text,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            node.hint,
            style: TextStyle(
              fontSize: 13.5,
              color: palette.text.withValues(alpha: 0.85),
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...node.options.map((o) {
          final selected = _answers.values.contains(o.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: selected
                  ? palette.primary.withValues(alpha: 0.12)
                  : palette.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _select(o),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? palette.primary : palette.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: palette.text,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        o.detail,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: palette.muted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _IntroView extends StatelessWidget {
  final ZanaPalette palette;
  final VoidCallback onStart;
  final PathResult? saved;

  const _IntroView({
    required this.palette,
    required this.onStart,
    this.saved,
  });

  Widget _card(String title, String body, {bool emphasis = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emphasis ? null : palette.surface,
        gradient: emphasis ? palette.headerGradient : null,
        borderRadius: BorderRadius.circular(16),
        border: emphasis ? null : Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: emphasis ? Colors.white : palette.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body.trim(),
            style: TextStyle(
              fontSize: 13.5,
              height: 1.75,
              color: emphasis
                  ? Colors.white.withValues(alpha: 0.95)
                  : palette.muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        FilledButton(
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            saved == null ? 'شروع مسیر' : 'شروع دوباره',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'پاسخها فقط روی همین دستگاه میمانند. به اینترنت نیاز نیست.',
            style: TextStyle(fontSize: 11.5, color: palette.muted),
          ),
        ),
        if (saved != null && !saved!.crisis) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'آخرین مسیر ذخیره شده:\n${saved!.summaryLine}',
              style: TextStyle(
                fontSize: 13,
                color: palette.muted,
                height: 1.55,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _card(PathTree.introTitle, PathTree.introBody, emphasis: true),
        _card('این مسیر چه کار می کند؟', PathTree.pathWhatBody),
        _card('چطور گزینه ها را پر کنی؟', PathTree.pathHowBody),
      ],
    );
  }
}

class _CrisisView extends StatelessWidget {
  final ZanaPalette palette;
  final VoidCallback onOpenCrisis;
  final VoidCallback onRestart;
  final VoidCallback onDelete;

  const _CrisisView({
    required this.palette,
    required this.onOpenCrisis,
    required this.onRestart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE07856).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE07856).withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.health_and_safety_rounded,
                      color: Color(0xFFE07856)),
                  SizedBox(width: 8),
                  Text(
                    'اینجا خودیاری کافی نیست',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE07856),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'با توجه به پاسخت، بهتر است الان به‌جای ادامهٔ ابزارها، از کمک جدی‌تر استفاده کنی: خطوط اضطراری، فرد قابل‌اعتماد، یا متخصص.\n\nزانا درمان نیست و جای تماس فوری را نمی‌گیرد.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: palette.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onOpenCrisis,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE07856),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.phone_in_talk_rounded),
          label: const Text('باز کردن کمک فوری'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onRestart, child: const Text('شروع دوباره مسیر')),
        TextButton(onPressed: onDelete, child: const Text('حذف این نتیجه')),
      ],
    );
  }
}

class _ResultView extends ConsumerWidget {
  final PathResult result;
  final ZanaPalette palette;
  final VoidCallback onRestart;
  final VoidCallback onDelete;

  const _ResultView({
    required this.result,
    required this.palette,
    required this.onRestart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = ContentService();
    final methods = <Method>[];
    for (final id in result.suggestedMethodIds) {
      final m = cs.methodById(id);
      if (m != null) methods.add(m);
    }
    final problems = <Problem>[];
    for (final id in result.suggestedProblemIds) {
      final p = cs.problemById(id);
      if (p != null) problems.add(p);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'نتیجهٔ مسیر تو',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'این یک تشخیص پزشکی نیست. بر اساس جواب‌هایت، نزدیک‌ترین الگوها و ابزارهای زانا این‌هاست. هرچه برایت ننشست را کنار بگذار.',
          style: TextStyle(fontSize: 13.5, color: palette.muted, height: 1.65),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.summaryLine,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.text,
              height: 1.5,
            ),
          ),
        ),
        if (result.answers['q5'] == 'safe_low') ...[
          const SizedBox(height: 10),
          Text(
            'اگر ناامیدی سنگین‌تر شد، از دکمهٔ کمک فوری در بالای صفحه استفاده کن.',
            style: TextStyle(fontSize: 12.5, color: palette.muted, height: 1.5),
          ),
        ],
        if (problems.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'مطلب‌های نزدیک',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 8),
          ...problems.map((p) => _LinkTile(
                title: p.name,
                subtitle: 'الگوی قابل‌مطالعه · نه تشخیص',
                palette: palette,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProblemSlidesScreen(problemId: p.id),
                    ),
                  );
                },
              )),
        ],
        if (methods.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'ابزارهای پیشنهادی',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 8),
          ...methods.map((m) => _LinkTile(
                title: m.title,
                subtitle: m.time,
                palette: palette,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MethodJourneyScreen(methodId: m.id),
                    ),
                  );
                },
              )),
        ],
        const SizedBox(height: 20),
        OutlinedButton(onPressed: onRestart, child: const Text('شروع دوباره')),
        TextButton(
          onPressed: onDelete,
          child: Text(
            'حذف از داشبورد',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final ZanaPalette palette;
  final VoidCallback onTap;

  const _LinkTile({
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11.5, color: palette.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: palette.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
