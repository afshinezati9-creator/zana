import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/chapter_service.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/method.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/rich_slide_body.dart';

class MethodJourneyScreen extends ConsumerStatefulWidget {
  final int methodId;

  const MethodJourneyScreen({super.key, required this.methodId});

  @override
  ConsumerState<MethodJourneyScreen> createState() =>
      _MethodJourneyScreenState();
}

class _MethodJourneyScreenState extends ConsumerState<MethodJourneyScreen> {
  late Method method;
  List<Chapter> chapters = const [];
  int currentChapter = 0;
  bool finished = false;

  // timer
  Timer? _timer;
  int _remaining = 0;
  bool _timerRunning = false;
  bool _timerDone = false;

  @override
  void initState() {
    super.initState();
    method = ContentService().methodById(widget.methodId)!;
    _boot();
  }

  Future<void> _boot() async {
    final loaded = await ChapterService().loadChapters(widget.methodId);
    if (!mounted) return;
    final p = ProgressService().getProgress(widget.methodId);
    setState(() {
      chapters = loaded;
      currentChapter =
          p.chaptersCompleted.clamp(0, loaded.isEmpty ? 0 : loaded.length - 1);
      if (p.isCompleted) finished = true;
    });
    ProgressService().addRecent(widget.methodId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (currentChapter < chapters.length - 1) {
      await ProgressService().updateChapter(widget.methodId, currentChapter);
      setState(() {
        currentChapter++;
        _resetTimerState();
      });
    }
  }

  void _goPrev() {
    if (currentChapter > 0) {
      setState(() {
        currentChapter--;
        _resetTimerState();
      });
    }
  }

  void _jump(int i) {
    final unlocked = ProgressService().chaptersCompleted(widget.methodId);
    if (i <= unlocked || i == 0) {
      setState(() {
        currentChapter = i;
        _resetTimerState();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('این فصل هنوز باز نشده'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _finish() async {
    await ProgressService().markCompleted(widget.methodId);
    setState(() => finished = true);
  }

  void _resetTimerState() {
    _timer?.cancel();
    _timerRunning = false;
    _timerDone = false;
    _remaining = 0;
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _remaining = seconds;
      _timerRunning = true;
      _timerDone = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() {
          _remaining = 0;
          _timerRunning = false;
          _timerDone = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('آفرین! یک دور کامل شد.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _toggleTimer(int totalSeconds) {
    if (_timerDone) {
      _startTimer(totalSeconds);
      return;
    }
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
    } else {
      if (_remaining <= 0) _remaining = totalSeconds;
      _startTimer(_remaining);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.library, isDark: isDark);
    if (chapters.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: palette.primary),
        ),
      );
    }
    final ch = chapters[currentChapter];
    final pct = ((currentChapter + 1) / chapters.length);

    return Theme(
      data: isDark
          ? Theme.of(context).copyWith(
              scaffoldBackgroundColor: palette.background,
            )
          : Theme.of(context),
      child: Scaffold(
        backgroundColor: palette.background,
        body: Column(
          children: [
            // کاور
            _Cover(
              method: method,
              palette: palette,
              onBack: () => Navigator.of(context).pop(),
              onPinChanged: () => setState(() {}),
            ),
            // پیشرفت فصل
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اسلاید ${currentChapter + 1} از ${chapters.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: palette.muted,
                    ),
                  ),
                  Text(
                    '${(pct * 100).round()}٪',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: palette.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 4,
                  backgroundColor: palette.border,
                  valueColor: AlwaysStoppedAnimation(palette.primary),
                ),
              ),
            ),
            // نقاط فصل — اسکرول افقی تا با تعداد زیاد اسلاید سرریز نشود
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 32,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(chapters.length, (i) {
                        final unlocked = i <=
                            ProgressService()
                                .chaptersCompleted(widget.methodId);
                        final isCur = i == currentChapter;
                        final done = unlocked &&
                            i <
                                ProgressService()
                                    .chaptersCompleted(widget.methodId);
                        return GestureDetector(
                          onTap: () => _jump(i),
                          child: Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCur
                                  ? palette.primary
                                  : (unlocked
                                      ? palette.primarySoft
                                      : palette.surface2),
                              border: Border.all(
                                color:
                                    isCur ? palette.primary : palette.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                done ? '✓' : '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isCur
                                      ? Colors.white
                                      : (unlocked
                                          ? palette.primaryDark
                                          : palette.muted),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

            // محتوای فصل
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                children: [
                  if (finished && currentChapter == chapters.length - 1)
                    _FinishCard(palette: palette, onLibrary: () {
                      Navigator.of(context).pop();
                      ref.read(currentTabProvider.notifier).state =
                          ZanaTab.library;
                    }),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ch.tagLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: palette.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ch.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: palette.text,
                            height: 1.35,
                          ),
                        ),
                        if (ch.lead != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            ch.lead!,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: palette.text,
                              height: 1.7,
                            ),
                          ),
                        ],
                        if (ch.origin != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.explore_outlined,
                                  size: 14, color: palette.muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  ch.origin!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: palette.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        ...ch.blocks.map((b) => _BlockView(
                              block: b,
                              palette: palette,
                              remaining: _remaining,
                              timerRunning: _timerRunning,
                              timerDone: _timerDone,
                              onTimer: _toggleTimer,
                            )),
                        if (ch.cliff != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: palette.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'فصل بعد',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: palette.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ch.cliff!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: palette.text,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // ناوبری چسبان
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            10 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.96),
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: Row(
            children: [
              if (currentChapter > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goPrev,
                    child: const Text('قبلی'),
                  ),
                ),
              if (currentChapter > 0) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: currentChapter < chapters.length - 1
                    ? ElevatedButton(
                        onPressed: _goNext,
                        child: const Text('فصل بعد'),
                      )
                    : ElevatedButton(
                        onPressed: finished ? null : _finish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZanaColors.success,
                          foregroundColor: const Color(0xFF3D2F0F),
                        ),
                        child: Text(finished ? 'تکمیل شد' : 'پایان سفر'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final Method method;
  final ZanaPalette palette;
  final VoidCallback onBack;
  final VoidCallback onPinChanged;

  const _Cover({
    required this.method,
    required this.palette,
    required this.onBack,
    required this.onPinChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(gradient: palette.headerGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  await ProgressService().togglePin(method.id);
                  onPinChanged();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ProgressService().isPinned(method.id)
                            ? 'به پین‌شده‌ها اضافه شد'
                            : 'از پین‌شده‌ها برداشته شد',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  ProgressService().isPinned(method.id)
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            method.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          if (method.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              method.subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [
              _Badge(method.time),
              _Badge('شواهد ${method.evidenceLabel}'),
              if (method.isAdult) const _Badge('۱۸+'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FinishCard extends StatelessWidget {
  final ZanaPalette palette;
  final VoidCallback onLibrary;

  const _FinishCard({required this.palette, required this.onLibrary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            'این سفر را کامل کردی',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'می‌توانی روش دیگری را شروع کنی.',
            style: TextStyle(fontSize: 13, color: palette.muted),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onLibrary,
            child: const Text('بازگشت به کتابخانه'),
          ),
        ],
      ),
    );
  }
}

class _BlockView extends StatelessWidget {
  final ChapterBlock block;
  final ZanaPalette palette;
  final int remaining;
  final bool timerRunning;
  final bool timerDone;
  final void Function(int totalSeconds) onTimer;

  const _BlockView({
    required this.block,
    required this.palette,
    required this.remaining,
    required this.timerRunning,
    required this.timerDone,
    required this.onTimer,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case BlockType.story:
      case BlockType.concept:
      case BlockType.sci:
        return _LabeledText(
          label: block.label ?? '',
          text: block.text ?? '',
          palette: palette,
          icon: block.type == BlockType.sci ? Icons.science_outlined : null,
        );
      case BlockType.promise:
      case BlockType.ending:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.primary.withValues(alpha: 0.25)),
          ),
          child: Text(
            block.text ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.text,
              height: 1.7,
            ),
          ),
        );
      case BlockType.quote:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: palette.primary, width: 3),
            ),
          ),
          child: Text(
            block.text ?? '',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: palette.muted,
              height: 1.7,
            ),
          ),
        );
      case BlockType.checklist:
        return _Checklist(block: block, palette: palette);
      case BlockType.actionSteps:
        return _ActionSteps(items: block.items ?? [], palette: palette);
      case BlockType.timer:
        return _TimerBox(
          minutes: block.minutes ?? 25,
          label: block.label ?? '',
          remaining: remaining,
          running: timerRunning,
          done: timerDone,
          palette: palette,
          onToggle: onTimer,
        );
      case BlockType.days:
        return _DaysList(items: block.dayItems ?? [], palette: palette);
      case BlockType.mirrorBefore:
      case BlockType.mirrorSigns:
        return _MirrorList(
          label: block.label ?? '',
          items: block.items ?? [],
          palette: palette,
        );
      case BlockType.mirrorAfter:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            block.label ?? '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
        );
      case BlockType.exit:
        return _ExitList(items: block.items ?? [], palette: palette);
      case BlockType.evidence:
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, color: palette.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.label ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        );
      case BlockType.sources:
        return _BulletList(
          title: 'منابع',
          items: block.items ?? [],
          palette: palette,
        );
      case BlockType.limits:
        return _BulletList(
          title: 'آنچه این روش ثابت نمی‌کند',
          items: block.items ?? [],
          palette: palette,
          alert: true,
        );
    }
  }
}

class _LabeledText extends StatelessWidget {
  final String label;
  final String text;
  final ZanaPalette palette;
  final IconData? icon;

  const _LabeledText({
    required this.label,
    required this.text,
    required this.palette,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: palette.muted),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          if (label.isNotEmpty) const SizedBox(height: 6),
          RichSlideBody(
            text: text,
            palette: palette,
            defaultLtr: label.contains('منابع') || label.toLowerCase().contains('source'),
          ),
        ],
      ),
    );
  }
}

