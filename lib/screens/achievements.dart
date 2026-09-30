import 'package:flutter/material.dart';

import '../data/lessons.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'certificate.dart';

class AchievementsScreen extends StatelessWidget {
  final bool embedded;
  const AchievementsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Centered(
        maxWidth: 1100,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text('🏆 Yutuqlar', style: h1()), const Spacer(), const XpBadge()]),
          const SizedBox(height: 6),
          Text('${p.unlocked.length} / ${achievements.length} ochildi. Har bir yutuq +25 XP beradi.', style: body(C.dim)),
          const SizedBox(height: 22),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 900 ? 3 : 2;
            final w = (c.maxWidth - (cols - 1) * 16) / cols;
            return Wrap(spacing: 16, runSpacing: 16, children: [
              for (final a in achievements)
                SizedBox(
                  width: w,
                  child: _AchTile(emoji: a.emoji, title: a.title, desc: a.description, unlocked: p.unlocked.contains(a.id)),
                ),
            ]);
          }),
          const SizedBox(height: 30),
          Panel(
            child: Row(children: [
              const Text('📜', style: TextStyle(fontSize: 48)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Sertifikat', style: h2()),
                  Text(
                    p.certificateDate != null
                        ? 'Siz ${p.certificateDate} sanasida sertifikat oldingiz!'
                        : "Katta imtihondan 70%+ olsangiz, ismingiz yozilgan sertifikat ochiladi.",
                    style: body(C.dim),
                  ),
                ]),
              ),
              if (p.certificateDate != null)
                BigButton('Ko\'rish', icon: Icons.workspace_premium_rounded, color: C.yellow, color2: C.orange,
                    onTap: () => Navigator.of(context).push(fadeRoute(const CertificateScreen()))),
            ]),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.restart_alt_rounded, color: C.faint),
              label: const Text('Progressni nolga tushirish', style: TextStyle(color: C.faint)),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: C.card,
                    title: const Text('Ishonchingiz komilmi?'),
                    content: const Text("Barcha XP, yutuqlar va progress o'chiriladi. Bu amalni qaytarib bo'lmaydi."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qilish')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("O'chirish", style: TextStyle(color: C.red))),
                    ],
                  ),
                );
                if (ok == true) await p.resetAll();
              },
            ),
          ),
        ]),
      ),
    );
    if (embedded) return content;
    return Scaffold(body: Column(children: [const TopBar(title: '🏆 Yutuqlar'), Expanded(child: content)]));
  }
}

class _AchTile extends StatelessWidget {
  final String emoji, title, desc;
  final bool unlocked;
  const _AchTile({required this.emoji, required this.title, required this.desc, required this.unlocked});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: unlocked
            ? const LinearGradient(colors: [Color(0xFF4C2A8A), Color(0xFF2A2366)])
            : null,
        color: unlocked ? null : C.card,
        border: Border.all(color: unlocked ? C.yellow.withValues(alpha: 0.6) : C.border),
      ),
      child: Row(children: [
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? C.yellow.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.04),
          ),
          child: unlocked
              ? Text(emoji, style: const TextStyle(fontSize: 32))
              : const Icon(Icons.lock_rounded, color: C.faint, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: h3(unlocked ? C.text : C.dim)),
            const SizedBox(height: 2),
            Text(desc, style: small(unlocked ? C.dim : C.faint)),
          ]),
        ),
      ]),
    );
  }
}
