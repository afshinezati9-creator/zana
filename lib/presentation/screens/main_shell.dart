import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/zana_colors.dart';
import '../../core/theme/zana_theme.dart';
import '../providers/app_state_provider.dart';
import '../../core/services/progress_service.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'path/path_screen.dart';
import 'problems/problems_screen.dart';
import 'about/about_screen.dart';
import 'crisis/crisis_modal.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final crisisOpen = ref.watch(crisisModalOpenProvider);
    final palette = ZanaColors.of(tab, isDark: isDark);

    return Theme(
      data: isDark ? ZanaTheme.dark(tab) : ZanaTheme.light(tab),
      child: Scaffold(
        backgroundColor: palette.background,
        body: Stack(
          children: [
            Column(
              children: [
                _ZanaHeader(palette: palette, isDark: isDark),
                _ZanaTabs(current: tab, palette: palette),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey(tab),
                      child: _buildBody(tab),
                    ),
                  ),
                ),
              ],
            ),
            if (crisisOpen) const CrisisModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ZanaTab tab) {
    switch (tab) {
      case ZanaTab.home:
        return const HomeScreen();
      case ZanaTab.library:
        return const LibraryScreen();
      case ZanaTab.path:
        return const PathScreen();
      case ZanaTab.problems:
        return const ProblemsScreen();
      case ZanaTab.about:
        return const AboutScreen();
      case ZanaTab.manage:
        // تب مدیریت حذف شد — فقط برای سازگاری enum
        return const HomeScreen();
    }
  }
}

class _ZanaHeader extends ConsumerWidget {
  final ZanaPalette palette;
  final bool isDark;

  const _ZanaHeader({required this.palette, required this.isDark});

  static const _fontSteps = [0.9, 1.0, 1.12, 1.25, 1.4, 1.55];

  void _cycleFont(BuildContext context, WidgetRef ref) {
    final current = ref.read(fontScaleProvider);
    var idx = 0;
    for (var i = 0; i < _fontSteps.length; i++) {
      if ((current - _fontSteps[i]).abs() < 0.01) {
        idx = i;
        break;
      }
    }
    final next = _fontSteps[(idx + 1) % _fontSteps.length];
    ref.read(fontScaleProvider.notifier).state = next;
    ProgressService().setFontScale(next);

    final labels = {
      0.9: 'خیلی کوچک',
      1.0: 'معمولی',
      1.12: 'کمی بزرگ',
      1.25: 'بزرگ',
      1.4: 'خیلی بزرگ',
      1.55: 'حداکثر',
    };
    final label = labels.entries
        .reduce((a, b) =>
            (next - a.key).abs() < (next - b.key).abs() ? a : b)
        .value;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'بزرگ‌نمایی متن: $label',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(48, 0, 48, 24),
      ),
    );
  }

  String _fontLabel(double scale) {
    if (scale < 0.95) return 'الف';
    if (scale < 1.05) return 'ا';
    if (scale < 1.18) return 'آ';
    if (scale < 1.32) return 'آ+';
    if (scale < 1.48) return 'آ++';
    return 'آ+++';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(fontScaleProvider);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo_header.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: palette.primary,
                alignment: Alignment.center,
                child: const Text(
                  'Z',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
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
                  'ZANA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: palette.text,
                    height: 1.2,
                  ),
                ),
                Text(
                  'زانا · توسعه فردی و خودآگاهی',
                  style: TextStyle(
                    fontSize: 10,
                    color: palette.muted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // بزرگ‌نمایی متن — با هر لمس یک پله؛ پیام پایین صفحه نشان می‌دهد
          _HeaderButton(
            palette: palette,
            tooltip: 'بزرگ‌نمایی متن',
            onTap: () => _cycleFont(context, ref),
            child: Text(
              'بزرگنمایی',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: palette.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // شب / روز
          _HeaderButton(
            icon: isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
            palette: palette,
            tooltip: isDark ? 'حالت روز' : 'حالت شب',
            onTap: () {
              final next = !isDark;
              ref.read(isDarkModeProvider.notifier).state = next;
              ProgressService().setDarkMode(next);
            },
          ),
          const SizedBox(width: 6),
          // درباره
          _HeaderButton(
            icon: Icons.info_outline_rounded,
            palette: palette,
            tooltip: 'درباره',
            isActive: ref.watch(currentTabProvider) == ZanaTab.about,
            onTap: () {
              ref.read(currentTabProvider.notifier).state = ZanaTab.about;
            },
          ),
          const SizedBox(width: 6),
          // کمک فوری
          _HeaderButton(
            icon: Icons.health_and_safety_rounded,
            palette: palette,
            isDanger: true,
            tooltip: 'کمک فوری',
            onTap: () {
              ref.read(crisisModalOpenProvider.notifier).state = true;
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final ZanaPalette palette;
  final VoidCallback onTap;
  final bool isDanger;
  final bool isActive;
  final String? tooltip;

  const _HeaderButton({
    this.icon,
    this.child,
    required this.palette,
    required this.onTap,
    this.isDanger = false,
    this.isActive = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDanger
        ? const Color(0xFFE07856).withValues(alpha: 0.12)
        : (isActive
            ? palette.primary.withValues(alpha: 0.15)
            : palette.surface2);
    final borderColor = isDanger
        ? const Color(0xFFE07856).withValues(alpha: 0.45)
        : (isActive ? palette.primary : palette.border);
    final iconColor = isDanger
        ? const Color(0xFFE07856)
        : (isActive ? palette.primaryDark : palette.text);

    final btn = Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: child != null
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
              : EdgeInsets.zero,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: child ??
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
        ),
      ),
    );

    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}

class _ZanaTabs extends ConsumerWidget {
  final ZanaTab current;
  final ZanaPalette palette;

  const _ZanaTabs({required this.current, required this.palette});

  /// تب‌های اصلی — درباره از اینجا خارج شد و به هدر رفت
  static const _items = [
    (ZanaTab.home, Icons.home_outlined, Icons.home_rounded, 'خانه'),
    (ZanaTab.library, Icons.menu_book_outlined, Icons.menu_book_rounded, 'کتابخانه'),
    (ZanaTab.path, Icons.explore_outlined, Icons.explore_rounded, 'مسیر'),
    (ZanaTab.problems, Icons.favorite_border_rounded, Icons.favorite_rounded, 'مشکلات'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.9, 1.65);
    final iconSize = (21 * (0.9 + 0.1 * scale)).clamp(18.0, 28.0);
    final labelSize = (10 * scale).clamp(9.0, 14.0);
    final vPad = (10 * (0.85 + 0.15 * scale)).clamp(8.0, 14.0);

    return Container(
      decoration: BoxDecoration(
        gradient: palette.pageGradient,
        border: Border(bottom: BorderSide(color: palette.border, width: 1)),
      ),
      child: Row(
        children: _items.map((item) {
          final isActive = current == item.$1;
          return Expanded(
            child: InkWell(
              onTap: () {
                ref.read(currentTabProvider.notifier).state = item.$1;
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: vPad),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? palette.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.$3 : item.$2,
                      size: iconSize,
                      color: isActive ? palette.primaryDark : palette.muted,
                    ),
                    SizedBox(height: (3 * scale).clamp(2.0, 5.0)),
                    Text(
                      item.$4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: labelSize,
                        fontWeight: FontWeight.w700,
                        color: isActive ? palette.primaryDark : palette.muted,
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
