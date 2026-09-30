import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../services/progress.dart';
import '../../theme.dart';
import '../../widgets/beads.dart';
import '../../widgets/code_highlight.dart';
import '../../widgets/common.dart';
import '../../widgets/md_text.dart';
import 'labs.dart';

class SliceLabScreen extends StatefulWidget {
  final Lesson lesson;
  const SliceLabScreen({super.key, required this.lesson});
  @override
  State<SliceLabScreen> createState() => _SliceLabScreenState();
}

class _SliceLabScreenState extends State<SliceLabScreen> {
  final _text = TextEditingController(text: 'Dasturlash');
  int? _start = 0;
  int? _stop = 6;
  int? _step;
  final Set<String> _tried = {};

  String get s => _text.text;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String get _expr {
    String f(int? v) => v == null ? '' : '$v';
    final st = _step == null ? '' : ':${_step!}';
    return '${f(_start)}:${f(_stop)}$st';
  }

  void _changed() {
    _tried.add('$s[$_expr]');
    if (_tried.length >= 6) {
      final first = ProgressScope.read(context).complete('${widget.lesson.id}.lab.sliceLab', xpReward: 25);
      if (first) showRewards(context, message: "+25 XP — slicing ustaxonasi o'zlashtirildi! 🔪");
    }
  }

  void _preset(int? a, int? b, int? c) {
    setState(() {
      _start = a;
      _stop = b;
      _step = c;
    });
    _changed();
  }

