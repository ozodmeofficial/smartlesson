import 'package:flutter/material.dart';

import '../data/models.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';
import 'labs/labs.dart';
import 'memory_game.dart';
import 'quiz.dart';
import 'tasks.dart';
import 'theory.dart';

class LessonHubScreen extends StatelessWidget {
  final Lesson lesson;
  const LessonHubScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final l = lesson;
    final prog = p.lessonProgress(l);

    void open(Widget w) => Navigator.of(context).push(fadeRoute(w));

    final theoryDone = l.sections.where((s) => p.isDone('${l.id}.sec.${s.id}')).length;
    final steps = <_StepData>[
      _StepData.header('📖', 'Nazariya', '$theoryDone / ${l.sections.length} bo\'lim'),
      for (int i = 0; i < l.sections.length; i++)
        _StepData(
          emoji: l.sections[i].emoji,
          title: l.sections[i].title,
          subtitle: 'Tezkor savol bilan',
          done: p.isDone('${l.id}.sec.${l.sections[i].id}'),
          onTap: () => open(TheoryScreen(lesson: l, start: i)),
        ),
      _StepData.header('🔬', 'Laboratoriya', "Interaktiv tajribalar va o'yinlar"),
      for (final lab in l.labs)
        _StepData(
          emoji: labInfo(lab).$1,
          title: labInfo(lab).$2,
          subtitle: labInfo(lab).$3,
          done: p.isDone('${l.id}.lab.${lab.name}'),
          onTap: () => open(labScreen(l, lab)),
        ),
      _StepData.header('💻', 'Amaliyot', 'Haqiqiy Python kodi yozing'),
      for (int i = 0; i < l.tasks.length; i++)
        _StepData(
          emoji: l.tasks[i].title.startsWith('🐞') ? '🐞' : '⌨️',
          title: l.tasks[i].title.replaceFirst('🐞 ', ''),
          subtitle: '${i + 1}-vazifa',
          done: p.isDone('${l.id}.task.${l.tasks[i].id}'),
          onTap: () => open(TasksScreen(lesson: l, index: i)),
        ),
      _StepData.header('🏁', 'Mustahkamlash', ''),
      _StepData(
        emoji: '🧠',
        title: "Xotira o'yini",
        subtitle: 'Juftliklarni toping',
        done: p.isDone('${l.id}.memory'),
        onTap: () => open(MemoryGameScreen(lesson: l)),
      ),
      _StepData(
        emoji: '📝',
        title: 'Yakuniy test',
        subtitle: p.quizBest[l.id] != null ? 'Eng yaxshi natija: ${p.quizBest[l.id]}%' : '${l.quiz.length} ta savol',
        done: p.isDone('${l.id}.quiz'),
        onTap: () => open(QuizScreen.lesson(l)),
      ),
    ];

    return Scaffold(
      body: Column(children: [
        TopBar(title: '${l.number}-dars: ${l.title}', subtitle: l.subtitle, color: l.color, progress: prog),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Centered(
              maxWidth: 1180,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Banner(lesson: l, progress: prog),
                const SizedBox(height: 26),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 900;
                  final path = _Path(steps: steps, color: l.color);
                  final side = _Side(lesson: l);
                  if (!wide) return Column(children: [path, const SizedBox(height: 20), side]);
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: path),
                    const SizedBox(width: 26),
                    SizedBox(width: 380, child: side),
                  ]);
                }),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Banner extends StatelessWidget {
  final Lesson lesson;
  final double progress;
  const _Banner({required this.lesson, required this.progress});
  @override
  Widget build(BuildContext context) {
    final l = lesson;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: [l.color, l.color2]),
      ),
      child: Row(children: [
        Text(l.emoji, style: const TextStyle(fontSize: 84)),
        const SizedBox(width: 24),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.title, style: h1(Colors.white)),
            const SizedBox(height: 8),
            MdText(l.intro, style: body(Colors.white).copyWith(fontSize: 17)),
          ]),
        ),
      ]),
    );
  }
}

class _StepData {
  final String emoji;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback? onTap;
  final bool isHeader;
  _StepData({required this.emoji, required this.title, required this.subtitle, required this.done, this.onTap})
      : isHeader = false;
  _StepData.header(this.emoji, this.title, this.subtitle)
      : done = false,
        onTap = null,
        isHeader = true;
}

class _Path extends StatelessWidget {
  final List<_StepData> steps;
  final Color color;
  const _Path({required this.steps, required this.color});

  @override
  Widget build(BuildContext context) {
    // Birinchi bajarilmagan qadam — "hozirgi" qadam.
    final current = steps.indexWhere((s) => !s.isHeader && !s.done);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          steps[i].isHeader
              ? Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 22, bottom: 10),
                  child: Row(children: [
                    Text(steps[i].emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Text(steps[i].title, style: h2()),
                    const SizedBox(width: 12),
                    Flexible(child: Text(steps[i].subtitle, style: small(), overflow: TextOverflow.ellipsis)),
                  ]),
                )
              : _StepTile(step: steps[i], color: color, current: i == current),
      ],
    );
  }
}

class _StepTile extends StatefulWidget {
  final _StepData step;
  final Color color;
  final bool current;
  const _StepTile({required this.step, required this.color, required this.current});
  @override
  State<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<_StepTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.step;
    final c = widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: s.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: _hover ? C.cardHi : C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.current ? c : (s.done ? C.green.withValues(alpha: 0.35) : C.border),
              width: widget.current ? 2 : 1,
            ),
            boxShadow: widget.current ? [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 18)] : null,
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.done ? C.green.withValues(alpha: 0.18) : c.withValues(alpha: 0.16),
              ),
              child: Text(s.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title, style: h3().copyWith(fontSize: 16.5)),
                Text(s.subtitle, style: small()),
              ]),
            ),
            if (s.done)
              const Icon(Icons.check_circle_rounded, color: C.green, size: 28)
            else if (widget.current)
              Pill('Keyingi qadam', color: c, icon: Icons.arrow_forward_rounded)
            else
              Icon(Icons.chevron_right_rounded, color: _hover ? C.text : C.faint),
          ]),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  final Lesson lesson;
  const _Side({required this.lesson});
  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final stars = p.lessonStars(lesson);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Yulduzlar', style: h3()),
            const Spacer(),
            for (int i = 0; i < 3; i++)
              Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < stars ? C.yellow : C.faint, size: 30),
          ]),
          const SizedBox(height: 6),
          Text("⭐ — testdan o'tish (60%+)\n⭐⭐ — darsni to'liq tugatish + test 80%+\n⭐⭐⭐ — hammasi + test 100%",
              style: small().copyWith(height: 1.6)),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🎯 Bu darsda', style: h3()),
          const SizedBox(height: 10),
          for (final g in lesson.goals)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_rounded, size: 18, color: lesson.color),
                const SizedBox(width: 8),
                Expanded(child: MdText(g, style: body().copyWith(fontSize: 14.5))),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        borderColor: C.yellow.withValues(alpha: 0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📌 Xulosa', style: h3(C.yellow)),
          const SizedBox(height: 10),
          for (final s in lesson.summary)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MdText('• $s', style: body().copyWith(fontSize: 14.5)),
            ),
        ]),
      ),
    ]);
  }
}
