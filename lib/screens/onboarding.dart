import 'package:flutter/material.dart';

import '../services/progress.dart';
import '../theme.dart';
import '../widgets/code_highlight.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _name = TextEditingController();
  late final AnimationController _typing =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();

  static const _demo = 'ism = "Sen"\nprint(f"Salom, {ism}! Sarguzasht boshlandi 🚀")';

  @override
  void dispose() {
    _name.dispose();
    _typing.dispose();
    super.dispose();
  }

  void _start() {
    if (_name.text.trim().isEmpty) return;
    ProgressScope.read(context).setName(_name.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.6, -0.8), radius: 1.6, colors: [Color(0xFF2B1B6B), C.bg]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  const Text('🐍', style: TextStyle(fontSize: 96)),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(colors: [C.violet, C.pink, C.orange]).createShader(r),
                    child: Text('Python Sarguzashti', style: h1(Colors.white).copyWith(fontSize: 46)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "O'zgaruvchilar • Ma'lumot turlari • Stringlar\no'yinlar, laboratoriyalar va jonli kod bilan",
                    textAlign: TextAlign.center,
                    style: body(C.dim).copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 28),
                  Panel(
                    color: C.code,
                    child: AnimatedBuilder(
                      animation: _typing,
                      builder: (_, _) {
                        final n = (_demo.length * _typing.value).round();
                        return SizedBox(
                          width: double.infinity,
                          child: Text.rich(
                            TextSpan(children: [
                              ...highlightSpans(_demo.substring(0, n)),
                              const TextSpan(text: '▌', style: TextStyle(color: C.yellow)),
                            ]),
                            style: codeStyle(size: 17),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Ismingiz nima?', style: h2()),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: h2(),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _start(),
                    decoration: InputDecoration(
                      hintText: 'Masalan: Aziza',
                      hintStyle: h2(C.faint),
                      filled: true,
                      fillColor: C.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: C.violet, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  BigButton(
                    'Sarguzashtni boshlash',
                    icon: Icons.rocket_launch_rounded,
                    color: C.violet,
                    color2: C.pink,
                    onTap: _name.text.trim().isEmpty ? null : _start,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
