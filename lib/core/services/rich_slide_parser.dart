/// نشانه‌گذاری غنی داخل بدنهٔ اسلاید.
/// تگ‌ها: ltr rtl hl h2 h3 b i u s center formula box quote tip warn danger success
/// check steps ol table hr divider code
library;

enum RichNodeType {
  paragraph,
  ltrBlock,
  rtlBlock,
  highlight,
  bold,
  italic,
  underline,
  strike,
  center,
  h2,
  h3,
  formula,
  box,
  tip,
  warn,
  danger,
  success,
  quote,
  table,
  checklist,
  steps,
  ordered,
  code,
  divider,
  badge,
  note,
  keyVal,
  dim,
  big,
  cols,
  callout,
  redText,
  greenText,
  blueText,
  card,
  sep,
  emphasis,
  numBlock,
  bulletList,
  plain,
}

class RichNode {
  final RichNodeType type;
  final String text;
  final List<List<String>>? rows;
  final List<String>? items;

  const RichNode({
    required this.type,
    this.text = '',
    this.rows,
    this.items,
  });
}

class RichSlideParser {
  RichSlideParser._();

  static final _blockTag = RegExp(
    r'\[(ltr|rtl|hl|h2|h3|b|i|u|s|center|formula|box|tip|warn|danger|success|quote|table|check|steps|ol|code|hr|badge|note|key|dim|big|cols|callout|red|green|blue|card|sep|em|num|list)\]([\s\S]*?)\[/\1\]',
    caseSensitive: false,
  );

  static final _hrOnly = RegExp(r'^\s*\[hr\]\s*$', multiLine: true, caseSensitive: false);

  /// `**متن**` مارک‌داون
  static final _mdBold = RegExp(r'\*\*([^*]+?)\*\*');

  /// متن آزاد: **کلمه** → هایلایت (بدون ستاره)
  static String _mdBoldToHlTags(String text) {
    var out = text.replaceAllMapped(
      _mdBold,
      (m) => '[hl]${m.group(1)}[/hl]',
    );
    return out.replaceAll('**', '');
  }

  /// داخل باکس tip/warn و… : ستاره را بردار، تگ hl خام نماند
  static String _stripMdKeepText(String text) {
    var out = text.replaceAllMapped(_mdBold, (m) => m.group(1)!);
    out = out.replaceAllMapped(
      RegExp(r'\[hl\]([\s\S]*?)\[/hl\]', caseSensitive: false),
      (m) => m.group(1) ?? '',
    );
    return out.replaceAll('**', '');
  }

  static List<RichNode> parse(String raw) {
    var text = raw.replaceAll('\r\n', '\n');
    if (text.trim().isEmpty) return const [];

    // **…** در متن آزاد → [hl]…[/hl]
    text = _mdBoldToHlTags(text);

    // standalone [hr]
    text = text.replaceAllMapped(_hrOnly, (_) => '[hr] [/hr]');

    final nodes = <RichNode>[];
    var cursor = 0;
    for (final m in _blockTag.allMatches(text)) {
      if (m.start > cursor) {
        nodes.addAll(_paragraphs(text.substring(cursor, m.start)));
      }
      final tag = m.group(1)!.toLowerCase();
      var body = (m.group(2) ?? '').trim();
      // باکس‌ها نباید تگ hl خام نشان دهند
      if (tag != 'hl' && tag != 'b' && tag != 'h2' && tag != 'h3') {
        body = _stripMdKeepText(body);
      } else {
        body = body.replaceAll('**', '');
      }
      nodes.add(_nodeFromTag(tag, body));
      cursor = m.end;
    }
    if (cursor < text.length) {
      nodes.addAll(_paragraphs(text.substring(cursor)));
    }
    return nodes.where((n) {
      if (n.type == RichNodeType.table) {
        return n.rows != null && n.rows!.isNotEmpty;
      }
      if (n.type == RichNodeType.checklist ||
          n.type == RichNodeType.steps ||
          n.type == RichNodeType.ordered) {
        return n.items != null && n.items!.isNotEmpty;
      }
      if (n.type == RichNodeType.divider) return true;
      return n.text.trim().isNotEmpty;
    }).toList();
  }

