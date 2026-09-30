import 'package:flutter/material.dart';

import '../theme.dart';

/// Python sintaksisini ranglab beruvchi oddiy skaner.
class Hl {
  static const keyword = Color(0xFFC084FC);
  static const builtin = Color(0xFF67E8F9);
  static const string = C.green;
  static const number = C.blue;
  static const boolc = C.orange;
  static const none = C.grey;
  static const comment = Color(0xFF6B72A8);
  static const func = Color(0xFFFDE68A);
  static const op = Color(0xFFF9A8D4);
  static const plain = Color(0xFFE2E8F0);
  static const constant = Color(0xFFFCA5A5);
}

const _keywords = {
  'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else',
  'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not',
  'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield',
};

const _builtins = {
  'print', 'input', 'len', 'type', 'id', 'int', 'float', 'str', 'bool', 'list', 'dict', 'tuple', 'set',
  'range', 'round', 'abs', 'isinstance', 'sum', 'min', 'max', 'sorted', 'complex', 'repr', 'enumerate', 'zip',
};

final _tokenRe = RegExp(
  r'''(#[^\n]*)'''
  r'''|([rRfFbBuU]{0,2}(?:"""[\s\S]*?(?:"""|$)|\'\'\'[\s\S]*?(?:\'\'\'|$)|"(?:\\.|[^"\\\n])*"?|'(?:\\.|[^'\\\n])*'?))'''
  r'''|(\b\d[\d_]*\.?[\d_]*(?:[eE][+-]?\d+)?j?\b|\.\d+)'''
  r'''|([A-Za-z_][A-Za-z0-9_]*)'''
  r'''|([+\-*/%=<>!&|^~]+|[()\[\]{}:,.])''',
);

List<TextSpan> highlightSpans(String code, {TextStyle? base}) {
  final spans = <TextSpan>[];
  int last = 0;
  for (final m in _tokenRe.allMatches(code)) {
    if (m.start > last) spans.add(TextSpan(text: code.substring(last, m.start)));
    final t = m.group(0)!;
    Color c = Hl.plain;
    FontStyle? fs;
    FontWeight? fw;
    if (m.group(1) != null) {
      c = Hl.comment;
      fs = FontStyle.italic;
    } else if (m.group(2) != null) {
      c = Hl.string;
    } else if (m.group(3) != null) {
      c = Hl.number;
    } else if (m.group(4) != null) {
      if (_keywords.contains(t)) {
        c = Hl.keyword;
        fw = FontWeight.w700;
      } else if (t == 'True' || t == 'False') {
        c = Hl.boolc;
        fw = FontWeight.w700;
      } else if (t == 'None') {
        c = Hl.none;
        fw = FontWeight.w700;
      } else if (_builtins.contains(t)) {
        c = Hl.builtin;
      } else if (m.end < code.length && code[m.end] == '(') {
        c = Hl.func;
      } else if (t.length > 1 && t == t.toUpperCase() && RegExp(r'[A-Z]').hasMatch(t)) {
        c = Hl.constant;
      }
    } else if (m.group(5) != null) {
      c = Hl.op;
    }
    spans.add(TextSpan(text: t, style: TextStyle(color: c, fontStyle: fs, fontWeight: fw)));
    last = m.end;
  }
  if (last < code.length) spans.add(TextSpan(text: code.substring(last)));
  return spans;
}

TextStyle codeStyle({double size = 15}) =>
    TextStyle(fontFamily: mono, fontSize: size, height: 1.55, color: Hl.plain);

/// Faqat o'qish uchun rangli kod bloki.
class CodeView extends StatelessWidget {
  final String code;
  final double fontSize;
  final bool lineNumbers;
  final int? highlightLine;
  const CodeView(this.code, {super.key, this.fontSize = 15, this.lineNumbers = true, this.highlightLine});

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    final style = codeStyle(size: fontSize);
    final lineH = fontSize * 1.55;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          if (highlightLine != null)
            Positioned(
              top: (highlightLine! - 1) * lineH,
              left: 0,
              right: 0,
              height: lineH,
              child: Container(color: C.yellow.withValues(alpha: 0.12)),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lineNumbers)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(
                    List.generate(lines.length, (i) => '${i + 1}').join('\n'),
                    textAlign: TextAlign.right,
                    style: style.copyWith(color: C.faint.withValues(alpha: 0.6)),
                  ),
                ),
              SelectableText.rich(TextSpan(style: style, children: highlightSpans(code))),
            ],
          ),
        ],
      ),
    );
  }
}
