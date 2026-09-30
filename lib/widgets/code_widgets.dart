import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/runner.dart';
import '../theme.dart';
import 'code_highlight.dart';
import 'common.dart';
import 'md_text.dart';

/// Sintaksisni rangli ko'rsatadigan tahrirlash kontrolleri.
class SyntaxController extends TextEditingController {
  SyntaxController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return TextSpan(style: style, children: highlightSpans(text));
  }
}

/// Qator raqamlari, Tab va avto-chekinishli kod muharriri.
class CodeEditor extends StatefulWidget {
  final SyntaxController controller;
  final double minHeight;
  final VoidCallback? onRun;
  final int? errorLine;
  const CodeEditor({super.key, required this.controller, this.minHeight = 260, this.onRun, this.errorLine});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late final _focus = FocusNode(onKeyEvent: _onKey);
  static const _fs = 15.5;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    _focus.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _focus.dispose();
    super.dispose();
  }

  void _insert(String s, {int? caretOffset}) {
    final c = widget.controller;
    final sel = c.selection;
    final start = sel.isValid ? sel.start : c.text.length;
    final end = sel.isValid ? sel.end : c.text.length;
    final t = c.text.replaceRange(start, end, s);
    c.value = TextEditingValue(text: t, selection: TextSelection.collapsed(offset: start + (caretOffset ?? s.length)));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    if (ctrl && k == LogicalKeyboardKey.enter) {
      widget.onRun?.call();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.tab) {
      _insert('    ');
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      final c = widget.controller;
      final pos = c.selection.isValid ? c.selection.start : c.text.length;
      final before = c.text.substring(0, pos);
      final lineStart = before.lastIndexOf('\n') + 1;
      final line = before.substring(lineStart);
      var indent = RegExp(r'^ *').firstMatch(line)!.group(0)!;
      if (line.trimRight().endsWith(':')) indent += '    ';
      _insert('\n$indent');
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace) {
      final c = widget.controller;
      final sel = c.selection;
      if (sel.isValid && sel.isCollapsed && sel.start >= 4) {
        final before = c.text.substring(0, sel.start);
        final lineStart = before.lastIndexOf('\n') + 1;
        final line = before.substring(lineStart);
        if (line.isNotEmpty && line.trim().isEmpty && line.length % 4 == 0) {
          c.value = TextEditingValue(
            text: c.text.replaceRange(sel.start - 4, sel.start, ''),
            selection: TextSelection.collapsed(offset: sel.start - 4),
          );
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final lines = '\n'.allMatches(widget.controller.text).length + 1;
    final style = codeStyle(size: _fs);
    final lineH = _fs * 1.55;
    return Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: BoxDecoration(
        color: C.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _focus.hasFocus ? C.violet.withValues(alpha: 0.6) : C.border, width: 1.5),
      ),
      child: GestureDetector(
        onTap: () => _focus.requestFocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Stack(
            children: [
              if (widget.errorLine != null && widget.errorLine! <= lines)
                Positioned(
                  top: (widget.errorLine! - 1) * lineH,
                  left: 0,
                  right: 0,
                  height: lineH,
                  child: Container(color: C.red.withValues(alpha: 0.16)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      List.generate(lines, (i) => '${i + 1}').join('\n'),
                      textAlign: TextAlign.right,
                      style: style.copyWith(color: C.faint.withValues(alpha: 0.7)),
                      strutStyle: StrutStyle(fontFamily: mono, fontSize: _fs, height: 1.55, forceStrutHeight: true),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                        controller: widget.controller,
                        focusNode: _focus,
                        maxLines: null,
                        minLines: (widget.minHeight / lineH).floor().clamp(1, 60),
                        style: style,
                        strutStyle: StrutStyle(fontFamily: mono, fontSize: _fs, height: 1.55, forceStrutHeight: true),
                        cursorColor: C.yellow,
                        cursorWidth: 2.2,
                        keyboardType: TextInputType.multiline,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(right: 16),
                        ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum RunState { idle, running, done }

/// Natija oynasi (konsol).
class ConsoleView extends StatelessWidget {
  final RunState state;
  final RunResult? result;
  final String? offlineExpected;
  final double minHeight;
  const ConsoleView({super.key, required this.state, this.result, this.offlineExpected, this.minHeight = 90});

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (state == RunState.idle) {
      content = Text("▶ «Ishga tushirish» tugmasini bosing (yoki Ctrl + Enter)",
          style: TextStyle(fontFamily: mono, color: C.faint, fontSize: 14));
    } else if (state == RunState.running) {
      content = Row(children: [
        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: C.green)),
        const SizedBox(width: 12),
        Text('Python ishlayapti...', style: TextStyle(fontFamily: mono, color: C.green, fontSize: 14)),
      ]);
    } else {
      final r = result!;
      if (r.networkError) {
        content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.wifi_off_rounded, color: C.orange, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text("${r.status}. Kodni haqiqiy Python'da ishga tushirish uchun internet kerak.",
                  style: const TextStyle(color: C.orange, fontWeight: FontWeight.w700)),
            ),
          ]),
          if (offlineExpected != null && offlineExpected!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Darslik bo\'yicha kutilgan natija:', style: small()),
            const SizedBox(height: 4),
            SelectableText(offlineExpected!, style: codeStyle(size: 14.5).copyWith(color: C.text)),
          ],
        ]);
      } else {
        content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (r.stdout.isNotEmpty)
            SelectableText(r.stdout.endsWith('\n') ? r.stdout.substring(0, r.stdout.length - 1) : r.stdout,
                style: codeStyle(size: 14.5).copyWith(color: C.text)),
          if (r.stdout.isEmpty && r.stderr.isEmpty)
            Text('(dastur hech narsa chiqarmadi)', style: TextStyle(fontFamily: mono, color: C.faint, fontSize: 14)),
          if (r.stderr.isNotEmpty) ...[
            if (r.stdout.isNotEmpty) const SizedBox(height: 8),
            SelectableText(r.stderr.trimRight(), style: codeStyle(size: 14).copyWith(color: C.red)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.yellow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.yellow.withValues(alpha: 0.3)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🐍', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      r.errorLine != null ? '${r.errorType ?? 'Xato'} — ${r.errorLine}-qatorda' : (r.errorType ?? 'Xato'),
                      style: const TextStyle(color: C.yellow, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    MdText(explainError(r.errorType, r.errorMessage), style: body().copyWith(fontSize: 14.5)),
                  ]),
                ),
              ]),
            ),
          ],
          if (!r.ok && r.stderr.isEmpty && r.statusId != 3)
            Text('Holat: ${r.status}', style: const TextStyle(color: C.orange)),
        ]);
      }
    }
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050716),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.terminal_rounded, size: 16, color: C.faint),
          const SizedBox(width: 6),
          Text('NATIJA', style: small(C.faint).copyWith(letterSpacing: 1.5, fontSize: 12)),
          const Spacer(),
          if (result != null && state == RunState.done && result!.time != null)
            Text('${result!.time} s', style: small(C.faint).copyWith(fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        content,
      ]),
    );
  }
}