class _Checklist extends StatefulWidget {
  final ChapterBlock block;
  final ZanaPalette palette;
  const _Checklist({required this.block, required this.palette});

  @override
  State<_Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<_Checklist> {
  final Set<int> checked = {};

  @override
  Widget build(BuildContext context) {
    final items = widget.block.items ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.block.label != null)
            Text(
              widget.block.label!,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: widget.palette.muted,
              ),
            ),
          const SizedBox(height: 8),
          ...List.generate(items.length, (i) {
            final on = checked.contains(i);
            return InkWell(
              onTap: () => setState(() {
                if (on) {
                  checked.remove(i);
                } else {
                  checked.add(i);
                }
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      on
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20,
                      color: on
                          ? widget.palette.primary
                          : widget.palette.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        items[i],
                        style: TextStyle(
                          fontSize: 13.5,
                          color: widget.palette.text,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActionSteps extends StatelessWidget {
  final List<String> items;
  final ZanaPalette palette;
  const _ActionSteps({required this.items, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: List.generate(items.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.text,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TimerBox extends StatelessWidget {
  final int minutes;
  final String label;
  final int remaining;
  final bool running;
  final bool done;
  final ZanaPalette palette;
  final void Function(int total) onToggle;

  const _TimerBox({
    required this.minutes,
    required this.label,
    required this.remaining,
    required this.running,
    required this.done,
    required this.palette,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = minutes * 60;
    final display = remaining > 0 ? remaining : total;
    final m = display ~/ 60;
    final s = display % 60;
    final text = done
        ? 'تمام!'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: done ? ZanaColors.success : palette.text,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => onToggle(total),
            icon: Icon(
              done
                  ? Icons.replay_rounded
                  : (running ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
            label: Text(
              done ? 'دوباره' : (running ? 'توقف' : (remaining > 0 ? 'ادامه' : 'شروع')),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: palette.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _DaysList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final ZanaPalette palette;
  const _DaysList({required this.items, required this.palette});

  @override
  State<_DaysList> createState() => _DaysListState();
}

class _DaysListState extends State<_DaysList> {
  final Set<int> done = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: List.generate(widget.items.length, (i) {
          final d = widget.items[i];
          final on = done.contains(i);
          return InkWell(
            onTap: () => setState(() {
              if (on) {
                done.remove(i);
              } else {
                done.add(i);
              }
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: on ? widget.palette.primarySoft : widget.palette.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: on ? widget.palette.primary : widget.palette.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: on ? widget.palette.primary : widget.palette.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${d['d']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: on ? Colors.white : widget.palette.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'روز ${d['d']}: ${d['t']}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: widget.palette.text,
                          ),
                        ),
                        Text(
                          '${d['s']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MirrorList extends StatelessWidget {
  final String label;
  final List<String> items;
  final ZanaPalette palette;
  const _MirrorList({
    required this.label,
    required this.items,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: palette.muted,
              ),
            ),
          const SizedBox(height: 8),
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: palette.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: palette.text,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ExitList extends StatelessWidget {
  final List<String> items;
  final ZanaPalette palette;
  const _ExitList({required this.items, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: items
            .map((t) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE4DD).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ZanaColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: palette.text,
                      height: 1.55,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final String title;
  final List<String> items;
  final ZanaPalette palette;
  final bool alert;

  const _BulletList({
    required this.title,
    required this.items,
    required this.palette,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      alert ? Icons.warning_amber_rounded : Icons.circle,
                      size: alert ? 16 : 6,
                      color: alert ? ZanaColors.danger : palette.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: palette.text,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
