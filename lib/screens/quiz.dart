import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/lessons.dart';
import '../data/models.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/code_highlight.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';
import 'certificate.dart';
import 'theory.dart' show OptionButton, OptState;

class _Q {
  final QuizQ q;
  final List<int> order; // ko'rsatiladigan tartib -> asl indeks
  final Lesson lesson;
  _Q(this.q, this.order, this.lesson);
  int get correctShown => order.indexOf(q.correct);
}

class QuizScreen extends StatefulWidget {
  final Lesson? lesson;
  const QuizScreen._(this.lesson);
  factory QuizScreen.lesson(Lesson l) => QuizScreen._(l);
  factory QuizScreen.exam() => const QuizScreen._(null);

  bool get isExam => lesson == null;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _rnd = math.Random();
  late List<_Q> _qs;
  int _i = 0;
  int? _picked;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _shake = 0;
  bool _finished = false;
  final List<_Q> _wrong = [];
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _Q mk(QuizQ q, Lesson l) {
      final order = List.generate(q.options.length, (i) => i)..shuffle(_rnd);
      return _Q(q, order, l);
    }

    if (widget.isExam) {
      final pool = <_Q>[];
      final per = [7, 7, 6];
      for (int k = 0; k < lessons.length; k++) {
        final qs = List.of(lessons[k].quiz)..shuffle(_rnd);
        pool.addAll(qs.take(per[k]).map((q) => mk(q, lessons[k])));
      }
      pool.shuffle(_rnd);
      _qs = pool;
    } else {
      _qs = (List.of(widget.lesson!.quiz)..shuffle(_rnd)).map((q) => mk(q, widget.lesson!)).toList();
    }
    _i = 0;
    _picked = null;
    _score = 0;
    _combo = 0;
    _bestCombo = 0;
    _finished = false;
    _wrong.clear();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Color get _color => widget.lesson?.color ?? C.yellow;
  Color get _color2 => widget.lesson?.color2 ?? C.orange;

  void _pick(int shown) {
    if (_picked != null || _finished) return;
    final q = _qs[_i];
    setState(() {
      _picked = shown;
      if (shown == q.correctShown) {
        _score++;
        _combo++;
        _bestCombo = math.max(_bestCombo, _combo);
      } else {
        _combo = 0;
        _shake++;
        _wrong.add(q);
      }
    });
  }