/// Darslikdagi kod bloki: ko'rish, ishga tushirish, tahrirlash.
class RunnableCode extends StatefulWidget {
  final String code;
  final bool runnable;
  final void Function(String code)? onEdit;
  const RunnableCode(this.code, {super.key, this.runnable = true, this.onEdit});

  @override
  State<RunnableCode> createState() => _RunnableCodeState();
}

class _RunnableCodeState extends State<RunnableCode> {
  RunState _state = RunState.idle;
  RunResult? _result;

  Future<void> _run() async {
    setState(() => _state = RunState.running);
    final r = await CodeRunner.run(widget.code);
    if (!mounted) return;
    setState(() {
      _state = RunState.done;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: C.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.border))),
          child: Row(children: [
            for (final c in [C.red, C.yellow, C.green])
              Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: c.withValues(alpha: 0.8), shape: BoxShape.circle),
              ),
            const SizedBox(width: 6),
            Text('main.py', style: small(C.faint)),
            const Spacer(),
            IconButton(
              tooltip: 'Nusxa olish',
              iconSize: 18,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod nusxalandi 📋')));
              },
              icon: const Icon(Icons.copy_rounded, color: C.dim),
            ),
            if (widget.onEdit != null)
              TextButton.icon(
                onPressed: () => widget.onEdit!(widget.code),
                icon: const Icon(Icons.edit_rounded, size: 17, color: C.cyan),
                label: const Text("O'zgartirib ko'r", style: TextStyle(color: C.cyan, fontWeight: FontWeight.w800)),
              ),
            if (widget.runnable) ...[
              const SizedBox(width: 6),
              BigButton(
                _state == RunState.running ? '...' : 'Ishga tushir',
                icon: Icons.play_arrow_rounded,
                color: C.green,
                color2: const Color(0xFF10B981),
                compact: true,
                onTap: _state == RunState.running ? null : _run,
              ),
            ],
          ]),
        ),
        Padding(padding: const EdgeInsets.all(16), child: CodeView(widget.code)),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: _state == RunState.idle
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: ConsoleView(
                    state: _state,
                    result: _result,
                    offlineExpected: CodeRunner.expectedFromComments(widget.code),
                    minHeight: 50,
                  ),
                ),
        ),
      ]),
    );
  }
}
