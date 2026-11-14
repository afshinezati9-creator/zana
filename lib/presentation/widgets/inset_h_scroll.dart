import 'package:flutter/material.dart';
import '../../core/theme/zana_colors.dart';
import '../../core/utils/app_scroll_behavior.dart';

/// اسکرول افقی؛ ارتفاع پالت با بزرگ‌نمایی رشد می‌کند تا چیپ‌ها بریده نشوند
class InsetHScroll extends StatelessWidget {
  final ZanaPalette palette;
  final double height;
  final List<Widget> children;
  final EdgeInsets outerPadding;

  const InsetHScroll({
    super.key,
    required this.palette,
    required this.children,
    this.height = 52,
    this.outerPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.9, 1.7);
    // پالت کمی بزرگ‌تر از قبل + رشد با زوم
    final h = (56 * scale + 8).clamp(52.0, 96.0);

    return Padding(
      padding: outerPadding,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: ScrollConfiguration(
          behavior: AppScrollBehavior(),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            primary: false,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: (8 * scale).clamp(6.0, 12.0),
            ),
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) => Align(
              alignment: Alignment.center,
              child: children[i],
            ),
          ),
        ),
      ),
    );
  }
}
