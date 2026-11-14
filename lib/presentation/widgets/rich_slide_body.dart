import 'package:flutter/material.dart';

import '../../core/services/rich_slide_parser.dart';
import '../../core/theme/zana_colors.dart';

class RichSlideBody extends StatelessWidget {
  final String text;
  final ZanaPalette palette;
  final double fontSize;
  final bool defaultLtr;

  const RichSlideBody({
    super.key,
    required this.text,
    required this.palette,
    this.fontSize = 14,
    this.defaultLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final nodes = RichSlideParser.parse(text);
    if (nodes.isEmpty) {
      return Text(
        text,
        textAlign: defaultLtr ? TextAlign.left : TextAlign.right,
        textDirection: defaultLtr ? TextDirection.ltr : TextDirection.rtl,
        style: TextStyle(fontSize: fontSize, height: 1.75, color: palette.text),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final n in nodes) ...[
          _node(n),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _node(RichNode n) {
    switch (n.type) {
      case RichNodeType.ltrBlock:
        return _ltrBox(n.text);
      case RichNodeType.rtlBlock:
      case RichNodeType.paragraph:
      case RichNodeType.plain:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: fontSize, height: 1.75, color: palette.text),
        );
      case RichNodeType.h2:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize + 3,
            fontWeight: FontWeight.w800,
            color: palette.primary,
            height: 1.4,
          ),
        );
      case RichNodeType.h3:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize + 1.5,
            fontWeight: FontWeight.w700,
            color: palette.text,
            height: 1.4,
          ),
        );
      case RichNodeType.highlight:
        return _coloredBox(n.text, palette.accentSoft, palette.accent, bold: true);
      case RichNodeType.bold:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.7,
            color: palette.text,
            fontWeight: FontWeight.w800,
          ),
        );
      case RichNodeType.italic:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.7,
            color: palette.muted,
            fontStyle: FontStyle.italic,
          ),
        );
      case RichNodeType.underline:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.7,
            color: palette.text,
            decoration: TextDecoration.underline,
          ),
        );
      case RichNodeType.strike:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.7,
            color: palette.muted,
            decoration: TextDecoration.lineThrough,
          ),
        );
      case RichNodeType.center:
        return Text(
          n.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.7,
            color: palette.text,
            fontWeight: FontWeight.w600,
          ),
        );
      case RichNodeType.formula:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('فرمول',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: palette.primary)),
              const SizedBox(height: 6),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  n.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: fontSize + 1,
                    height: 1.5,
                    color: palette.text,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        );
      case RichNodeType.box:
        return _coloredBox(n.text, palette.surface, palette.primary);
      case RichNodeType.tip:
        return _alert(n.text, const Color(0xFF5B8A72), Icons.lightbulb_outline_rounded, 'نکته');
      case RichNodeType.warn:
        return _alert(n.text, const Color(0xFFC9A96E), Icons.warning_amber_rounded, 'توجه');
      case RichNodeType.danger:
        return _alert(n.text, ZanaColors.danger, Icons.error_outline_rounded, 'هشدار');
      case RichNodeType.success:
        return _alert(n.text, const Color(0xFF5B8A72), Icons.check_circle_outline, 'موفق');
      case RichNodeType.quote:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: palette.primary, width: 3)),
          ),
          child: Text(
            n.text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.7,
              fontStyle: FontStyle.italic,
              color: palette.muted,
            ),
          ),
        );
      case RichNodeType.table:
        return _TableView(rows: n.rows ?? const [], palette: palette);
      case RichNodeType.checklist:
        return _ItemList(
          items: n.items ?? const [],
          palette: palette,
          icon: Icons.check_box_outlined,
          numbered: false,
        );
      case RichNodeType.steps:
        return _ItemList(
          items: n.items ?? const [],
          palette: palette,
          icon: Icons.flag_outlined,
          numbered: true,
        );
      case RichNodeType.ordered:
        return _ItemList(
          items: n.items ?? const [],
          palette: palette,
          icon: null,
          numbered: true,
        );
      case RichNodeType.code:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.border),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              n.text,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: fontSize - 1,
                height: 1.5,
                color: palette.text,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );

      case RichNodeType.badge:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              n.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: palette.primary,
              ),
            ),
          ),
        );
      case RichNodeType.note:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border(
              right: BorderSide(color: palette.muted, width: 3),
            ),
          ),
          child: Text(
            n.text,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: fontSize - 0.5, height: 1.6, color: palette.muted),
          ),
        );
      case RichNodeType.keyVal:
        final parts = n.text.split('|');
        final k = parts.isNotEmpty ? parts[0].trim() : n.text;
        final v = parts.length > 1 ? parts.sublist(1).join('|').trim() : '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(k,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: palette.primary,
                        fontSize: fontSize)),
              ),
              if (v.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(v,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: palette.text, fontSize: fontSize)),
                ),
              ],
            ],
          ),
        );
      case RichNodeType.dim:
        return Text(
          n.text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: fontSize - 1,
            height: 1.6,
            color: palette.muted,
          ),
        );
      case RichNodeType.big:
        return Text(
          n.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize + 4,
            fontWeight: FontWeight.w800,
            color: palette.primary,
            height: 1.4,
          ),
        );
      case RichNodeType.cols:
        final items = n.items ?? const [];
        return LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth > 420;
          if (!wide) {
            return Column(
              children: [
                for (final it in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(it,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: fontSize, color: palette.text, height: 1.5)),
                    ),
                  ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(items[i],
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: fontSize - 0.5, color: palette.text, height: 1.5)),
                  ),
                ),
              ],
            ],
          );
        });


      case RichNodeType.callout:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.primarySoft, palette.surface2],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.primary.withValues(alpha: 0.35)),
          ),
          child: Text(n.text, textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize, height: 1.65, color: palette.text, fontWeight: FontWeight.w600)),
        );
      case RichNodeType.redText:
        return Text(n.text, textAlign: TextAlign.right,
            style: TextStyle(fontSize: fontSize, height: 1.6, color: const Color(0xFFB54A4A), fontWeight: FontWeight.w600));
      case RichNodeType.greenText:
        return Text(n.text, textAlign: TextAlign.right,
            style: TextStyle(fontSize: fontSize, height: 1.6, color: const Color(0xFF2F7D4A), fontWeight: FontWeight.w600));
      case RichNodeType.blueText:
        return Text(n.text, textAlign: TextAlign.right,
            style: TextStyle(fontSize: fontSize, height: 1.6, color: const Color(0xFF2F5F8F), fontWeight: FontWeight.w600));
      case RichNodeType.card:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(color: palette.border.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Text(n.text, textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize, height: 1.65, color: palette.text)),
        );
      case RichNodeType.sep:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(child: Divider(color: palette.border, thickness: 1)),
              if (n.text.trim().isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(n.text, style: TextStyle(fontSize: 12, color: palette.muted, fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
              ],
              Expanded(child: Divider(color: palette.border, thickness: 1)),
            ],
          ),
        );
      case RichNodeType.emphasis:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(n.text, textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize + 1, height: 1.5, color: palette.primary, fontWeight: FontWeight.w800)),
        );
      case RichNodeType.numBlock:
        final parts = n.text.split('|');
        final num = parts.isNotEmpty ? parts[0].trim() : '';
        final rest = parts.length > 1 ? parts.sublist(1).join('|').trim() : '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(rest.isEmpty ? n.text : rest, textAlign: TextAlign.right,
                  style: TextStyle(fontSize: fontSize, height: 1.55, color: palette.text))),
            ],
          ),
        );
      case RichNodeType.bulletList:
        final items = n.items ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final it in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 7, height: 7,
                      decoration: BoxDecoration(color: palette.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(it, textAlign: TextAlign.right,
                        style: TextStyle(fontSize: fontSize, height: 1.55, color: palette.text))),
                  ],
                ),
              ),
          ],
        );

      case RichNodeType.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(color: palette.border, thickness: 1),
        );
    }
  }

  Widget _ltrBox(String text) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.border),
        ),
        child: Text(
          text,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: fontSize - 0.5,
            height: 1.55,
            color: palette.text,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _coloredBox(String text, Color bg, Color border, {bool bold = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.65,
          color: palette.text,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _alert(String text, Color color, IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color)),
                const SizedBox(height: 4),
                Text(
                  text,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.6,
                    color: palette.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<String> items;
  final ZanaPalette palette;
  final IconData? icon;
  final bool numbered;

  const _ItemList({
    required this.items,
    required this.palette,
    required this.icon,
    required this.numbered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numbered)
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: palette.primary,
                      ),
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 18, color: palette.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    items[i],
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: palette.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TableView extends StatelessWidget {
  final List<List<String>> rows;
  final ZanaPalette palette;

  const _TableView({required this.rows, required this.palette});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final colCount = rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    final w = MediaQuery.sizeOf(context).width;
    final cellPad = w < 400 ? 8.0 : 12.0;
    final fontSz = w < 400 ? 11.5 : 12.5;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
            color: palette.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                columnWidths: {
                  for (var i = 0; i < colCount; i++)
                    i: const IntrinsicColumnWidth(flex: 1),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(color: palette.border),
                  verticalInside:
                      BorderSide(color: palette.border.withValues(alpha: 0.6)),
                ),
                children: [
                  for (var i = 0; i < rows.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: i == 0
                            ? palette.primarySoft
                            : (i.isOdd ? palette.surface2 : palette.surface),
                      ),
                      children: [
                        for (var c = 0; c < colCount; c++)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: cellPad, vertical: cellPad * 0.85),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: w < 400 ? 72 : 96,
                                maxWidth: w < 600 ? 160 : 220,
                              ),
                              child: Text(
                                c < rows[i].length ? rows[i][c] : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSz,
                                  fontWeight: i == 0
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: palette.text,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
