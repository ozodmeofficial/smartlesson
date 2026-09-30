import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models.dart';
import '../../services/progress.dart';
import '../../theme.dart';
import '../../widgets/code_highlight.dart';
import '../../widgets/common.dart';
import 'labs.dart';

const _types = ['int', 'float', 'str', 'bool', 'NoneType'];

const _values = <(String, String, String)>[
  ('42', 'int', 'Butun son'),
  ('-7', 'int', 'Manfiy butun son ham int'),
  ('1_000_000', 'int', '`_` faqat ko\'z uchun — bu int'),
  ('2 ** 100', 'int', "Katta bo'lsa ham int"),
  ('0', 'int', 'Nol ham butun son'),
  ('3.14', 'float', 'Nuqta bor — float'),
  ('5.0', 'float', '.0 bo\'lsa ham float!'),
  ('1.5e6', 'float', 'Ilmiy yozuv doim float'),
  ('10 / 2', 'float', '`/` bo\'lish doim float beradi (5.0)'),
  ('-0.5', 'float', 'Manfiy kasr'),
  ('"42"', 'str', 'Tirnoq ichida — matn!'),
  ("'True'", 'str', 'Tirnoqdagi True — bu matn'),
  ('""', 'str', "Bo'sh matn ham str"),
  ('"3.14"', 'str', 'Tirnoq — matn'),
  ('"None"', 'str', 'Bu None emas, oddiy matn'),
  ('True', 'bool', 'Mantiqiy qiymat'),
  ('False', 'bool', 'Mantiqiy qiymat'),
  ('10 > 5', 'bool', 'Taqqoslash natijasi — bool'),
  ('3 == 7', 'bool', 'Taqqoslash natijasi — bool'),
  ('None', 'NoneType', "\"Qiymat yo'q\""),
  ('print("hi")', 'NoneType', 'print() hech narsa qaytarmaydi → None'),
  ('7 // 2', 'int', '`//` ikki int uchun int beradi (3)'),
  ('input()', 'str', 'input() doim str qaytaradi!'),
  ('len("salom")', 'int', 'len() — int'),
  ('0.1 + 0.2', 'float', 'Kasr sonlar yig\'indisi float'),
  ('str(25)', 'str', 'str() matnga aylantiradi'),
  ('int("7")', 'int', 'int() songa aylantiradi'),
  ('bool(0)', 'bool', 'bool() doim bool qaytaradi'),
];

class TypeSorterScreen extends StatefulWidget {
  final Lesson lesson;
  const TypeSorterScreen({super.key, required this.lesson});
  @override
  State<TypeSorterScreen> createState() => _TypeSorterScreenState();
}

class _TypeSorterScreenState extends State<TypeSorterScreen> {
  final _rnd = math.Random();
  static const _duration = 60;
  bool _playing = false;
  int _left = _duration;
  int _score = 0;
  int _combo = 0;
  int _shake = 0;
  late (String, String, String) _cur;
  String? _feedback;
  bool _lastOk = true;
  Timer? _timer;
  final _focus = FocusNode();
  final List<(String, String, String)> _mistakes = [];