  String _explain(List<int> idx) {
    final n = s.length;
    final st = _step ?? 1;
    if (st == 0) return "❌ `step` 0 bo'lishi mumkin emas → ValueError: slice step cannot be zero";
    final parts = <String>[];
    parts.add(_start == null
        ? (st > 0 ? "start bo'sh → **boshidan** (0)" : "start bo'sh → **oxiridan** (${n - 1})")
        : (_start! < 0 ? 'start = ${_start!} → ${_start!} + $n = **${_start! + n}**' : 'start = **${_start!}** (kiradi)'));
    parts.add(_stop == null
        ? (st > 0 ? "stop bo'sh → **oxirigacha**" : "stop bo'sh → **boshigacha**")
        : (_stop! < 0 ? 'stop = ${_stop!} → ${_stop!} + $n = **${_stop! + n}** (kirmaydi)' : 'stop = **${_stop!}** (kirmaydi)'));
    parts.add(st == 1 ? 'qadam = 1 (ketma-ket)' : (st < 0 ? 'qadam = **$st** → **orqaga** yurish' : 'qadam = **$st** → har $st-belgi'));
    parts.add(idx.isEmpty ? "Natija: **bo'sh string** `\"\"`" : 'Olingan indekslar: **${idx.join(', ')}**');
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final n = s.length;
    final idx = n == 0 ? <int>[] : sliceIndices(_start, _stop, _step, n);
    final result = idx.map((i) => s[i]).join();
    return Scaffold(
      body: Column(children: [
        TopBar(
          title: '🔪 Slicing ustaxonasi',
          subtitle: "Sliderlarni suring va natijani jonli ko'ring (kamida 6 xil kesim sinab ko'ring)",
          color: l.color,
          progress: (_tried.length / 6).clamp(0, 1),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Centered(
              maxWidth: 1050,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Text('soz = ', style: codeStyle(size: 22)),
                  SizedBox(
                    width: 360,
                    child: TextField(
                      controller: _text,
                      maxLength: 18,
                      style: codeStyle(size: 22).copyWith(color: Hl.string),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        counterText: '',
                        prefixText: '"',
                        suffixText: '"',
                        prefixStyle: codeStyle(size: 22).copyWith(color: Hl.string),
                        suffixStyle: codeStyle(size: 22).copyWith(color: Hl.string),
                        filled: true,
                        fillColor: C.code,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('len(soz) = $n', style: codeStyle(size: 18).copyWith(color: C.dim)),
                ]),
                const SizedBox(height: 22),
                Panel(
                  padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                  child: Center(child: BeadsView(s, selected: idx, size: 54, color: l.color)),
                ),
                const SizedBox(height: 18),
                Panel(
                  color: C.code,
                  child: Row(children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          ...highlightSpans('soz[$_expr]'),
                          const TextSpan(text: '   →   ', style: TextStyle(color: C.faint)),
                          ...highlightSpans(_step == 0 ? 'ValueError' : '"$result"'),
                        ]),
                        style: codeStyle(size: 28).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (_step != 0 && (_step ?? 1) > 0 && _start != null && _stop != null && _start! >= 0 && _stop! >= 0)
                      Pill('uzunlik = stop − start = ${(_stop! - _start!).clamp(0, 999)}', color: C.yellow),
                  ]),
                ),
                const SizedBox(height: 18),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Panel(
                      child: Column(children: [
                        _slider('start', _start, -n, n, l.color, (v) => setState(() => _start = v)),
                        _slider('stop', _stop, -n, n, C.pink, (v) => setState(() => _stop = v)),
                        _slider('step', _step, -3, 3, C.cyan, (v) => setState(() => _step = v)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    width: 360,
                    child: Panel(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('🧠 Python nima qildi?', style: h3()),
                        const SizedBox(height: 10),
                        MdText(_explain(idx), style: body().copyWith(fontSize: 15)),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 18),
                Text('Mashhur kesimlar — bosib ko\'ring:', style: h3()),
                const SizedBox(height: 10),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _chip('[:3]', 'birinchi 3 ta', null, 3, null),
                  _chip('[-3:]', 'oxirgi 3 ta', -3, null, null),
                  _chip('[::-1]', 'teskari', null, null, -1),
                  _chip('[::2]', 'har ikkinchi', null, null, 2),
                  _chip('[1:-1]', 'chetlarisiz', 1, -1, null),
                  _chip('[:]', 'nusxa', null, null, null),
                  _chip('[2:5]', 'uzunligi 3', 2, 5, null),
                  _chip('[-1:-4:-1]', 'oxiridan 3 ta teskari', -1, -4, -1),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String code, String label, int? a, int? b, int? c) => ActionChip(
        backgroundColor: C.card,
        side: const BorderSide(color: C.border),
        label: Text.rich(TextSpan(children: [
          ...highlightSpans('soz$code'),
          TextSpan(text: '  $label', style: const TextStyle(fontFamily: 'Nunito', color: C.dim, fontSize: 13)),
        ]), style: codeStyle(size: 15)),
        onPressed: () => _preset(a, b, c),
      );

  Widget _slider(String name, int? v, int min, int max, Color c, ValueChanged<int?> onChanged) {
    final enabled = v != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 60, child: Text(name, style: TextStyle(fontFamily: mono, fontSize: 17, fontWeight: FontWeight.w700, color: c))),
        Switch(
          value: enabled,
          activeThumbColor: c,
          onChanged: (on) {
            onChanged(on ? (name == 'step' ? 1 : (name == 'stop' ? max : 0)) : null);
            _changed();
          },
        ),
        Expanded(
          child: Slider(
            value: (v ?? (name == 'step' ? 1 : 0)).clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble() == min.toDouble() ? min + 1.0 : max.toDouble(),
            divisions: (max - min) == 0 ? 1 : max - min,
            activeColor: enabled ? c : C.faint,
            label: v?.toString() ?? "bo'sh",
            onChanged: enabled
                ? (d) {
                    onChanged(d.round());
                  }
                : null,
            onChangeEnd: (_) => _changed(),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(v?.toString() ?? "bo'sh",
              textAlign: TextAlign.right, style: TextStyle(fontFamily: mono, fontSize: 17, color: enabled ? C.text : C.faint)),
        ),
      ]),
    );
  }
}
