import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/lessons.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/code_highlight.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';

/// Leitner tizimidagi flesh-kartalar bilan takrorlash.
class ReviewScreen extends StatefulWidget {
  final bool embedded;
  const ReviewScreen({super.key, this.embedded = false});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<String>? _session;
  int _i = 0;
  bool _flipped = false;
  int _good = 0;
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _start(List<String> ids) {
    setState(() {
      _session = (List.of(ids)..shuffle(math.Random())).take(20).toList();
      _i = 0;
      _flipped = false;
      _good = 0;
    });
    _focus.requestFocus();
  }

  void _answer(bool ok) {
    final s = _session;
    if (s == null || !_flipped) return;
    ProgressScope.read(context).answerCard(s[_i], ok);
    setState(() {
      if (ok) _good++;
      _i++;
      _flipped = false;
    });
    if (_i >= s.length) showRewards(context);
  }

  KeyEventResult _onKey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent || _session == null || _i >= _session!.length) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.space || e.logicalKey == LogicalKeyboardKey.enter) {
      setState(() => _flipped = !_flipped);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.digit1 || e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _answer(false);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.digit2 || e.logicalKey == LogicalKeyboardKey.arrowRight) {
      _answer(true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final s = _session;
    Widget body;
    if (s != null && _i < s.length) {
      body = _cardView(s[_i], s.length);
    } else if (s != null) {
      body = _doneView(s.length);
    } else {
      body = _overview(p);
    }
    final content = Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: SingleChildScrollView(padding: const EdgeInsets.all(30), child: Centered(maxWidth: 980, child: body)),
    );
    if (widget.embedded) return content;
    return Scaffold(body: Column(children: [const TopBar(title: '🔁 Takrorlash', color: C.cyan), Expanded(child: content)]));
  }

  Widget _overview(Progress p) {
    final due = p.dueCards();
    final boxes = List.filled(leitnerDays.length, 0);
    for (final c in p.cards.values) {
      boxes[c.box]++;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('🔁 Takrorlash', style: h1()), const Spacer(), const XpBadge()]),
      const SizedBox(height: 8),
      Text("Flesh-kartalar Leitner tizimida ishlaydi: esladingiz — karta keyingi qutiga o'tadi va kamroq so'raladi; "
          "unutdingiz — birinchi qutiga qaytadi. Bu ilmiy asoslangan \"oraliqli takrorlash\" usuli.",
          style: body(C.dim)),
      const SizedBox(height: 22),
      Panel(
        padding: const EdgeInsets.all(26),
        gradient: LinearGradient(colors: [C.cyan.withValues(alpha: 0.18), C.violet.withValues(alpha: 0.18)]),
        child: Row(children: [
          Text(due.isEmpty ? '✅' : '🃏', style: const TextStyle(fontSize: 60)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                p.cards.isEmpty
                    ? "Hali kartalar yo'q"
                    : (due.isEmpty ? "Bugungi takrorlash bajarildi!" : "${due.length} ta karta sizni kutyapti"),
                style: h2(),
              ),
              const SizedBox(height: 4),
              Text(
                p.cards.isEmpty
                    ? "Darslarning nazariya qismini tugatsangiz, kartalar avtomatik qo'shiladi."
                    : (due.isEmpty
                        ? "Keyingi kartalar belgilangan kunda qaytadi. Xohlasangiz, hozir ham mashq qilishingiz mumkin."
                        : "Bo'sh joy — Space, bilmadim — 1, esladim — 2"),
                style: body(C.dim),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          if (due.isNotEmpty)
            BigButton('Boshlash', icon: Icons.play_arrow_rounded, color: C.cyan, color2: C.blue, onTap: () => _start(due))
          else if (p.cards.isNotEmpty)
            BigButton('Mashq qilish', icon: Icons.fitness_center_rounded, color: C.cyan, outlined: true,
                onTap: () => _start(p.cards.keys.toList()))
          else
            BigButton("Barcha kartalarni qo'shish", icon: Icons.add_rounded, color: C.cyan, outlined: true, onTap: p.enrollAll),
        ]),
      ),
      const SizedBox(height: 26),
      Text('📦 Leitner qutilari', style: h2()),
      const SizedBox(height: 12),
      Row(children: [
        for (int b = 0; b < boxes.length; b++)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color.lerp(C.red, C.green, b / 5)!.withValues(alpha: 0.5)),
              ),
              child: Column(children: [
                Text('${b + 1}-quti', style: small()),
                const SizedBox(height: 6),
                Text('${boxes[b]}', style: h1(Color.lerp(C.red, C.green, b / 5)!)),
                Text(leitnerDays[b] == 0 ? 'bugun' : 'har ${leitnerDays[b]} kunda', style: small(C.faint).copyWith(fontSize: 12)),
              ]),
            ),
          ),
      ]),
      const SizedBox(height: 26),
      Panel(
        child: Row(children: [
          SizedBox(width: 320, height: 170, child: CustomPaint(painter: _CurvePainter())),
          const SizedBox(width: 24),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🧠 Nega takrorlash kerak?', style: h3()),
              const SizedBox(height: 8),
              MdText(
                "Olim **Ebbinghaus** aniqlagan: yangi bilimning ~**70%** bir kunda unutiladi (qizil chiziq). "
                "Lekin har bir takrorlash xotirani mustahkamlaydi va unutish sekinlashadi (yashil chiziqlar). "
                "5–6 ta to'g'ri vaqtdagi takrorlashdan keyin bilim **yillar** davomida saqlanadi!",
                style: body().copyWith(fontSize: 15.5),
              ),
            ]),
          ),
        ]),
      ),
    ]);
  }

  Widget _cardView(String id, int total) {
    final entry = allCards[id]!;
    final (lesson, card) = entry;
    return Column(children: [
      Row(children: [
        Text('Karta ${_i + 1} / $total', style: h3()),
        const SizedBox(width: 12),
        Expanded(child: ProgressBar(_i / total, color: C.cyan)),
        const SizedBox(width: 12),
        TextButton(onPressed: () => setState(() => _session = null), child: const Text('Tugatish')),
      ]),
      const SizedBox(height: 26),
      GestureDetector(
        onTap: () => setState(() => _flipped = !_flipped),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _flipped ? 1 : 0),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOutCubic,
            builder: (_, v, _) {
              final front = v < 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(v * math.pi),
                child: front
                    ? _face(lesson.color, lesson.emoji, 'SAVOL', card.front, card.frontCode, false)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationX(math.pi),
                        child: _face(C.green, '💡', 'JAVOB', card.back, card.backCode, true),
                      ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 26),
      AnimatedOpacity(
        opacity: _flipped ? 1 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          BigButton('Bilmadim  (1)', icon: Icons.replay_rounded, color: C.red, color2: const Color(0xFFDC2626),
              onTap: _flipped ? () => _answer(false) : null),
          const SizedBox(width: 18),
          BigButton('Esladim  (2)', icon: Icons.check_rounded, color: C.green, color2: const Color(0xFF059669),
              onTap: _flipped ? () => _answer(true) : null),
        ]),
      ),
      const SizedBox(height: 12),
      if (!_flipped) Text("Avval javobni o'zingiz eslang, keyin kartani bosing (Space)", style: small()),
    ]);
  }

  Widget _face(Color color, String emoji, String label, String text, String? code, bool back) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.35), C.card],
        ),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Text(emoji, style: const TextStyle(fontSize: 26)), const Spacer(), Pill(label, color: color)]),
        const SizedBox(height: 24),
        if (text.isNotEmpty) MdText(text, style: h2().copyWith(fontSize: 26), align: TextAlign.center),
        if (code != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: C.code, borderRadius: BorderRadius.circular(14)),
            child: CodeView(code, fontSize: 19, lineNumbers: false),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _doneView(int total) {
    return Column(children: [
      const SizedBox(height: 30),
      const Text('🌟', style: TextStyle(fontSize: 90)),
      Text('Takrorlash tugadi!', style: h1()),
      const SizedBox(height: 10),
      Text('$total tadan $_good tasini esladingiz. Xotirangiz mustahkamlanmoqda 💪', style: body(C.dim).copyWith(fontSize: 18)),
      const SizedBox(height: 24),
      BigButton('Yaxshi', icon: Icons.check_rounded, color: C.cyan, color2: C.blue, onTap: () => setState(() => _session = null)),
    ]);
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = C.faint
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axis);
    canvas.drawLine(Offset.zero, Offset(0, size.height), axis);
    // takrorlashsiz unutish
    final red = Path()..moveTo(0, 0);
    for (double x = 0; x <= size.width; x += 2) {
      final t = x / size.width * 30;
      red.lineTo(x, size.height * (1 - math.exp(-t / 1.2) * 0.85 - 0.15 * math.exp(-t / 20)));
    }
    canvas.drawPath(red, Paint()
      ..color = C.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    // takrorlashlar bilan
    final reviews = [0.0, 1, 3, 7, 16];
    final green = Path();
    for (int k = 0; k < reviews.length; k++) {
      final start = reviews[k].toDouble();
      final end = k + 1 < reviews.length ? reviews[k + 1].toDouble() : 30.0;
      final strength = 1.2 * math.pow(2.6, k);
      for (double t = start; t <= end; t += 0.1) {
        final x = t / 30 * size.width;
        final y = size.height * (1 - math.exp(-(t - start) / strength));
        if (t == start) {
          green.moveTo(x, 0);
        } else {
          green.lineTo(x, y * 0.9);
        }
      }
    }
    canvas.drawPath(green, Paint()
      ..color = C.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    final tp = TextPainter(
      text: const TextSpan(text: 'vaqt →', style: TextStyle(color: C.faint, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width - tp.width, size.height + 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