  @override
  void initState() {
    super.initState();
    _cur = _values[0];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _playing = true;
      _left = _duration;
      _score = 0;
      _combo = 0;
      _feedback = null;
      _mistakes.clear();
      _cur = _values[_rnd.nextInt(_values.length)];
    });
    _focus.requestFocus();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _left--);
      if (_left <= 0) _end();
    });
  }

  Future<void> _end() async {
    _timer?.cancel();
    setState(() => _playing = false);
    final p = ProgressScope.read(context);
    p.recordSorter(_score);
    if (_score >= 10) {
      final first = p.complete('${widget.lesson.id}.lab.typeSorter', xpReward: 25);
      if (first) showRewards(context, message: '+25 XP');
    } else {
      showRewards(context);
    }
    await showLabResult(context,
        emoji: _score >= 15 ? '⚡' : (_score >= 10 ? '🎯' : '⏱️'),
        title: '$_score ball!',
        text: _score >= 10
            ? "Ajoyib tezlik! Turlarni ko'rishingiz bilan taniyapsiz. Rekord: ${p.bestSorter}"
            : "Laboratoriyani o'tish uchun 10 ball kerak. Yana bir bor!",
        color: widget.lesson.color);
  }

  void _answer(String t) {
    if (!_playing) return;
    final ok = t == _cur.$2;
    setState(() {
      if (ok) {
        _combo++;
        _score += _combo >= 5 ? 2 : 1;
        _feedback = '✅ ${_cur.$1} → ${_cur.$2}';
      } else {
        _combo = 0;
        _shake++;
        _mistakes.add(_cur);
        _feedback = '❌ ${_cur.$1} → ${_cur.$2}: ${_cur.$3}';
      }
      _lastOk = ok;
      var next = _values[_rnd.nextInt(_values.length)];
      while (next == _cur) {
        next = _values[_rnd.nextInt(_values.length)];
      }
      _cur = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return Scaffold(
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: (n, e) {
          if (e is! KeyDownEvent) return KeyEventResult.ignored;
          final keys = [
            LogicalKeyboardKey.digit1,
            LogicalKeyboardKey.digit2,
            LogicalKeyboardKey.digit3,
            LogicalKeyboardKey.digit4,
            LogicalKeyboardKey.digit5,
          ];
          final i = keys.indexOf(e.logicalKey);
          if (i >= 0) {
            _answer(_types[i]);
            return KeyEventResult.handled;
          }
          if (!_playing && e.logicalKey == LogicalKeyboardKey.enter) {
            _start();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(children: [
          TopBar(
            title: '⚡ Tur saralash',
            subtitle: "Qiymat qaysi turga tegishli? 60 soniya!  •  klaviatura: 1–5",
            color: l.color,
            progress: _playing ? _left / _duration : null,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: _playing ? _game() : _intro(),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _intro() {
    final p = ProgressScope.of(context);
    return Column(children: [
      const Text('⚡', style: TextStyle(fontSize: 80)),
      Text('Tur saralash', style: h1()),
      const SizedBox(height: 10),
      Text(
        "Ekranda Python qiymati paydo bo'ladi. Uning turini tanlang: int, float, str, bool yoki NoneType.\n"
        "Ketma-ket 5 ta to'g'ri javob — kombo, har biri 2 ball! Laboratoriyani o'tish uchun 10 ball kerak.",
        textAlign: TextAlign.center,
        style: body(C.dim).copyWith(fontSize: 17),
      ),
      const SizedBox(height: 18),
      Wrap(spacing: 10, children: [for (final t in _types) Pill(t, color: C.forType(t))]),
      const SizedBox(height: 10),
      Text("💡 Ranglarni eslab qoling — ular butun darslikda bir xil!", style: small(C.yellow)),
      const SizedBox(height: 26),
      BigButton('Boshlash (Enter)', icon: Icons.play_arrow_rounded, color: widget.lesson.color, color2: widget.lesson.color2,
          onTap: _start),
      if (p.bestSorter > 0) ...[const SizedBox(height: 14), Text('🏅 Rekordingiz: ${p.bestSorter} ball', style: h3(C.yellow))],
      if (_mistakes.isNotEmpty) ...[
        const SizedBox(height: 26),
        Align(alignment: Alignment.centerLeft, child: Text('Oxirgi o\'yindagi xatolar:', style: h3())),
        const SizedBox(height: 8),
        for (final m in _mistakes.toSet())
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              SizedBox(width: 160, child: Text.rich(TextSpan(children: highlightSpans(m.$1)), style: codeStyle(size: 16))),
              Pill(m.$2, color: C.forType(m.$2)),
              const SizedBox(width: 12),
              Expanded(child: Text(m.$3, style: body(C.dim))),
            ]),
          ),
      ],
    ]);
  }

  Widget _game() {
    return Column(children: [
      Row(children: [
        Pill('⏱️ $_left s', color: _left <= 10 ? C.red : C.cyan),
        const Spacer(),
        if (_combo >= 3) Pill('🔥 ${_combo}x kombo', color: C.orange),
        const SizedBox(width: 8),
        Pill('⭐ $_score', color: C.yellow),
      ]),
      const SizedBox(height: 36),
      Shake(
        trigger: _shake,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: c),
          child: Container(
            key: ValueKey('$_score-$_shake-${_cur.$1}'),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
            decoration: BoxDecoration(
              color: C.code,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: C.border, width: 2),
              boxShadow: [BoxShadow(color: widget.lesson.color.withValues(alpha: 0.25), blurRadius: 30)],
            ),
            child: Text.rich(TextSpan(children: highlightSpans(_cur.$1)), style: codeStyle(size: 50).copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 28,
        child: _feedback == null
            ? null
            : Text(_feedback!, style: body(_lastOk ? C.green : C.orange).copyWith(fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 26),
      Row(children: [
        for (int i = 0; i < _types.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _Bucket(type: _types[i], hotkey: '${i + 1}', onTap: () => _answer(_types[i]))),
        ],
      ]),
    ]);
  }
}

class _Bucket extends StatefulWidget {
  final String type;
  final String hotkey;
  final VoidCallback onTap;
  const _Bucket({required this.type, required this.hotkey, required this.onTap});
  @override
  State<_Bucket> createState() => _BucketState();
}

class _BucketState extends State<_Bucket> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final c = C.forType(widget.type);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(
            color: c.withValues(alpha: _hover ? 0.3 : 0.14),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(28)),
            border: Border.all(color: c, width: 2.5),
          ),
          child: Column(children: [
            Text(widget.type, style: TextStyle(fontFamily: mono, fontSize: 21, fontWeight: FontWeight.w700, color: c)),
            const SizedBox(height: 4),
            Text('[${widget.hotkey}]', style: small(C.faint)),
          ]),
        ),
      ),
    );
  }
}
