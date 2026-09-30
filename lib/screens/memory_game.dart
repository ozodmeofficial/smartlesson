import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/code_highlight.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';

class _Card {
  final int pair;
  final bool isCode;
  final String text;
  bool open = false;
  bool matched = false;
  _Card(this.pair, this.isCode, this.text);
}

class MemoryGameScreen extends StatefulWidget {
  final Lesson lesson;
  const MemoryGameScreen({super.key, required this.lesson});
  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final _rnd = math.Random();
  late List<_Card> _cards;
  late List<MemoryPair> _pairs;
  final List<int> _open = [];
  int _moves = 0;
  int _found = 0;
  bool _busy = false;
  bool _won = false;
  MemoryPair? _lastMatch;
  final _watch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _newGame();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_won) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _newGame() {
    _pairs = (List.of(widget.lesson.pairs)..shuffle(_rnd)).take(8).toList();
    _cards = [
      for (int i = 0; i < _pairs.length; i++) ...[_Card(i, true, _pairs[i].a), _Card(i, false, _pairs[i].b)],
    ]..shuffle(_rnd);
    _open.clear();
    _moves = 0;
    _found = 0;
    _won = false;
    _lastMatch = null;
    _watch
      ..reset()
      ..start();
  }

  void _tap(int i) {
    final c = _cards[i];
    if (_busy || c.open || c.matched || _won) return;
    setState(() {
      c.open = true;
      _open.add(i);
    });
    if (_open.length == 2) {
      _moves++;
      final a = _cards[_open[0]], b = _cards[_open[1]];
      if (a.pair == b.pair && a.isCode != b.isCode) {
        setState(() {
          a.matched = b.matched = true;
          _found++;
          _lastMatch = _pairs[a.pair];
          _open.clear();
        });
        if (_found == _pairs.length) _win();
      } else {
        _busy = true;
        Timer(const Duration(milliseconds: 950), () {
          if (!mounted) return;
          setState(() {
            a.open = b.open = false;
            _open.clear();
            _busy = false;
          });
        });
      }
    }
  }

  void _win() {
    _watch.stop();
    final p = ProgressScope.read(context);
    p.recordMemory(_moves);
    final first = p.complete('${widget.lesson.id}.memory', xpReward: 30);
    setState(() => _won = true);
    showRewards(context, message: first ? "+30 XP — xotira o'yini yutildi!" : null);
  }

  int get _stars => _moves <= 11 ? 3 : (_moves <= 15 ? 2 : 1);

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final secs = _watch.elapsed.inSeconds;
    return Scaffold(
      body: ConfettiOverlay(
        play: _won,
        child: Column(children: [
          TopBar(
            title: "🧠 Xotira o'yini — ${l.title}",
            subtitle: "Kodni uning ma'nosi bilan juftlang. Har bir juftlik — bitta esda qolgan qoida!",
            color: l.color,
            progress: _found / _pairs.length,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                    const cols = 4;
                    final rows = (_cards.length / cols).ceil();
                    const gap = 14.0;
                    final w = (c.maxWidth - gap * (cols - 1)) / cols;
                    final h = math.min((c.maxHeight - gap * (rows - 1)) / rows, w * 0.8);
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (int i = 0; i < _cards.length; i++)
                          SizedBox(width: w, height: h, child: _FlipCard(card: _cards[i], color: l.color, onTap: () => _tap(i))),
                      ],
                    );
                  }),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 300,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Panel(
                      child: Column(children: [
                        _stat('🎯 Yurishlar', '$_moves'),
                        _stat('⏱️ Vaqt', '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}'),
                        _stat('✅ Topildi', '$_found / ${_pairs.length}'),
                        if (ProgressScope.of(context).bestMemoryMoves > 0)
                          _stat('🏅 Rekord', '${ProgressScope.of(context).bestMemoryMoves} yurish'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _won
                          ? Panel(
                              key: const ValueKey('won'),
                              borderColor: C.green,
                              child: Column(children: [
                                const Text('🏆', style: TextStyle(fontSize: 54)),
                                Text("Barcha juftliklar topildi!", style: h3(), textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  for (int i = 0; i < 3; i++)
                                    Icon(i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                        color: i < _stars ? C.yellow : C.faint, size: 36),
                                ]),
                                const SizedBox(height: 6),
                                Text('$_moves yurish, ${secs}s', style: small()),
                                const SizedBox(height: 14),
                                BigButton('Yana o\'ynash', icon: Icons.refresh_rounded, color: l.color, compact: true,
                                    onTap: () => setState(_newGame)),
                                const SizedBox(height: 10),
                                BigButton('Darsga qaytish', color: l.color, outlined: true, compact: true,
                                    onTap: () => Navigator.of(context).pop()),
                              ]),
                            )
                          : _lastMatch != null
                              ? Panel(
                                  key: ValueKey(_lastMatch),
                                  borderColor: C.green.withValues(alpha: 0.5),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('✨ Juftlik topildi!', style: h3(C.green)),
                                    const SizedBox(height: 8),
                                    Text.rich(TextSpan(children: highlightSpans(_lastMatch!.a)), style: codeStyle(size: 16)),
                                    const Icon(Icons.arrow_downward_rounded, color: C.faint, size: 18),
                                    Text(_lastMatch!.b, style: h3().copyWith(fontSize: 16)),
                                    const SizedBox(height: 8),
                                    MdText(_lastMatch!.explain, style: body(C.dim).copyWith(fontSize: 14.5)),
                                  ]),
                                )
                              : const Mascot("Kartani bosing — ikkitadan ochiladi. Kod va uning ma'nosini toping!", size: 40),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stat(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [Text(k, style: body(C.dim)), const Spacer(), Text(v, style: h3())]),
      );
}

class _FlipCard extends StatefulWidget {
  final _Card card;
  final Color color;
  final VoidCallback onTap;
  const _FlipCard({required this.card, required this.color, required this.onTap});
  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    final faceUp = c.open || c.matched;
    return MouseRegion(
      cursor: faceUp ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: faceUp ? 1 : 0),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut,
          builder: (_, v, _) {
            final showFront = v > 0.5;
            final angle = v * math.pi;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle)
                ..scaleByDouble(_hover && !faceUp ? 1.04 : 1.0, _hover && !faceUp ? 1.04 : 1.0, 1, 1),
              child: showFront
                  ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: _front(c))
                  : _back(),
            );
          },
        ),
      ),
    );
  }

  Widget _back() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.color.withValues(alpha: 0.9), Color.lerp(widget.color, Colors.black, 0.4)!],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [BoxShadow(color: widget.color.withValues(alpha: _hover ? 0.5 : 0.15), blurRadius: 16)],
        ),
        alignment: Alignment.center,
        child: Text('🐍', style: TextStyle(fontSize: 38, color: Colors.white.withValues(alpha: 0.9))),
      );

  Widget _front(_Card c) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.matched ? C.green.withValues(alpha: 0.16) : (c.isCode ? C.code : C.cardHi),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.matched ? C.green : widget.color, width: 2),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: c.isCode
              ? Text.rich(TextSpan(children: highlightSpans(c.text)), style: codeStyle(size: 24), textAlign: TextAlign.center)
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(c.text, textAlign: TextAlign.center, style: h3().copyWith(fontSize: 21)),
                ),
        ),
      );
}
