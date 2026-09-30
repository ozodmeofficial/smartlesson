import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../services/progress.dart';
import '../../theme.dart';
import '../../widgets/beads.dart';
import '../../widgets/code_highlight.dart';
import '../../widgets/common.dart';
import 'labs.dart';

class _Level {
  final String text;
  final String target;
  final String hint;
  final String sample;
  const _Level(this.text, this.target, this.hint, this.sample);
}

const _levels = <_Level>[
  _Level('Python', 'P', 'Birinchi belgi — 0-indeks', '[0]'),
  _Level('Python', 'n', 'Oxirgi belgi — manfiy indeks', '[-1]'),
  _Level('Dasturlash', 'Dastur', "Boshidan 6 ta belgi. stop kirmaydi!", '[:6]'),
  _Level('hisobot.pdf', 'pdf', 'Oxirgi 3 belgi', '[-3:]'),
  _Level('hisobot.pdf', 'hisobot', "Oxirgi 4 ta belgidan tashqari hammasi", '[:-4]'),
  _Level('salom', 'molas', 'Teskari!', '[::-1]'),
  _Level('0123456789', '02468', 'Har ikkinchi belgi', '[::2]'),
  _Level('0123456789', '13579', "1-indeksdan boshlab har ikkinchi", '[1::2]'),
  _Level('Toshkent', 'shk', "Uzunlik = stop − start = 3", '[2:5]'),
  _Level('abcdefgh', 'hfd', 'Oxiridan boshlab, 2 qadam orqaga, 3 ta belgi', '[::-2] emas... [7:1:-2]'),
];

/// `[a:b:c]` yoki `[i]` ko'rinishidagi yozuvni hisoblaydi. Xato bo'lsa null.
String? evalSlice(String s, String input) {
  var t = input.trim().replaceAll(' ', '');
  if (t.startsWith('soz')) t = t.substring(3);
  if (!t.startsWith('[') || !t.endsWith(']')) return null;
  t = t.substring(1, t.length - 1);
  final parts = t.split(':');
  if (parts.length > 3) return null;
  int? p(String x) => x.isEmpty ? null : int.tryParse(x);
  for (final x in parts) {
    if (x.isNotEmpty && int.tryParse(x) == null) return null;
  }
  if (parts.length == 1) {
    final i = p(parts[0]);
    if (i == null) return null;
    final j = i < 0 ? i + s.length : i;
    if (j < 0 || j >= s.length) return '⛔ IndexError';
    return s[j];
  }
  final step = parts.length == 3 ? p(parts[2]) : null;
  if (step == 0) return '⛔ ValueError';
  return sliceIndices(p(parts[0]), p(parts[1]), step, s.length).map((i) => s[i]).join();
}

class SliceNinjaScreen extends StatefulWidget {
  final Lesson lesson;
  const SliceNinjaScreen({super.key, required this.lesson});
  @override
  State<SliceNinjaScreen> createState() => _SliceNinjaScreenState();
}

class _SliceNinjaScreenState extends State<SliceNinjaScreen> {
  int _lv = 0;
  final _input = TextEditingController(text: '[]');
  String? _result;
  bool _solved = false;
  bool _hint = false;
  int _shake = 0;
  int _hintsUsed = 0;
  bool _celebrate = false;

  _Level get lv => _levels[_lv];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _try() {
    final r = evalSlice(lv.text, _input.text);
    setState(() {
      _result = r ?? '⛔ Yozuv noto\'g\'ri. Masalan: [2:5] yoki [::-1]';
      _solved = r == lv.target;
      if (!_solved) _shake++;
    });
    if (_solved && _lv == _levels.length - 1) {
      final first = ProgressScope.read(context).complete('${widget.lesson.id}.lab.sliceNinja', xpReward: 40);
      setState(() => _celebrate = true);
      if (first) showRewards(context, message: '+40 XP — siz haqiqiy Slice ninjasiz! 🥷');
    }
  }

