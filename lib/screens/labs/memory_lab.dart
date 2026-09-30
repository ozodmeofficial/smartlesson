import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../services/progress.dart';
import '../../services/runner.dart';
import '../../theme.dart';
import '../../widgets/code_highlight.dart';
import '../../widgets/code_widgets.dart';
import '../../widgets/common.dart';
import '../../widgets/md_text.dart';

class _Obj {
  final String key, type, repr;
  final int id;
  final bool cached; // kichik sonlar keshda qoladi
  const _Obj(this.key, this.type, this.repr, this.id, {this.cached = false});
}

class _Step {
  final int line; // 0 dan
  final Map<String, String> vars; // nom -> obyekt kaliti
  final String note;
  const _Step(this.line, this.vars, this.note);
}

class _Scenario {
  final String title;
  final String code;
  final String realCode; // haqiqiy Python'da tekshirish uchun
  final List<_Obj> objs;
  final List<_Step> steps;
  const _Scenario(this.title, this.code, this.realCode, this.objs, this.steps);
}

const _scenarios = <_Scenario>[
  _Scenario(
    "🏷️ Yorliq ko'chishi",
    'ism = "Ali"\nism = "Vali"\nyosh = 10\nyosh = 20',
    'ism = "Ali"\nprint(id(ism))\nism = "Vali"\nprint(id(ism))\nyosh = 10\nprint(id(yosh))\nyosh = 20\nprint(id(yosh))',
    [
      _Obj('ali', 'str', '"Ali"', 4378214448),
      _Obj('vali', 'str', '"Vali"', 4378214512),
      _Obj('10', 'int', '10', 4374826384, cached: true),
      _Obj('20', 'int', '20', 4374826704, cached: true),
    ],
    [
      _Step(0, {'ism': 'ali'}, 'Xotirada **"Ali"** obyekti yaratildi va unga **ism** yorlig\'i yopishtirildi.'),
      _Step(1, {'ism': 'vali'},
          "Yangi obyekt **\"Vali\"** yaratildi va yorliq **unga ko'chdi**. \"Ali\" ga endi hech kim qaramaydi — **garbage collector** uni olib ketadi 🧹"),
      _Step(2, {'ism': 'vali', 'yosh': '10'}, "**yosh** yorlig'i 10 soniga yopishdi. id: 4374826384"),
      _Step(3, {'ism': 'vali', 'yosh': '20'},
          "yosh endi **20** ga qaraydi — `id(yosh)` o'zgardi (4374826704). 10 soni esa o'chmaydi: kichik sonlar Python **keshida** doim turadi."),
    ],
  ),
  _Scenario(
    '🪞 b = a — nusxami?',
    'a = 10\nb = a\na = 99\nprint(b)',
    'a = 10\nb = a\nprint(a is b)\na = 99\nprint(b)\nprint(a is b)',
    [
      _Obj('10', 'int', '10', 4374826384, cached: true),
      _Obj('99', 'int', '99', 4374829232, cached: true),
    ],
    [
      _Step(0, {'a': '10'}, "**a** yorlig'i 10 ga yopishdi."),
      _Step(1, {'a': '10', 'b': '10'},
          "`b = a` — nusxa olinmaydi! **b** ham xuddi **o'sha** obyektga qaraydi. `a is b` → True"),
      _Step(2, {'a': '99', 'b': '10'}, "Faqat **a** ning yorlig'i 99 ga ko'chdi. **b** joyida qoldi."),
      _Step(3, {'a': '99', 'b': '10'}, "Shuning uchun `print(b)` → **10**. Mashhur xato №5 ning siri shu!"),
    ],
  ),
  _Scenario(
    '🔄 a, b = b, a',
    'a = "choy"\nb = "sharbat"\na, b = b, a',
    'a = "choy"\nb = "sharbat"\nprint(id(a), id(b))\na, b = b, a\nprint(id(a), id(b))\nprint(a, b)',
    [
      _Obj('choy', 'str', '"choy"', 4378214448),
      _Obj('sharbat', 'str', '"sharbat"', 4378214512),
    ],
    [
      _Step(0, {'a': 'choy'}, '**a** → "choy"'),
      _Step(1, {'a': 'choy', 'b': 'sharbat'}, '**b** → "sharbat"'),
      _Step(2, {'a': 'sharbat', 'b': 'choy'},
          "Python avval o'ng tomonni `(b, a)` hisobladi, keyin yorliqlarni **almashtirdi**. Obyektlar joyidan qimirlamadi — faqat o'qlar kesishdi! ✨"),
    ],
  ),
  _Scenario(
    '♻️ Kichik sonlar keshi',
    'a = 100\nb = 100\nc = 1000\nd = int("1000")',
    'a = 100\nb = 100\nprint(a is b)\nc = 1000\nd = int("1000")\nprint(c is d)\nprint(c == d)',
    [
      _Obj('100', 'int', '100', 4374829264, cached: true),
      _Obj('1000a', 'int', '1000', 4378214640),
      _Obj('1000b', 'int', '1000', 4378214704),
    ],
    [
      _Step(0, {'a': '100'}, "**a** → 100 (id 4374829264)"),
      _Step(1, {'a': '100', 'b': '100'},
          "**b** ham **o'sha** 100 ga qaraydi! −5…256 oralig'idagi sonlar Python'da bittadan saqlanadi. `a is b` → True"),
      _Step(2, {'a': '100', 'b': '100', 'c': '1000a'}, "1000 — katta son, u uchun yangi obyekt yaratildi."),
      _Step(3, {'a': '100', 'b': '100', 'c': '1000a', 'd': '1000b'},
          "Hisoblash natijasida yana bir 1000 yaratildi — **boshqa** obyekt! `c == d` → True (qiymat teng), lekin `c is d` → False (manzil boshqa)."),
    ],
  ),
  _Scenario(
    '🗑️ del va axlat yig\'uvchi',
    'v = "keraksiz"\nw = v\ndel v\ndel w',
    'v = "keraksiz"\nw = v\ndel v\nprint(w)\ndel w\nprint("w ham o\'chdi")',
    [_Obj('k', 'str', '"keraksiz"', 4378214448)],
    [
      _Step(0, {'v': 'k'}, '**v** → "keraksiz"'),
      _Step(1, {'v': 'k', 'w': 'k'}, 'Endi obyektga **ikkita** yorliq qaraydi.'),
      _Step(2, {'w': 'k'}, "`del v` faqat **yorliqni** o'chirdi. Obyekt tirik — unga hali **w** qaraydi."),
      _Step(3, {}, "Oxirgi yorliq ham o'chdi. Endi obyektga hech kim qaramaydi → **garbage collector** uni xotiradan tozalaydi 🧹"),
    ],
  ),
  _Scenario(
    '➕ += va id()',
    'ball = 0\nball += 10\nball += 5\nball -= 15',
    'ball = 0\nprint(ball, id(ball))\nball += 10\nprint(ball, id(ball))\nball += 5\nprint(ball, id(ball))\nball -= 15\nprint(ball, id(ball))',
    [
      _Obj('0', 'int', '0', 4374826064, cached: true),
      _Obj('10', 'int', '10', 4374826384, cached: true),
      _Obj('15', 'int', '15', 4374826544, cached: true),
    ],
    [
      _Step(0, {'ball': '0'}, '**ball** → 0'),
      _Step(1, {'ball': '10'}, "`ball += 10` sonni \"ichidan\" o'zgartirmaydi — **yangi** obyekt 10 ga ko'chadi. id o'zgardi!"),
      _Step(2, {'ball': '15'}, 'Yana yangi obyekt: 15.'),
      _Step(3, {'ball': '0'}, "Qiziq: 15 − 15 = 0 → yorliq **eski 0** obyektiga qaytdi. id ham boshidagidek! (kesh tufayli)"),
    ],
  ),
];

