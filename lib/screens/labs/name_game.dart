import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models.dart';
import '../../services/progress.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/md_text.dart';
import 'labs.dart';

enum _V { good, bad, error }

class _NameItem {
  final String name;
  final _V verdict;
  final String why;
  const _NameItem(this.name, this.verdict, this.why);
}

const _items = <_NameItem>[
  _NameItem('talaba_ismi', _V.good, "snake_case — PEP 8 bo'yicha ideal."),
  _NameItem('2narx', _V.error, "Raqam bilan boshlangan → SyntaxError: invalid decimal literal."),
  _NameItem('class', _V.error, "`class` — kalit so'z. Nom bo'la olmaydi."),
  _NameItem('_maxfiy', _V.good, "`_` bilan boshlanishi mumkin. Odatda \"ichki\" o'zgaruvchilar shunday nomlanadi."),
  _NameItem('narx-yangi', _V.error, "`-` — ayirish operatori. SyntaxError."),
  _NameItem('list', _V.bad, "Ishlaydi, lekin `list()` funksiyasini yopib qo'yadi!"),
  _NameItem('foydalanuvchiIsmi', _V.bad, "Ishlaydi, lekin camelCase — bu JavaScript uslubi. Python'da `foydalanuvchi_ismi`."),
  _NameItem('umumiy_narx', _V.good, "Ma'noli va snake_case. A'lo!"),
  _NameItem('talaba ismi', _V.error, "Bo'shliq bo'lmaydi → SyntaxError."),
  _NameItem('x1', _V.bad, "Ishlaydi, lekin ma'nosiz. Nima saqlanayotgani noma'lum."),
  _NameItem('MAKSIMAL_URINISH', _V.good, "KATTA_HARF — konstanta uchun to'g'ri uslub."),
  _NameItem('for', _V.error, "`for` — kalit so'z."),
  _NameItem('narx!', _V.error, "`!` belgisi nomda bo'lmaydi."),
  _NameItem('str', _V.bad, "Ishlaydi, lekin `str()` funksiyasi yo'qoladi."),
  _NameItem('narx2', _V.good, "Raqam oxirida bo'lishi mumkin."),
  _NameItem('True', _V.error, "`True` — kalit so'z (qiymat). Unga qiymat berib bo'lmaydi."),
  _NameItem('FoydalanuvchiIsmi', _V.bad, "PascalCase klass nomlari uchun. O'zgaruvchiga — snake_case."),
  _NameItem('shahar_nomi', _V.good, "To'g'ri va tushunarli."),
  _NameItem('print', _V.bad, "Ishlaydi, lekin keyin `print()` bilan hech narsa chiqara olmaysiz!"),
  _NameItem('yosh', _V.good, "Qisqa va ma'noli."),
];

class NameGameScreen extends StatefulWidget {
  final Lesson lesson;
  const NameGameScreen({super.key, required this.lesson});
  @override
  State<NameGameScreen> createState() => _NameGameScreenState();
}

class _NameGameScreenState extends State<NameGameScreen> {
  late List<_NameItem> _deck;
  int _i = 0;
  int _score = 0;
  _V? _picked;
  int _shake = 0;
  final _focus = FocusNode();

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

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _pick(_V v) {
    if (_picked != null) return;
    setState(() {
      _picked = v;
      if (v == _deck[_i].verdict) {
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
      final first = ProgressScope.read(context).complete('${widget.lesson.id}.lab.nameGame', xpReward: 25);
      if (first) showRewards(context, message: '+25 XP');
    }
    await showLabResult(context,
        emoji: pct >= 0.7 ? '🏷️' : '📚',
        title: '$_score / ${_deck.length}',
        text: pct >= 0.7
            ? "Siz endi nomlash qoidalarini a'lo bilasiz!"
            : "70% dan kam. Nomlash qoidalari bo'limini qayta ko'rib, yana urinib ko'ring.",
        color: widget.lesson.color);
    if (mounted) setState(_reset);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final it = _deck[_i];
    final answered = _picked != null;
    final ok = _picked == it.verdict;
    return Scaffold(
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: (n, e) {
          if (e is! KeyDownEvent) return KeyEventResult.ignored;
          final map = {LogicalKeyboardKey.digit1: _V.good, LogicalKeyboardKey.digit2: _V.bad, LogicalKeyboardKey.digit3: _V.error};
          if (map.containsKey(e.logicalKey)) {
            _pick(map[e.logicalKey]!);
            return KeyEventResult.handled;
          }
          if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.space) {
            _next();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(children: [
          TopBar(
            title: '🏷️ Nom tekshiruvchi',
            subtitle: "Bu nom to'g'rimi, yomonmi yoki xato beradimi?   •   klaviatura: 1, 2, 3, Enter",
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
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: Container(
                          key: ValueKey(_i),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 34),
                          decoration: BoxDecoration(
                            color: C.code,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: answered ? (ok ? C.green : C.red) : l.color.withValues(alpha: 0.6), width: 2.5),
                          ),
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(text: it.name, style: const TextStyle(color: C.yellow)),
                              const TextSpan(text: ' = ', style: TextStyle(color: C.pink)),
                              const TextSpan(text: '42', style: TextStyle(color: C.blue)),
                            ]),
                            style: const TextStyle(fontFamily: mono, fontSize: 44, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(children: [
                      Expanded(child: _choice('1', '✅', "To'g'ri va chiroyli", C.green, _V.good, it)),
                      const SizedBox(width: 14),
                      Expanded(child: _choice('2', '⚠️', 'Ishlaydi, lekin yomon', C.yellow, _V.bad, it)),
                      const SizedBox(width: 14),
                      Expanded(child: _choice('3', '❌', 'Xato beradi', C.red, _V.error, it)),
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
                                Expanded(child: MdText(it.why, style: body().copyWith(fontSize: 17))),
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

  Widget _choice(String key, String emoji, String label, Color c, _V v, _NameItem it) {
    final answered = _picked != null;
    final isRight = v == it.verdict;
    final isPicked = _picked == v;
    return GestureDetector(
      onTap: () => _pick(v),
      child: MouseRegion(
        cursor: answered ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            color: answered && isRight ? c.withValues(alpha: 0.28) : c.withValues(alpha: answered && !isPicked ? 0.04 : 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: answered && isRight ? c : c.withValues(alpha: isPicked ? 1 : 0.4), width: 2),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: h3(c).copyWith(fontSize: 16)),
            Text('[$key]', style: small(C.faint)),
          ]),
        ),
      ),
    );
  }
}
