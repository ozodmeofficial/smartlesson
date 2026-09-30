import 'package:flutter/material.dart';

import '../services/runner.dart';
import '../theme.dart';
import '../widgets/code_widgets.dart';
import '../widgets/common.dart';
import 'tasks.dart' show codeStyleInline;

const _examples = <String, String>{
  "👋 Salom dunyo": 'ism = "Python"\nprint(f"Salom, {ism}!")\n',
  "🏷️ Yorliqlar va id()": 'a = 10\nb = a\nprint(a is b, id(a) == id(b))\n\na = 20\nprint(a, b)\nprint(id(a) == id(b))\n',
  "🔄 a, b = b, a": 'a = "choy"\nb = "sharbat"\na, b = b, a\nprint("a =", a)\nprint("b =", b)\n',
  "🧪 Turlar": 'for qiymat in [42, 3.14, "42", True, None, 3 + 4j]:\n    print(repr(qiymat), "->", type(qiymat).__name__)\n',
  "🤔 Truthy/Falsy": 'for q in [0, 0.0, "", " ", [], [0], None, "False"]:\n    print(repr(q), "->", bool(q))\n',
  "🌊 0.1 + 0.2": 'natija = 0.1 + 0.2\nprint(natija)\nprint(natija == 0.3)\nprint(round(natija, 2) == 0.3)\n',
  "🔪 Slicing": 'soz = "Dasturlash"\nprint(soz[0], soz[-1])\nprint(soz[0:6], soz[6:])\nprint(soz[::2], soz[::-1])\n',
  "🛠️ Metodlar": 'matn = "  salom Dunyo  "\nprint(matn.strip().title())\nprint(matn.upper())\nprint("-".join("2026 09 19".split()))\n',
  "⌨️ input()": 'ism = input("Ismingiz: ")\nyosh = int(input("Yoshingiz: "))\nprint(f"{ism}, 10 yildan keyin {yosh + 10} yoshda bo\'lasiz!")\n',
};

class PlaygroundScreen extends StatefulWidget {
  final bool embedded;
  final String? initialCode;
  const PlaygroundScreen({super.key, this.embedded = false, this.initialCode});
  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  late final _code = SyntaxController(text: widget.initialCode ?? _examples.values.first);
  final _stdin = TextEditingController();
  RunState _state = RunState.idle;
  RunResult? _result;

  @override
  void dispose() {
    _code.dispose();
    _stdin.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() => _state = RunState.running);
    final r = await CodeRunner.run(_code.text, stdin: _stdin.text);
    if (!mounted) return;
    setState(() {
      _state = RunState.done;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Centered(
        maxWidth: 1100,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (widget.embedded) ...[
            Row(children: [
              Text('🧪 Python maydoni', style: h1()),
              const Spacer(),
              const XpBadge(),
            ]),
            const SizedBox(height: 6),
            Text("Istalgan kodni yozing va haqiqiy Python 3 da ishga tushiring. Xato qilishdan qo'rqmang — xato ham o'qituvchi!",
                style: body(C.dim)),
            const SizedBox(height: 18),
          ],
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in _examples.entries)
              ActionChip(
                label: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                backgroundColor: C.card,
                side: const BorderSide(color: C.border),
                onPressed: () => setState(() {
                  _code.text = e.value;
                  _state = RunState.idle;
                  _result = null;
                }),
              ),
          ]),
          const SizedBox(height: 14),
          CodeEditor(
            controller: _code,
            minHeight: 320,
            onRun: _run,
            errorLine: _result != null && !_result!.ok ? _result!.errorLine : null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stdin,
            maxLines: 3,
            minLines: 1,
            style: codeStyleInline(),
            decoration: InputDecoration(
              labelText: 'Kiritma (stdin): input() uchun javoblar — har biri yangi qatorda',
              labelStyle: small(),
              prefixIcon: const Icon(Icons.keyboard_rounded, color: C.cyan),
              filled: true,
              fillColor: C.bg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            BigButton(_state == RunState.running ? 'Ishlayapti...' : 'Ishga tushirish', icon: Icons.play_arrow_rounded,
                color: C.green, color2: const Color(0xFF10B981), onTap: _state == RunState.running ? null : _run),
            const SizedBox(width: 12),
            BigButton('Tozalash', icon: Icons.delete_outline_rounded, color: C.dim, outlined: true,
                onTap: () => setState(() {
                      _code.text = '';
                      _result = null;
                      _state = RunState.idle;
                    })),
            const Spacer(),
            Text('Ctrl + Enter', style: small(C.faint)),
          ]),
          const SizedBox(height: 14),
          ConsoleView(state: _state, result: _result, minHeight: 140),
        ]),
      ),
    );
    if (widget.embedded) return content;
    return Scaffold(
      body: Column(children: [
        const TopBar(title: '🧪 Python maydoni', subtitle: "Kodni o'zgartiring va natijani ko'ring", color: C.green),
        Expanded(child: content),
      ]),
    );
  }
}