class MemoryLabScreen extends StatefulWidget {
  final Lesson lesson;
  const MemoryLabScreen({super.key, required this.lesson});
  @override
  State<MemoryLabScreen> createState() => _MemoryLabScreenState();
}

class _MemoryLabScreenState extends State<MemoryLabScreen> {
  int _sc = 0;
  int _step = -1;
  Timer? _auto;
  final Set<int> _seen = {};
  RunState _runState = RunState.idle;
  RunResult? _result;

  _Scenario get s => _scenarios[_sc];

  @override
  void dispose() {
    _auto?.cancel();
    super.dispose();
  }

  void _select(int i) {
    _auto?.cancel();
    setState(() {
      _sc = i;
      _step = -1;
      _runState = RunState.idle;
      _result = null;
    });
  }

  void _forward() {
    if (_step >= s.steps.length - 1) {
      _auto?.cancel();
      _auto = null;
      return;
    }
    setState(() => _step++);
    if (_step == s.steps.length - 1 && _seen.add(_sc) && _seen.length >= 3) {
      final first = ProgressScope.read(context).complete('${widget.lesson.id}.lab.memoryLab', xpReward: 25);
      if (first) showRewards(context, message: '+25 XP — laboratoriya tajribalari bajarildi! 🔬');
    }
  }

  void _play() {
    _auto?.cancel();
    if (_step >= s.steps.length - 1) setState(() => _step = -1);
    _auto = Timer.periodic(const Duration(milliseconds: 1800), (_) => _forward());
    _forward();
  }

