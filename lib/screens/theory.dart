import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/beads.dart';
import '../widgets/code_highlight.dart';
import '../widgets/code_widgets.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';
import 'playground.dart';

class TheoryScreen extends StatefulWidget {
  final Lesson lesson;
  final int start;
  const TheoryScreen({super.key, required this.lesson, this.start = 0});
  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  late int _i = widget.start;
  final _scroll = ScrollController();
  bool _answered = false;
  bool _celebrate = false;

  Lesson get l => widget.lesson;
  Section get s => l.sections[_i];
  String get _key => '${l.id}.sec.${s.id}';

  @override
  void initState() {
    super.initState();
    _answered = ProgressScope.read(context).isDone(_key) || s.check == null;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() {
      _i = i;
      _answered = ProgressScope.read(context).isDone(_key) || s.check == null;
      _celebrate = false;
    });
    _scroll.jumpTo(0);
  }

  void _next() {
    final p = ProgressScope.read(context);
    final first = p.complete(_key, xpReward: 10);
    if (_i == l.sections.length - 1) {
      p.enrollCards(l);
      setState(() => _celebrate = true);
      showRewards(context, message: first ? '+10 XP — nazariya tugadi! 🎉' : null);
      showDialog(context: context, builder: (_) => _TheoryDoneDialog(lesson: l)).then((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    showRewards(context, message: first ? "+10 XP — bo'lim o'zlashtirildi" : null);
    _go(_i + 1);
  }

  void _openPlayground(String code) {
    Navigator.of(context).push(fadeRoute(PlaygroundScreen(initialCode: code)));
  }

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final wide = MediaQuery.of(context).size.width > 1150;
    return Scaffold(
      body: ConfettiOverlay(
        play: _celebrate,
        child: Column(children: [
          TopBar(
            title: '${l.emoji} ${l.title} — nazariya',
            subtitle: "${_i + 1}/${l.sections.length}: ${s.title}",
            color: l.color,
            progress: (_i + (p.isDone(_key) ? 1 : 0)) / l.sections.length,
          ),
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (wide)
                Container(
                  width: 270,
                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: C.border))),
                  child: ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      for (int k = 0; k < l.sections.length; k++)
                        _TocItem(
                          emoji: l.sections[k].emoji,
                          title: l.sections[k].title,
                          done: p.isDone('${l.id}.sec.${l.sections[k].id}'),
                          active: k == _i,
                          color: l.color,
                          onTap: () => _go(k),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(36, 30, 36, 60),
                  child: Centered(
                    maxWidth: 900,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(_i),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [l.color, l.color2]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s.emoji, style: const TextStyle(fontSize: 32)),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text("${_i + 1}-BO'LIM", style: small(l.color).copyWith(letterSpacing: 2)),
                                Text(s.title, style: h1().copyWith(fontSize: 30)),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 22),
                          for (final b in s.blocks) _block(b),
                          if (s.check != null) ...[
                            const SizedBox(height: 24),
                            QuickCheckCard(
                              key: ValueKey('qc$_i'),
                              check: s.check!,
                              color: l.color,
                              onAnswered: (ok) {
                                if (ok) ProgressScope.read(context).addXp(5);
                                setState(() => _answered = true);
                              },
                            ),
                          ],
                          const SizedBox(height: 28),
                          Row(children: [
                            if (_i > 0)
                              BigButton('Oldingi', icon: Icons.arrow_back_rounded, color: C.dim, outlined: true,
                                  onTap: () => _go(_i - 1)),
                            Expanded(
                              child: !_answered
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      child: Text('⬆ Avval tezkor savolga javob bering',
                                          textAlign: TextAlign.right, style: small(C.yellow)),
                                    )
                                  : const SizedBox(),
                            ),
                            BigButton(
                              _i == l.sections.length - 1 ? 'Nazariyani yakunlash' : 'Keyingi bo\'lim',
                              icon: _i == l.sections.length - 1 ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                              color: l.color,
                              color2: l.color2,
                              onTap: _answered ? _next : null,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _block(Block b) {
    switch (b) {
      case TextBlock():
        return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: MdText(b.md, style: body().copyWith(fontSize: 17)));
      case BulletsBlock():
        return MdText(b.items.map((e) => '• $e').join('\n'), style: body().copyWith(fontSize: 17));
      case CodeBlock():
        return RunnableCode(b.code, runnable: b.runnable, onEdit: _openPlayground);
      case NoteBlock():
        final (c, icon, label) = switch (b.kind) {
          NoteKind.info => (C.blue, Icons.info_rounded, 'Eslatma'),
          NoteKind.warning => (C.orange, Icons.warning_amber_rounded, 'Diqqat'),
          NoteKind.tip => (C.green, Icons.lightbulb_rounded, 'Maslahat'),
        };
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: c, width: 5)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: c),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: h3(c).copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                MdText(b.md, style: body().copyWith(fontSize: 16)),
              ]),
            ),
          ]),
        );
      case TableBlock():
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
          clipBehavior: Clip.antiAlias,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: l.color.withValues(alpha: 0.22)),
                children: [
                  for (final h in b.header)
                    Padding(padding: const EdgeInsets.all(12), child: Text(h, style: h3().copyWith(fontSize: 15))),
                ],
              ),
              for (int r = 0; r < b.rows.length; r++)
                TableRow(
                  decoration: BoxDecoration(color: r.isEven ? C.card : C.bg2),
                  children: [
                    for (final cell in b.rows[r])
                      Padding(padding: const EdgeInsets.all(12), child: MdText(cell, style: body().copyWith(fontSize: 14.5))),
                  ],
                ),
            ],
          ),
        );
      case AnalogyBlock():
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(colors: [l.color.withValues(alpha: 0.28), l.color2.withValues(alpha: 0.14)]),
            border: Border.all(color: l.color.withValues(alpha: 0.45)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Analogiya: ${b.title}', style: h3()),
                const SizedBox(height: 8),
                MdText(b.md, style: body().copyWith(fontSize: 16.5)),
              ]),
            ),
          ]),
        );
      case MnemonicBlock():
        return Transform.rotate(
          angle: -0.006,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3B0),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(3, 8))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('🧷', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('ESLAB QOLISH KALITI',
                    style: TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ]),
              const SizedBox(height: 8),
              MdText(b.md, style: TextStyle(color: Colors.brown.shade900, fontSize: 17, height: 1.5, fontWeight: FontWeight.w600)),
            ]),
          ),
        );
      case BeadsBlock():
        final sel = b.from == null ? const <int>[] : [for (int k = b.from!; k < math.min(b.to!, b.text.length); k++) k];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            BeadsView(b.text, selected: sel),
            if (b.from != null) ...[
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(children: [
                  ...highlightSpans('"${b.text}"[${b.from}:${b.to}]'),
                  const TextSpan(text: '  →  '),
                  ...highlightSpans('"${b.text.substring(b.from!, b.to)}"'),
                ]),
                style: codeStyle(size: 16),
              ),
            ],
          ]),
        );
    }
  }
}

