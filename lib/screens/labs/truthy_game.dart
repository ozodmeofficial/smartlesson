import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models.dart';
import '../../services/progress.dart';
import '../../theme.dart';
import '../../widgets/code_highlight.dart';
import '../../widgets/common.dart';
import '../../widgets/md_text.dart';
import 'labs.dart';

const _items = <(String, bool, String)>[
  ('0', false, 'Nol — falsy.'),
  ('0.0', false, 'Kasr nol ham falsy.'),
  ('""', false, "Bo'sh matn — falsy."),
  ('" "', true, 'Probel ham belgi! Bo\'sh emas → True.'),
  ('"0"', true, 'Ichida bitta belgi bor → True.'),
  ('"False"', true, "Bu so'z, qiymat emas. Bo'sh emas → True."),
  ('[]', false, "Bo'sh ro'yxat — falsy."),
  ('[0]', true, "Ro'yxat bo'sh emas (ichida 0 bor) → True."),
  ('{}', false, "Bo'sh lug'at — falsy."),
  ('None', false, "\"Hech narsa\" — falsy."),
  ('1', true, 'Noldan farqli son → True.'),
  ('-5', true, 'Manfiy son ham noldan farqli → True.'),
  ('0.0001', true, 'Juda kichik, lekin nol emas → True.'),
  ('"salom"', true, "Bo'sh emas matn → True."),
  ('[[]]', true, "Tashqi ro'yxatda bitta element bor → True."),
  ('False', false, 'False — o\'zi yolg\'on.'),
  ('0j', false, 'Kompleks nol — falsy.'),
  ('()', false, "Bo'sh tuple — falsy."),
];

class TruthyGameScreen extends StatefulWidget {
  final Lesson lesson;
  const TruthyGameScreen({super.key, required this.lesson});
  @override
  State<TruthyGameScreen> createState() => _TruthyGameScreenState();
}

class _TruthyGameScreenState extends State<TruthyGameScreen> {
  late List<(String, bool, String)> _deck;
  int _i = 0;
  int _score = 0;
  bool? _picked;
  int _shake = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _deck = (List.of(_items)..shuffle(math.Random())).take(14).toList();
    _i = 0;
    _score = 0;
    _picked = null;
  }

  void _pick(bool v) {
    if (_picked != null) return;
    setState(() {
      _picked = v;
      if (v == _deck[_i].$2) {
        _score++;
      } else {
        _shake++;
      }
    });
  }

  Future<void> _next() async {
    if (_picked == null) return;
    if (_i < _deck.length - 1) {
      setState(() {
        _i++;
        _picked = null;
      });
      return;
    }
    final pct = _score / _deck.length;
    if (pct >= 0.7) {
      final first = ProgressScope.read(context).complete('${widget.lesson.id}.lab.truthyGame', xpReward: 25);
      if (first) showRewards(context, message: '+25 XP');
    }
    await showLabResult(context,
        emoji: pct >= 0.7 ? '⚖️' : '🤔',
        title: '$_score / ${_deck.length}',
        text: pct >= 0.7
            ? "Falsy oilasini yoddan bilasiz: 0, 0.0, \"\", [], {}, (), None, False!"
            : "Eslatma: faqat \"bo'sh\" narsalar False. Yana urinib ko'ring!",
        color: widget.lesson.color);
    if (mounted) setState(_reset);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final it = _deck[_i];
    final answered = _picked != null;
    final ok = _picked == it.$2;
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (n, e) {
          if (e is! KeyDownEvent) return KeyEventResult.ignored;
          if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _pick(true);
          } else if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
            _pick(false);
          } else if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.space) {
            _next();
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        },
        child: Column(children: [
          TopBar(
            title: '⚖️ Truthy yoki Falsy?',
            subtitle: 'bool(qiymat) nima qaytaradi?   •   ← True,  → False,  Enter — keyingi',
            color: l.color,
            progress: (_i + (answered ? 1 : 0)) / _deck.length,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(children: [
                    Row(children: [Pill('${_i + 1} / ${_deck.length}', color: l.color), const Spacer(), Pill('✅ $_score', color: C.green)]),
                    const SizedBox(height: 30),
                    Shake(
                      trigger: _shake,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: Container(
                          key: ValueKey(_i),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 34),
                          decoration: BoxDecoration(
                            color: C.code,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: answered ? (ok ? C.green : C.red) : C.border, width: 2.5),
                          ),
                          child: Text.rich(
                            TextSpan(children: [
                              ...highlightSpans('bool('),
                              ...highlightSpans(it.$1),
                              ...highlightSpans(')'),
                              if (answered) ...[
                                const TextSpan(text: '  →  ', style: TextStyle(color: C.faint)),
                                ...highlightSpans(it.$2 ? 'True' : 'False'),
                              ],
                            ]),
                            style: codeStyle(size: 42).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(children: [
                      Expanded(child: _btn('True', '←', C.green, true, it)),
                      const SizedBox(width: 18),
                      Expanded(child: _btn('False', '→', C.red, false, it)),
                    ]),
                    const SizedBox(height: 22),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: answered
                          ? Panel(
                              borderColor: (ok ? C.green : C.orange).withValues(alpha: 0.5),
                              child: Row(children: [
                                Text(ok ? '🎉' : '💡', style: const TextStyle(fontSize: 30)),
                                const SizedBox(width: 14),
                                Expanded(child: MdText(it.$3, style: body().copyWith(fontSize: 17))),
                                BigButton('Keyingi', icon: Icons.arrow_forward_rounded, color: l.color, color2: l.color2, onTap: _next),
                              ]),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _btn(String label, String key, Color c, bool v, (String, bool, String) it) {
    final answered = _picked != null;
    final right = it.$2 == v;
    return GestureDetector(
      onTap: () => _pick(v),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: c.withValues(alpha: answered ? (right ? 0.3 : 0.04) : 0.13),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.withValues(alpha: answered && !right ? 0.3 : 1), width: 2.5),
          ),
          child: Column(children: [
            Text(label, style: TextStyle(fontFamily: mono, fontSize: 32, fontWeight: FontWeight.w700, color: c)),
            Text(key, style: small(C.faint).copyWith(fontSize: 18)),
          ]),
        ),
      ),
    );
  }
}
