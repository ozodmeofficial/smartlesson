import 'package:flutter/material.dart';

import '../data/models.dart';
import '../services/progress.dart';
import '../services/runner.dart';
import '../theme.dart';
import '../widgets/code_highlight.dart';
import '../widgets/code_widgets.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';

/// Yozilgan kodlar sessiya davomida saqlanib turadi.
final Map<String, String> _drafts = {};

class TasksScreen extends StatefulWidget {
  final Lesson lesson;
  final int index;
  const TasksScreen({super.key, required this.lesson, this.index = 0});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late int _i = widget.index;
  late SyntaxController _code;
  final _stdin = TextEditingController();
  RunState _state = RunState.idle;
  RunResult? _result;
  TaskVerdict? _verdict;
  bool _checking = false;
  int _hintsShown = 0;
  int _fails = 0;
  bool _celebrate = false;

  Lesson get l => widget.lesson;
  CodeTask get t => l.tasks[_i];
  String get _draftKey => '${l.id}.${t.id}';

  @override
  void initState() {
    super.initState();
    _code = SyntaxController(text: _drafts[_draftKey] ?? t.starter);
    _code.addListener(() => _drafts[_draftKey] = _code.text);
  }

  @override
  void dispose() {
    _code.dispose();
    _stdin.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() {
      _i = i;
      _code.text = _drafts[_draftKey] ?? t.starter;
      _state = RunState.idle;
      _result = null;
      _verdict = null;
      _hintsShown = 0;
      _fails = 0;
      _celebrate = false;
      _stdin.clear();
    });
  }

  Future<void> _run() async {
    setState(() {
      _state = RunState.running;
      _verdict = null;
    });
    final r = await CodeRunner.run(_code.text, stdin: _stdin.text);
    if (!mounted) return;
    setState(() {
      _state = RunState.done;
      _result = r;
    });
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _verdict = null;
      _state = RunState.running;
    });
    RunResult? last;
    final v = await t.check(_code.text, (stdin) async {
      final r = await CodeRunner.run(_code.text, stdin: stdin);
      last = r;
      return r;
    });
    if (!mounted) return;
    final p = ProgressScope.read(context);
    bool first = false;
    if (v.ok) {
      first = p.complete('${l.id}.task.${t.id}', xpReward: 20);
    } else {
      _fails++;
    }
    setState(() {
      _checking = false;
      _verdict = v;
      _state = last == null ? RunState.idle : RunState.done;
      _result = last;
      _celebrate = v.ok;
    });
    if (v.ok) showRewards(context, message: first ? '+20 XP — vazifa yechildi! 🎉' : null);
  }

  void _showSolution() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.card,
        title: Text('💡 Namunaviy yechim', style: h2()),
        content: SizedBox(
          width: 620,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Avval o'zingiz tushunib chiqing, keyin qayta yozib ko'ring — ko'chirish emas, tushunish muhim!",
                style: body(C.dim)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.code, borderRadius: BorderRadius.circular(12)),
              child: CodeView(t.solution),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _code.text = t.solution;
              Navigator.pop(context);
            },
            child: const Text("Muharrirga qo'yish", style: TextStyle(color: C.cyan, fontWeight: FontWeight.w800)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Yopish')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final solved = p.isDone('${l.id}.task.${t.id}');
    final doneCount = l.tasks.where((x) => p.isDone('${l.id}.task.${x.id}')).length;
    return Scaffold(
      body: ConfettiOverlay(
        play: _celebrate,
        child: Column(children: [
          TopBar(
            title: '💻 Amaliyot — ${l.title}',
            subtitle: '$doneCount / ${l.tasks.length} vazifa yechildi   •   Ctrl + Enter — ishga tushirish',
            color: l.color,
            progress: doneCount / l.tasks.length,
          ),
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 250,
                decoration: const BoxDecoration(border: Border(right: BorderSide(color: C.border))),
                child: ListView(padding: const EdgeInsets.all(12), children: [
                  for (int k = 0; k < l.tasks.length; k++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: k == _i ? l.color.withValues(alpha: 0.22) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _go(k),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.isDone('${l.id}.task.${l.tasks[k].id}') ? C.green : C.cardHi,
                                ),
                                child: p.isDone('${l.id}.task.${l.tasks[k].id}')
                                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                                    : Text('${k + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(l.tasks[k].title,
                                    style: TextStyle(fontWeight: k == _i ? FontWeight.w900 : FontWeight.w600)),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(26),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(child: Text('${_i + 1}. ${t.title}', style: h1().copyWith(fontSize: 28))),
                      if (solved) const Pill('Yechilgan', color: C.green, icon: Icons.check_rounded),
                    ]),
                    const SizedBox(height: 12),
                    Panel(
                      padding: const EdgeInsets.all(18),
                      child: MdText(t.description, style: body().copyWith(fontSize: 16.5)),
                    ),
                    const SizedBox(height: 16),
                    CodeEditor(
                      controller: _code,
                      minHeight: 240,
                      onRun: _run,
                      errorLine: _result != null && !_result!.ok ? _result!.errorLine : null,
                    ),
                    if (t.usesInput || _code.text.contains('input(')) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _stdin,
                        maxLines: 3,
                        minLines: 1,
                        style: codeStyleInline(),
                        decoration: InputDecoration(
                          labelText: "Kiritma (stdin) — «Ishga tushirish» uchun input() javoblari, har biri yangi qatorda",
                          labelStyle: small(),
                          prefixIcon: const Icon(Icons.keyboard_rounded, color: C.cyan),
                          filled: true,
                          fillColor: C.bg2,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      BigButton('Ishga tushirish', icon: Icons.play_arrow_rounded, color: C.green, color2: const Color(0xFF10B981),
                          onTap: _state == RunState.running ? null : _run),
                      BigButton(_checking ? 'Tekshirilmoqda...' : 'Tekshirish', icon: Icons.verified_rounded, color: l.color,
                          color2: l.color2, onTap: _checking ? null : _check),
                      BigButton('Maslahat (${t.hints.length - _hintsShown})', icon: Icons.lightbulb_rounded, color: C.yellow,
                          outlined: true, onTap: _hintsShown < t.hints.length ? () => setState(() => _hintsShown++) : null),
                      if (_fails >= 2 || solved)
                        BigButton('Yechim', icon: Icons.visibility_rounded, color: C.cyan, outlined: true, onTap: _showSolution),
                      BigButton('Qaytadan', icon: Icons.restart_alt_rounded, color: C.dim, outlined: true,
                          onTap: () => setState(() {
                                _code.text = t.starter;
                                _result = null;
                                _verdict = null;
                                _state = RunState.idle;
                              })),
                    ]),
                    for (int h = 0; h < _hintsShown; h++)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.yellow.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.yellow.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Text('💡 ${h + 1}.  ', style: h3(C.yellow).copyWith(fontSize: 15)),
                          Expanded(child: MdText(t.hints[h], style: body().copyWith(fontSize: 15.5))),
                        ]),
                      ),
                    if (_verdict != null) ...[
                      const SizedBox(height: 14),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            (_verdict!.ok ? C.green : C.red).withValues(alpha: 0.22),
                            (_verdict!.ok ? C.cyan : C.orange).withValues(alpha: 0.1),
                          ]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: (_verdict!.ok ? C.green : C.red).withValues(alpha: 0.6)),
                        ),
                        child: Row(children: [
                          Text(_verdict!.ok ? '🎉' : '🤔', style: const TextStyle(fontSize: 34)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(_verdict!.ok ? "To'g'ri yechim!" : "Hali to'liq emas", style: h3(_verdict!.ok ? C.green : C.orange)),
                              const SizedBox(height: 2),
                              MdText(_verdict!.message, style: body().copyWith(fontSize: 15.5)),
                            ]),
                          ),
                          if (_verdict!.ok && _i < l.tasks.length - 1)
                            BigButton('Keyingi vazifa', icon: Icons.arrow_forward_rounded, color: l.color, color2: l.color2,
                                onTap: () => _go(_i + 1)),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ConsoleView(state: _state, result: _result, minHeight: 110),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

TextStyle codeStyleInline() => const TextStyle(fontFamily: mono, fontSize: 15, color: C.text);