class _TocItem extends StatelessWidget {
  final String emoji, title;
  final bool done, active;
  final Color color;
  final VoidCallback onTap;
  const _TocItem(
      {required this.emoji, required this.title, required this.done, required this.active, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w600, color: active ? C.text : C.dim)),
              ),
              if (done) const Icon(Icons.check_circle_rounded, color: C.green, size: 18),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Bo'lim oxiridagi tezkor savol.
class QuickCheckCard extends StatefulWidget {
  final QuickCheck check;
  final Color color;
  final ValueChanged<bool> onAnswered;
  const QuickCheckCard({super.key, required this.check, required this.color, required this.onAnswered});
  @override
  State<QuickCheckCard> createState() => _QuickCheckCardState();
}

class _QuickCheckCardState extends State<QuickCheckCard> {
  int? _picked;
  int _shake = 0;

  @override
  Widget build(BuildContext context) {
    final q = widget.check;
    final answered = _picked != null;
    final ok = _picked == q.correct;
    return Shake(
      trigger: _shake,
      child: Panel(
        borderColor: answered ? (ok ? C.green : C.red).withValues(alpha: 0.6) : widget.color.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('⚡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text('TEZKOR SAVOL', style: small(widget.color).copyWith(letterSpacing: 2, fontSize: 13)),
            const Spacer(),
            if (!answered) Text('+5 XP', style: small(C.yellow)),
          ]),
          const SizedBox(height: 10),
          MdText(q.question, style: h3().copyWith(fontSize: 18.5)),
          if (q.code != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.code, borderRadius: BorderRadius.circular(12)),
              child: CodeView(q.code!, lineNumbers: false),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (int i = 0; i < q.options.length; i++)
              OptionButton(
                text: q.options[i],
                state: !answered
                    ? OptState.idle
                    : (i == q.correct ? OptState.correct : (i == _picked ? OptState.wrong : OptState.dim)),
                onTap: answered
                    ? null
                    : () {
                        setState(() {
                          _picked = i;
                          if (i != q.correct) _shake++;
                        });
                        widget.onAnswered(i == q.correct);
                      },
              ),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: answered
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ok ? '🎉' : '💡', style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MdText('${ok ? "**To'g'ri!** " : "**Deyarli!** "}${q.explain}', style: body().copyWith(fontSize: 16)),
                      ),
                    ]),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ]),
      ),
    );
  }
}