  static RichNode _nodeFromTag(String tag, String body) {
    switch (tag) {
      case 'ltr':
        return RichNode(type: RichNodeType.ltrBlock, text: body);
      case 'rtl':
        return RichNode(type: RichNodeType.rtlBlock, text: body);
      case 'hl':
        return RichNode(type: RichNodeType.highlight, text: body);
      case 'h2':
        return RichNode(type: RichNodeType.h2, text: body);
      case 'h3':
        return RichNode(type: RichNodeType.h3, text: body);
      case 'b':
        return RichNode(type: RichNodeType.bold, text: body);
      case 'i':
        return RichNode(type: RichNodeType.italic, text: body);
      case 'u':
        return RichNode(type: RichNodeType.underline, text: body);
      case 's':
        return RichNode(type: RichNodeType.strike, text: body);
      case 'center':
        return RichNode(type: RichNodeType.center, text: body);
      case 'formula':
        return RichNode(type: RichNodeType.formula, text: body);
      case 'box':
        return RichNode(type: RichNodeType.box, text: body);
      case 'tip':
        return RichNode(type: RichNodeType.tip, text: body);
      case 'warn':
        return RichNode(type: RichNodeType.warn, text: body);
      case 'danger':
        return RichNode(type: RichNodeType.danger, text: body);
      case 'success':
        return RichNode(type: RichNodeType.success, text: body);
      case 'quote':
        return RichNode(type: RichNodeType.quote, text: body);
      case 'table':
        return RichNode(type: RichNodeType.table, rows: _parseTable(body));
      case 'check':
        return RichNode(type: RichNodeType.checklist, items: _lines(body));
      case 'steps':
        return RichNode(type: RichNodeType.steps, items: _lines(body));
      case 'ol':
        return RichNode(type: RichNodeType.ordered, items: _lines(body));
      case 'code':
        return RichNode(type: RichNodeType.code, text: body);
      case 'badge':
        return RichNode(type: RichNodeType.badge, text: body);
      case 'note':
        return RichNode(type: RichNodeType.note, text: body);
      case 'key':
        return RichNode(type: RichNodeType.keyVal, text: body);
      case 'dim':
        return RichNode(type: RichNodeType.dim, text: body);
      case 'big':
        return RichNode(type: RichNodeType.big, text: body);
      case 'cols':
        return RichNode(type: RichNodeType.cols, items: _lines(body));

      case 'callout':
        return RichNode(type: RichNodeType.callout, text: body);
      case 'red':
        return RichNode(type: RichNodeType.redText, text: body);
      case 'green':
        return RichNode(type: RichNodeType.greenText, text: body);
      case 'blue':
        return RichNode(type: RichNodeType.blueText, text: body);
      case 'card':
        return RichNode(type: RichNodeType.card, text: body);
      case 'sep':
        return RichNode(type: RichNodeType.sep, text: body);
      case 'em':
        return RichNode(type: RichNodeType.emphasis, text: body);
      case 'num':
        return RichNode(type: RichNodeType.numBlock, text: body);
      case 'list':
        return RichNode(type: RichNodeType.bulletList, items: _lines(body));
      case 'hr':
        return const RichNode(type: RichNodeType.divider);
      default:
        return RichNode(type: RichNodeType.paragraph, text: body);
    }
  }

  static List<String> _lines(String body) {
    return body
        .split('\n')
        .map((e) => e.trim())
        .map((e) => e.replaceFirst(RegExp(r'^[-•*]\s*'), ''))
        .map((e) => e.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static List<List<String>> _parseTable(String body) {
    final rows = <List<String>>[];
    for (final line in body.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) continue;
      if (t.replaceAll(RegExp(r'[\|\-\s]'), '').isEmpty) continue;
      final cells2 = t.split('|').map((e) => e.trim()).toList();
      if (cells2.isNotEmpty && cells2.first.isEmpty) cells2.removeAt(0);
      if (cells2.isNotEmpty && cells2.last.isEmpty) cells2.removeLast();
      if (cells2.isNotEmpty) rows.add(cells2);
    }
    return rows;
  }

  static List<RichNode> _paragraphs(String chunk) {
    final parts = chunk.split(RegExp(r'\n\s*\n'));
    final out = <RichNode>[];
    for (final p in parts) {
      final t = p.trim();
      if (t.isEmpty) continue;
      out.add(RichNode(type: RichNodeType.paragraph, text: t));
    }
    return out;
  }
}