  void _nextLevel() {
    setState(() {
      _lv++;
      _input.text = '[]';
      _input.selection = const TextSelection.collapsed(offset: 1);
      _result = null;
      _solved = false;
      _hint = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final preview = evalSlice(lv.text, _input.text);
    final sel = <int>[];
    if (preview != null && !preview.startsWith('⛔')) {
      var t = _input.text.trim().replaceAll(' ', '');
      if (t.length >= 2) t = t.substring(1, t.length - 1);
      final parts = t.split(':');
      int? p(String x) => x.isEmpty ? null : int.tryParse(x);
      if (parts.length == 1 && p(parts[0]) != null) {
        final i = p(parts[0])!;
        sel.add(i < 0 ? i + lv.text.length : i);
      } else if (parts.length >= 2) {
        sel.addAll(sliceIndices(p(parts[0]), p(parts[1]), parts.length == 3 ? p(parts[2]) : null, lv.text.length));
      }
    }
    return Scaffold(
      body: ConfettiOverlay(
        play: _celebrate,
        child: Column(children: [
          TopBar(
            title: '🥷 Slice ninja',
            subtitle: "Kerakli bo'lakni bitta slice bilan kesib oling!",
            color: l.color,
            progress: (_lv + (_solved ? 1 : 0)) / _levels.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Centered(
                maxWidth: 900,
                child: Column(children: [
                  Row(children: [
                    Pill('${_lv + 1}-daraja / ${_levels.length}', color: l.color),
                    const Spacer(),
                    if (_hintsUsed > 0) Pill('💡 $_hintsUsed maslahat', color: C.yellow),
                  ]),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(children: highlightSpans('soz = "${lv.text}"')),
                    style: codeStyle(size: 26),
                  ),
                  const SizedBox(height: 18),
                  Panel(child: Center(child: BeadsView(lv.text, selected: sel, size: 52, color: l.color))),
                  const SizedBox(height: 22),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('🎯 Maqsad:  ', style: h2()),
                    Text.rich(TextSpan(children: highlightSpans('"${lv.target}"')), style: codeStyle(size: 30).copyWith(fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 22),
                  Shake(
                    trigger: _shake,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('soz', style: codeStyle(size: 28)),
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller: _input,
                          autofocus: true,
                          style: codeStyle(size: 28).copyWith(color: C.yellow),
                          onChanged: (_) => setState(() {
                            _result = null;
                          }),
                          onSubmitted: (_) => _solved ? (_lv < _levels.length - 1 ? _nextLevel() : null) : _try(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: C.code,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: l.color, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('→', style: codeStyle(size: 28).copyWith(color: C.faint)),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 200,
                        child: Text(
                          preview == null ? '?' : (preview.startsWith('⛔') ? preview : '"$preview"'),
                          style: codeStyle(size: 24).copyWith(color: preview == lv.target ? C.green : C.dim),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  if (_result != null && !_solved)
                    Text(_result == null ? '' : "Hozircha \"${_result!}\" chiqdi — maqsad \"${lv.target}\". Yana urinib ko'ring!",
                        style: body(C.orange)),
                  if (_solved)
                    Panel(
                      borderColor: C.green,
                      child: Row(children: [
                        const Text('🥷', style: TextStyle(fontSize: 40)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _lv == _levels.length - 1 ? 'Barcha darajalar o\'tildi! Siz haqiqiy Slice ninjasiz!' : 'Aniq kesim! Keyingi darajaga tayyormisiz?',
                            style: h3(C.green),
                          ),
                        ),
                        if (_lv < _levels.length - 1)
                          BigButton('Keyingi daraja', icon: Icons.arrow_forward_rounded, color: l.color, color2: l.color2, onTap: _nextLevel)
                        else
                          BigButton('Tayyor', icon: Icons.check_rounded, color: C.green, onTap: () => Navigator.pop(context)),
                      ]),
                    )
                  else
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      BigButton('Kesish!', icon: Icons.content_cut_rounded, color: l.color, color2: l.color2, onTap: _try),
                      const SizedBox(width: 12),
                      BigButton('Maslahat', icon: Icons.lightbulb_rounded, color: C.yellow, outlined: true,
                          onTap: _hint
                              ? null
                              : () => setState(() {
                                    _hint = true;
                                    _hintsUsed++;
                                  })),
                    ]),
                  if (_hint && !_solved) ...[
                    const SizedBox(height: 14),
                    Text('💡 ${lv.hint}', style: body(C.yellow).copyWith(fontSize: 17)),
                  ],
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