  Future<void> _runReal() async {
    setState(() => _runState = RunState.running);
    final r = await CodeRunner.run(s.realCode);
    if (!mounted) return;
    setState(() {
      _runState = RunState.done;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final step = _step >= 0 ? s.steps[_step] : null;
    final prev = _step > 0 ? s.steps[_step - 1] : null;
    return Scaffold(
      body: Column(children: [
        TopBar(
          title: '🔬 Xotira laboratoriyasi',
          subtitle: "O'zgaruvchi — quti emas, yorliq! Qadamma-qadam ko'ring (kamida 3 ta tajribani oxirigacha o'tkazing)",
          color: l.color,
          progress: _seen.length / 3,
        ),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 270,
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: C.border))),
              child: ListView(padding: const EdgeInsets.all(12), children: [
                for (int i = 0; i < _scenarios.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: i == _sc ? l.color.withValues(alpha: 0.22) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(_scenarios[i].title, style: TextStyle(fontWeight: i == _sc ? FontWeight.w900 : FontWeight.w600)),
                        trailing: _seen.contains(i) ? const Icon(Icons.check_circle_rounded, color: C.green, size: 20) : null,
                        onTap: () => _select(i),
                      ),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(26),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: 340,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Panel(
                          color: C.code,
                          child: CodeView(s.code, fontSize: 17, highlightLine: step == null ? null : step.line + 1),
                        ),
                        const SizedBox(height: 14),
                        Row(children: [
                          IconButton.filledTonal(
                            onPressed: _step >= 0 ? () => setState(() => _step--) : null,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BigButton(
                              _step < 0 ? 'Boshlash' : (_step >= s.steps.length - 1 ? 'Qaytadan' : 'Keyingi qadam'),
                              icon: Icons.play_arrow_rounded,
                              color: l.color,
                              color2: l.color2,
                              compact: true,
                              onTap: () {
                                _auto?.cancel();
                                if (_step >= s.steps.length - 1) {
                                  setState(() => _step = -1);
                                } else {
                                  _forward();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'Avtomatik',
                            onPressed: _play,
                            icon: const Icon(Icons.slow_motion_video_rounded),
                          ),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 24),
                    Expanded(child: _MemoryCanvas(scenario: s, step: step, prev: prev)),
                  ]),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Panel(
                      key: ValueKey('$_sc-$_step'),
                      borderColor: l.color.withValues(alpha: 0.5),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('🐍', style: TextStyle(fontSize: 30)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MdText(
                            step?.note ?? "«Boshlash» tugmasini bosing — kod qatorma-qator bajariladi va xotirada nima bo'layotganini ko'rasiz.",
                            style: body().copyWith(fontSize: 17),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    Text("Haqiqiy Python'da tekshiring:", style: h3()),
                    const SizedBox(width: 12),
                    BigButton('id() larni ko\'rish', icon: Icons.play_arrow_rounded, color: C.green, compact: true,
                        onTap: _runState == RunState.running ? null : _runReal),
                  ]),
                  const SizedBox(height: 10),
                  if (_runState != RunState.idle) ...[
                    Panel(color: C.code, padding: const EdgeInsets.all(14), child: CodeView(s.realCode, fontSize: 14)),
                    const SizedBox(height: 10),
                    ConsoleView(state: _runState, result: _result),
                    const SizedBox(height: 6),
                    Text("Eslatma: id() raqamlari har bir kompyuterda boshqacha bo'ladi — muhimi, qaysilari teng va qaysilari farq qilishi.",
                        style: small(C.faint)),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MemoryCanvas extends StatelessWidget {
  final _Scenario scenario;
  final _Step? step;
  final _Step? prev;
  const _MemoryCanvas({required this.scenario, required this.step, required this.prev});

  static const rowH = 84.0;
  static const nameW = 130.0;
  static const objW = 220.0;

  @override
  Widget build(BuildContext context) {
    final cur = step?.vars ?? const <String, String>{};
    final before = prev?.vars ?? const <String, String>{};
    final curIdx = step == null ? -1 : scenario.steps.indexOf(step!);
    // Hozirgacha paydo bo'lgan nomlar (tartib bilan)
    final names = <String>[];
    for (int i = 0; i <= curIdx; i++) {
      for (final n in scenario.steps[i].vars.keys) {
        if (!names.contains(n)) names.add(n);
      }
    }
    final seenObjs = <String>{};
    for (int i = 0; i <= curIdx; i++) {
      seenObjs.addAll(scenario.steps[i].vars.values);
    }
    final referenced = cur.values.toSet();
    final visible = scenario.objs
        .where((o) => referenced.contains(o.key) || before.values.contains(o.key) || (o.cached && seenObjs.contains(o.key)))
        .toList();
    final rows = [names.length, visible.length, 1].reduce((a, b) => a > b ? a : b);
    return Container(
      height: rows * rowH + 60,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final objX = c.maxWidth - objW;
        double yName(String n) => names.indexOf(n) * rowH + rowH / 2;
        double yObj(String k) => visible.indexWhere((o) => o.key == k) * rowH + rowH / 2;
        final arrows = <(double, double)>[];
        for (final e in cur.entries) {
          arrows.add((yName(e.key), yObj(e.value)));
        }
        return Stack(children: [
          Positioned(left: 0, top: -4, child: Text('NOMLAR (yorliqlar)', style: small(C.faint).copyWith(letterSpacing: 1.2, fontSize: 12))),
          Positioned(right: 0, top: -4, child: Text('XOTIRA (obyektlar)', style: small(C.faint).copyWith(letterSpacing: 1.2, fontSize: 12))),
          Positioned.fill(
            top: 20,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(step),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (_, t, _) => CustomPaint(
                painter: _ArrowPainter(
                  arrows: [
                    for (final e in cur.entries)
                      (
                        yName(e.key),
                        before.containsKey(e.key) && visible.any((o) => o.key == before[e.key]) && before[e.key] != e.value
                            ? yObj(before[e.key]!) + (yObj(e.value) - yObj(before[e.key]!)) * t
                            : yObj(e.value),
                        before[e.key] != e.value,
                      ),
                  ],
                  x1: nameW,
                  x2: objX,
                  progress: t,
                ),
              ),
            ),
          ),
          for (final n in names)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: 0,
              top: 20 + names.indexOf(n) * rowH + rowH / 2 - 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: cur.containsKey(n) ? 1 : 0.18,
                child: _NameChip(n, deleted: !cur.containsKey(n)),
              ),
            ),
          for (final o in visible)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              left: objX,
              top: 20 + visible.indexOf(o) * rowH + rowH / 2 - 35,
              child: _ObjBox(o, orphan: !referenced.contains(o.key)),
            ),
        ]);
      }),
    );
  }
}

class _NameChip extends StatelessWidget {
  final String name;
  final bool deleted;
  const _NameChip(this.name, {this.deleted = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _MemoryCanvas.nameW,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: C.yellow,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(24), right: Radius.circular(8)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF3F2E00), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(name,
            style: TextStyle(
                fontFamily: mono,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: const Color(0xFF3F2E00),
                decoration: deleted ? TextDecoration.lineThrough : null)),
      ]),
    );
  }
}

class _ObjBox extends StatelessWidget {
  final _Obj o;
  final bool orphan;
  const _ObjBox(this.o, {required this.orphan});
  @override
  Widget build(BuildContext context) {
    final c = C.forType(o.type);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: orphan ? 0.4 : 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          width: _MemoryCanvas.objW,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c, width: 2),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text.rich(TextSpan(children: highlightSpans(o.repr)), style: codeStyle(size: 18).copyWith(fontWeight: FontWeight.w700, height: 1.25)),
                Text('id ${o.id}', style: TextStyle(fontFamily: mono, fontSize: 11.5, color: C.dim)),
              ]),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(o.type, style: TextStyle(color: c, fontWeight: FontWeight.w900, height: 1.2)),
              if (orphan) Text(o.cached ? '♻️ keshda' : '🗑️ GC', style: small(C.faint).copyWith(fontSize: 11.5, height: 1.2)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final List<(double, double, bool)> arrows; // (yName, yObj, o'zgardimi)
  final double x1, x2, progress;
  _ArrowPainter({required this.arrows, required this.x1, required this.x2, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final (y1, y2, changed) in arrows) {
      final paint = Paint()
        ..color = changed ? C.yellow : C.yellow.withValues(alpha: 0.75)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final start = Offset(x1 + 4, y1);
      final end = Offset(x2 - 6, y2);
      final mid = (x1 + x2) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(mid, start.dy, mid, end.dy, end.dx, end.dy);
      final metric = path.computeMetrics().first;
      final len = metric.length * (changed ? progress.clamp(0, 1) : 1);
      canvas.drawPath(metric.extractPath(0, len), paint);
      if (len >= metric.length * 0.98) {
        final tan = metric.getTangentForOffset(metric.length)!;
        final dir = tan.vector / tan.vector.distance;
        final normal = Offset(-dir.dy, dir.dx);
        final tip = tan.position;
        final head = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - dir.dx * 14 + normal.dx * 7, tip.dy - dir.dy * 14 + normal.dy * 7)
          ..lineTo(tip.dx - dir.dx * 14 - normal.dx * 7, tip.dy - dir.dy * 14 - normal.dy * 7)
          ..close();
        canvas.drawPath(head, Paint()..color = paint.color);
      }
      canvas.drawCircle(start, 5, Paint()..color = C.yellow);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) => true;
}
