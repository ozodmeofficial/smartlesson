import 'package:flutter/material.dart';

import '../theme.dart';
import 'code_highlight.dart';

/// Juda kichik markdown: `### sarlavha`, `• punkt`, **qalin**, `kod`, ``` blok.
class MdText extends StatelessWidget {
  final String md;
  final TextStyle? style;
  final TextAlign align;
  const MdText(this.md, {super.key, this.style, this.align = TextAlign.start});

  static List<InlineSpan> inline(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`|\*(.+?)\*');
    int last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      if (m.group(1) != null) {
        spans.add(TextSpan(
          children: inline(m.group(1)!, base.copyWith(fontWeight: FontWeight.w900)),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ));
      } else if (m.group(2) != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2F66),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text.rich(
              TextSpan(children: highlightSpans(m.group(2)!)),
              style: TextStyle(fontFamily: mono, fontSize: (base.fontSize ?? 16) * 0.9, color: Hl.plain, height: 1.3),
            ),
          ),
        ));
      } else {
        spans.add(TextSpan(text: m.group(3), style: const TextStyle(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? body();
    final children = <Widget>[];
    final lines = md.split('\n');
    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      if (line.trim().startsWith('```')) {
        final buf = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          buf.add(lines[i]);
          i++;
        }
        i++;
        children.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: C.code, borderRadius: BorderRadius.circular(10)),
          child: CodeView(buf.join('\n'), fontSize: 14, lineNumbers: false),
        ));
        continue;
      }
      if (line.startsWith('### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text.rich(TextSpan(children: inline(line.substring(4), h3())), style: h3()),
        ));
      } else if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 8));
      } else if (line.startsWith('• ') || line.startsWith('- ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: base.copyWith(color: C.violet, fontWeight: FontWeight.w900)),
            Expanded(child: Text.rich(TextSpan(children: inline(line.substring(2), base)), style: base)),
          ]),
        ));
      } else {
        children.add(Text.rich(TextSpan(children: inline(line, base)), style: base, textAlign: align));
      }
      i++;
    }
    return Column(
      crossAxisAlignment: align == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
