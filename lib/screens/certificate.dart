import 'package:flutter/material.dart';

import '../data/lessons.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    return Scaffold(
      body: ConfettiOverlay(
        play: true,
        child: Column(children: [
          const TopBar(title: '📜 Sertifikat', color: C.yellow),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Container(
                  width: 900,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF7E7A1), Color(0xFFB8860B)]),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 20))],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 44),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFB8860B), width: 2),
                    ),
                    child: Column(children: [
                      const Text('🐍', style: TextStyle(fontSize: 56)),
                      Text('SERTIFIKAT',
                          style: TextStyle(
                              fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: 10, color: Colors.brown.shade800)),
                      const SizedBox(height: 4),
                      Text("«Python Sarguzashti» interaktiv darsligi",
                          style: TextStyle(fontSize: 17, color: Colors.brown.shade600, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 28),
                      Text('Ushbu sertifikat', style: TextStyle(fontSize: 16, color: Colors.brown.shade600)),
                      const SizedBox(height: 6),
                      ShaderMask(
                        shaderCallback: (r) => const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFFDB2777)]).createShader(r),
                        child: Text(p.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      Container(width: 420, height: 2, color: const Color(0xFFB8860B), margin: const EdgeInsets.symmetric(vertical: 10)),
                      Text(
                        "ga Python dasturlash tilining asoslari — ${lessons.map((l) => l.title).join(', ')} — "
                        "mavzularini muvaffaqiyatli o'zlashtirgani va katta imtihonni ${p.examBest}% natija bilan "
                        "topshirgani uchun berildi.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, height: 1.6, color: Colors.brown.shade800, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 30),
                      Row(children: [
                        _sig('Sana', p.certificateDate ?? ''),
                        const Spacer(),
                        Container(
                          width: 110,
                          height: 110,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [Color(0xFFFDE68A), Color(0xFFD97706)]),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('🎓', style: TextStyle(fontSize: 38)),
                            Text('${p.level}-daraja', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF78350F))),
                          ]),
                        ),
                        const Spacer(),
                        _sig('Jami tajriba', '${p.xp} XP'),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sig(String label, String value) => Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.brown.shade800)),
        Container(width: 170, height: 1.5, color: Colors.brown.shade400, margin: const EdgeInsets.symmetric(vertical: 4)),
        Text(label, style: TextStyle(color: Colors.brown.shade500, fontWeight: FontWeight.w700)),
      ]);
}