enum OptState { idle, correct, wrong, dim }

class OptionButton extends StatefulWidget {
  final String text;
  final OptState state;
  final VoidCallback? onTap;
  final bool expand;
  final String? prefix;
  const OptionButton({super.key, required this.text, required this.state, this.onTap, this.expand = false, this.prefix});
  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (widget.state) {
      OptState.idle => (_hover ? C.cardHi : C.bg2, _hover ? C.violet : C.border),
      OptState.correct => (C.green.withValues(alpha: 0.2), C.green),
      OptState.wrong => (C.red.withValues(alpha: 0.2), C.red),
      OptState.dim => (C.bg2, C.border),
    };
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
      ),
      child: Row(mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min, children: [
        if (widget.prefix != null) ...[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(widget.prefix!, style: const TextStyle(fontWeight: FontWeight.w900, color: C.dim)),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: MdText(widget.text,
              style: body(widget.state == OptState.dim ? C.faint : C.text).copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        if (widget.state == OptState.correct) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_rounded, color: C.green, size: 20),
        ],
        if (widget.state == OptState.wrong) ...[
          const SizedBox(width: 8),
          const Icon(Icons.cancel_rounded, color: C.red, size: 20),
        ],
      ]),
    );
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(onTap: widget.onTap, child: child),
    );
  }
}

class _TheoryDoneDialog extends StatelessWidget {
  final Lesson lesson;
  const _TheoryDoneDialog({required this.lesson});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: C.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            Text('Nazariya tugadi!', style: h1()),
            const SizedBox(height: 10),
            Text(
              "Zo'r! ${lesson.cards.length} ta flesh-karta «Takrorlash» bo'limiga qo'shildi — ular sizga eng to'g'ri vaqtda qayta ko'rsatiladi, shunda bilim yillar davomida esda qoladi.\n\nEndi laboratoriyada bilimlarni sinab ko'ring! 🔬",
              textAlign: TextAlign.center,
              style: body(C.dim),
            ),
            const SizedBox(height: 22),
            BigButton('Davom etish', icon: Icons.arrow_forward_rounded, color: lesson.color, color2: lesson.color2,
                onTap: () => Navigator.of(context).pop()),
          ]),
        ),
      ),
    );
  }
}