  void _next() {
    if (_picked == null) return;
    if (_i == _qs.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _i++;
      _picked = null;
    });
  }

  void _finish() {
    final p = ProgressScope.read(context);
    final pct = (_score * 100 / _qs.length).round();
    final bonus = _score * 4 + (_bestCombo >= 5 ? 10 : 0);
    if (widget.isExam) {
      p.recordExam(pct);
    } else {
      p.recordQuiz(widget.lesson!.id, pct);
      p.enrollCards(widget.lesson!);
    }
    p.addXp(bonus);
    // Xato qilingan mavzular kartalari zudlik bilan takrorlashga qaytadi.
    for (final w in _wrong) {
      p.enrollCards(w.lesson);
    }
    setState(() => _finished = true);
    showRewards(context, message: '+$bonus XP');
  }

  KeyEventResult _onKey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent || _finished) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final digits = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3, LogicalKeyboardKey.digit4];
    final idx = digits.indexOf(k);
    if (idx >= 0 && idx < _qs[_i].q.options.length) {
      _pick(idx);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
      _next();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isExam ? '🎓 Katta imtihon' : '📝 ${widget.lesson!.title} — yakuniy test';
    return Scaffold(
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: ConfettiOverlay(
          play: _finished && _score / _qs.length >= 0.6,
          child: Column(children: [
            TopBar(
              title: title,
              subtitle: _finished ? 'Natijalar' : 'Savol ${_i + 1} / ${_qs.length}   •   klaviatura: 1–4, Enter',
              color: _color,
              progress: _finished ? 1 : (_i + (_picked != null ? 1 : 0)) / _qs.length,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Centered(maxWidth: 860, child: _finished ? _results() : _question()),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _question() {
    final q = _qs[_i];
    final answered = _picked != null;
    final ok = _picked == q.correctShown;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Pill('${_i + 1}-savol', color: _color),
        if (widget.isExam) ...[const SizedBox(width: 8), Pill('${q.lesson.emoji} ${q.lesson.title}', color: q.lesson.color)],
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: _combo >= 2
              ? Pill('🔥 ${_combo}x kombo!', key: ValueKey(_combo), color: C.orange)
              : const SizedBox(key: ValueKey(0)),
        ),
        const SizedBox(width: 8),
        Pill('✅ $_score', color: C.green),
      ]),
      const SizedBox(height: 22),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey(_i),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MdText(q.q.question, style: h2().copyWith(fontSize: 26)),
            if (q.q.code != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: C.code, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
                child: CodeView(q.q.code!, fontSize: 17),
              ),
            ],
            const SizedBox(height: 22),
            Shake(
              trigger: _shake,
              child: Column(children: [
                for (int s = 0; s < q.order.length; s++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OptionButton(
                      text: q.q.options[q.order[s]],
                      prefix: '${s + 1}',
                      expand: true,
                      state: !answered
                          ? OptState.idle
                          : (s == q.correctShown ? OptState.correct : (s == _picked ? OptState.wrong : OptState.dim)),
                      onTap: answered ? null : () => _pick(s),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: answered
            ? Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: (ok ? C.green : C.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (ok ? C.green : C.orange).withValues(alpha: 0.4)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ok ? '🎉' : '🧐', style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ok ? ["Barakalla!", "Aynan shunday!", "Zo'r!", "Ofarin!"][_i % 4] : "Bu safar emas — lekin endi eslab qolasiz:",
                          style: h3(ok ? C.green : C.orange)),
                      const SizedBox(height: 4),
                      MdText(q.q.explain, style: body().copyWith(fontSize: 16)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  BigButton(_i == _qs.length - 1 ? 'Natija' : 'Keyingi', icon: Icons.arrow_forward_rounded, color: _color,
                      color2: _color2, onTap: _next),
                ]),
              )
            : const SizedBox(width: double.infinity),
      ),
    ]);
  }

  Widget _results() {
    final pct = (_score * 100 / _qs.length).round();
    final passed = widget.isExam ? pct >= 70 : pct >= 60;
    final stars = pct >= 100 ? 3 : (pct >= 80 ? 2 : (pct >= 60 ? 1 : 0));
    final verdict = pct == 100
        ? 'Mukammal! Siz haqiqiy Python ustasisiz! 🏆'
        : pct >= 80
            ? "A'lo natija! Yana ozgina — va 100% sizniki! 🌟"
            : pct >= 60
                ? "Yaxshi! Xatolarni ko'rib chiqing — ular endi takrorlash kartalarida 🔁"
                : "Hali ozgina mashq kerak. Nazariyani qayta ko'rib, yana urinib ko'ring 💪";
    return Column(children: [
      Text(passed ? '🏆' : '📚', style: const TextStyle(fontSize: 90)),
      const SizedBox(height: 6),
      TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: pct),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => Text('$v%', style: h1(passed ? C.green : C.orange).copyWith(fontSize: 72)),
      ),
      Text('$_score / ${_qs.length} to\'g\'ri javob   •   eng uzun kombo: $_bestCombo', style: body(C.dim)),
      const SizedBox(height: 12),
      if (!widget.isExam)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 0; i < 3; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + i * 250),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 64, color: i < stars ? C.yellow : C.faint),
            ),
        ]),
      const SizedBox(height: 12),
      Text(verdict, style: h3(), textAlign: TextAlign.center),
      if (widget.isExam && passed) ...[
        const SizedBox(height: 20),
        BigButton('Sertifikatni olish', icon: Icons.workspace_premium_rounded, color: C.yellow, color2: C.orange,
            onTap: () => Navigator.of(context).pushReplacement(fadeRoute(const CertificateScreen()))),
      ] else if (widget.isExam) ...[
        const SizedBox(height: 8),
        Text("Sertifikat uchun kamida 70% kerak.", style: body(C.dim)),
      ],
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        BigButton('Qayta urinish', icon: Icons.refresh_rounded, color: _color, outlined: true,
            onTap: () => setState(_build)),
        const SizedBox(width: 14),
        BigButton('Tayyor', icon: Icons.check_rounded, color: _color, color2: _color2, onTap: () => Navigator.of(context).pop()),
      ]),
      if (_wrong.isNotEmpty) ...[
        const SizedBox(height: 36),
        Align(alignment: Alignment.centerLeft, child: Text('🔍 Xatolar ustida ishlash', style: h2())),
        const SizedBox(height: 12),
        for (final w in _wrong)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              MdText(w.q.question, style: h3().copyWith(fontSize: 16.5)),
              if (w.q.code != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: C.code, borderRadius: BorderRadius.circular(10)),
                  child: CodeView(w.q.code!, fontSize: 14, lineNumbers: false),
                ),
              ],
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.check_circle_rounded, color: C.green, size: 18),
                const SizedBox(width: 8),
                Expanded(child: MdText(w.q.options[w.q.correct], style: body(C.green).copyWith(fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 4),
              MdText(w.q.explain, style: body(C.dim).copyWith(fontSize: 15)),
            ]),
          ),
      ],
    ]);
  }
}
