import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/lessons.dart';
import '../data/models.dart';
import '../services/progress.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/md_text.dart';
import 'achievements.dart';
import 'certificate.dart';
import 'lesson_hub.dart';
import 'playground.dart';
import 'quiz.dart';
import 'review.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final due = p.dueCards().length;
    final wide = MediaQuery.of(context).size.width > 1000;
    final pages = [
      _Dashboard(onGoReview: () => setState(() => _tab = 1)),
      const ReviewScreen(embedded: true),
      const PlaygroundScreen(embedded: true),
      const AchievementsScreen(embedded: true),
    ];
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            wide: wide,
            index: _tab,
            dueCount: due,
            onSelect: (i) => setState(() => _tab = i),
          ),
          Expanded(child: IndexedStack(index: _tab, sizing: StackFit.expand, children: pages)),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final bool wide;
  final int index;
  final int dueCount;
  final ValueChanged<int> onSelect;
  const _Sidebar({required this.wide, required this.index, required this.dueCount, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final items = [
      (Icons.map_rounded, 'Sarguzasht xaritasi', 0),
      (Icons.style_rounded, 'Takrorlash', dueCount),
      (Icons.code_rounded, 'Python maydoni', 0),
      (Icons.emoji_events_rounded, 'Yutuqlar', 0),
    ];
    return Container(
      width: wide ? 270 : 84,
      decoration: const BoxDecoration(
        color: C.bg2,
        border: Border(right: BorderSide(color: C.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              const Text('🐍', style: TextStyle(fontSize: 34)),
              if (wide) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Python', style: h3().copyWith(height: 1)),
                    Text('Sarguzashti', style: h3(C.pink).copyWith(height: 1.1)),
                  ]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 26),
          if (wide)
            Panel(
              padding: const EdgeInsets.all(14),
              gradient: const LinearGradient(colors: [Color(0xFF2D2170), Color(0xFF1C2358)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: C.violet,
                    child: Text(p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: h3().copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                      Text('${p.level}-daraja', style: small(C.yellow)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(p.levelTitle, style: small(C.dim)),
                const SizedBox(height: 6),
                ProgressBar(p.levelXp / Progress.levelSize, color: C.yellow, color2: C.orange, height: 8),
                const SizedBox(height: 4),
                Text('${p.levelXp} / ${Progress.levelSize} XP', style: small(C.faint).copyWith(fontSize: 12)),
              ]),
            ),
          const SizedBox(height: 18),
          for (int i = 0; i < items.length; i++)
            _NavItem(
              icon: items[i].$1,
              label: items[i].$2,
              badge: items[i].$3,
              selected: index == i,
              wide: wide,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          if (wide)
            Text('🔥 ${p.streak} kunlik seriya\n⚡ ${p.xp} XP jami', style: small(C.faint), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int badge;
  final bool selected;
  final bool wide;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon, required this.label, required this.badge, required this.selected, required this.wide, required this.onTap});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.selected ? Colors.white : C.dim;
    return Tooltip(
      message: widget.wide ? '' : widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: widget.selected
                  ? LinearGradient(colors: [C.violet.withValues(alpha: 0.9), C.pink.withValues(alpha: 0.7)])
                  : null,
              color: widget.selected ? null : (_hover ? Colors.white.withValues(alpha: 0.05) : null),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: widget.wide ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Badge(
                  isLabelVisible: widget.badge > 0 && !widget.wide,
                  label: Text('${widget.badge}'),
                  child: Icon(widget.icon, color: c),
                ),
                if (widget.wide) ...[
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(widget.label,
                          style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 15.5))),
                  if (widget.badge > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(99)),
                      child: Text('${widget.badge}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ dashboard

const _tips = [
  "`=` bu o'q `←`: o'ngdagi qiymat chapdagi nomga oqib tushadi.",
  "O'zgaruvchi — quti emas, **yorliq** 🏷️. Qiymat o'zgarsa, yorliq yangi obyektga ko'chadi.",
  "**snake_case** 🐍 — ilon kabi: hamma harf pastda, orasida `_`.",
  "Falsy oilasi: `0`, `0.0`, `\"\"`, `[]`, `{}`, `None`. Qolgan hamma narsa — True!",
  "`0.1 + 0.2` — `0.30000000000000004`. Kasr sonlarni `round()` bilan solishtiring.",
  "Indekslar chizg'ich kabi **0 dan** boshlanadi 📏.",
  "Slicing: **uzunlik = stop − start**. `soz[2:5]` — 3 ta belgi.",
  "`[::-1]` — stringni teskari aylantirishning eng qisqa yo'li 🔁.",
  "String — toshga o'yilgan yozuv 🗿: metodlar doim **yangi** string qaytaradi.",
  "`input()` har doim `str` qaytaradi. Son kerak bo'lsa — `int(input())`.",
  "`None` ni `is None` bilan tekshiring, `== None` bilan emas.",
  "KATTA_HARF nom = konstanta. Bu \"TEGMA!\" degan signal 📢.",
];

class _Dashboard extends StatelessWidget {
  final VoidCallback onGoReview;
  const _Dashboard({required this.onGoReview});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final due = p.dueCards().length;
    final tip = _tips[DateTime.now().day % _tips.length];
    final hour = DateTime.now().hour;
    final greet = hour < 11 ? 'Xayrli tong' : (hour < 18 ? 'Salom' : 'Xayrli kech');
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(center: Alignment(0.9, -1.1), radius: 1.4, colors: [Color(0xFF23195C), C.bg]),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 30, 36, 40),
        child: Centered(
          maxWidth: 1180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- hero
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$greet, ${p.name}! 👋', style: h1()),
                      const SizedBox(height: 8),
                      Text(
                        p.totalProgress == 0
                            ? "Bugun Python olamiga sayohatni boshlaymiz. Birinchi orol — O'zgaruvchilar!"
                            : "Sarguzasht davom etmoqda — ${(p.totalProgress * 100).round()}% yo'l bosib o'tildi.",
                        style: body(C.dim).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 18),
                      Mascot(tip, size: 46),
                    ]),
                  ),
                  const SizedBox(width: 30),
                  _Ring(value: p.totalProgress),
                ],
              ),
              const SizedBox(height: 28),
              // ---- stats
              Wrap(spacing: 14, runSpacing: 14, children: [
                _Stat('⚡', '${p.xp}', 'XP', C.yellow),
                _Stat('🔥', '${p.streak}', 'kunlik seriya', C.orange),
                _Stat('🧠', '${p.masteredCards}/${allCards.length}', "o'zlashtirilgan karta", C.cyan),
                _Stat('🏆', '${p.unlocked.length}/${achievements.length}', 'yutuq', C.pink),
              ]),
              if (due > 0) ...[
                const SizedBox(height: 22),
                _ReviewBanner(count: due, onTap: onGoReview),
              ],
              const SizedBox(height: 34),
              Text('🗺️  Sarguzasht xaritasi', style: h2()),
              const SizedBox(height: 6),
              Text("Har bir orolda: nazariya → laboratoriya → amaliy kod → xotira o'yini → test",
                  style: body(C.dim)),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth > 1000 ? 3 : (c.maxWidth > 640 ? 2 : 1);
                final w = (c.maxWidth - (cols - 1) * 18) / cols;
                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [for (final l in lessons) SizedBox(width: w, child: _LessonCard(l))],
                );
              }),
              const SizedBox(height: 22),
              _ExamCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double value;
  const _Ring({required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => CustomPaint(
          painter: _RingPainter(v),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(v * 100).round()}%', style: h1().copyWith(fontSize: 32)),
              Text('umumiy', style: small()),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  _RingPainter(this.v);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawArc(r, 0, math.pi * 2, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = Colors.white.withValues(alpha: 0.08));
    canvas.drawArc(
        r,
        -math.pi / 2,
        math.pi * 2 * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(colors: [C.violet, C.pink, C.orange, C.violet]).createShader(r));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.v != v;
}

class _Stat extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _Stat(this.emoji, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: h2(color)),
            Text(label, style: small()),
          ]),
        ),
      ]),
    );
  }
}

class _ReviewBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _ReviewBanner({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Panel(
      gradient: LinearGradient(colors: [C.cyan.withValues(alpha: 0.25), C.violet.withValues(alpha: 0.25)]),
      borderColor: C.cyan.withValues(alpha: 0.4),
      child: Row(children: [
        const Text('🔁', style: TextStyle(fontSize: 40)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bugun $count ta karta takrorlashni kutyapti', style: h3()),
            const SizedBox(height: 4),
            Text("Takrorlash — bilimni yillar davomida saqlashning eng kuchli usuli. 3 daqiqa yetarli!",
                style: body(C.dim)),
          ]),
        ),
        BigButton('Takrorlash', icon: Icons.play_arrow_rounded, color: C.cyan, color2: C.blue, onTap: onTap),
      ]),
    );
  }
}

class _LessonCard extends StatefulWidget {
  final Lesson l;
  const _LessonCard(this.l);
  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final l = widget.l;
    final prog = p.lessonProgress(l);
    final stars = p.lessonStars(l);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(fadeRoute(LessonHubScreen(lesson: l))),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [l.color.withValues(alpha: 0.95), l.color2.withValues(alpha: 0.8)],
            ),
            boxShadow: [
              BoxShadow(color: l.color.withValues(alpha: _hover ? 0.45 : 0.2), blurRadius: _hover ? 30 : 16, offset: const Offset(0, 10)),
            ],
          ),
          child: Stack(children: [
            Positioned(
              right: -16,
              top: -18,
              child: Text(l.emoji, style: TextStyle(fontSize: 120, color: Colors.white.withValues(alpha: 0.25))),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(99)),
                    child: Text('${l.number}-OROL', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                  ),
                  const Spacer(),
                  for (int i = 0; i < 3; i++)
                    Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i < stars ? C.yellow : Colors.white.withValues(alpha: 0.5), size: 24),
                ]),
                const SizedBox(height: 26),
                Text(l.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 6),
                Text(l.title, style: h2(Colors.white).copyWith(fontSize: 26)),
                const SizedBox(height: 4),
                Text(l.subtitle, style: body(Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 20),
                ProgressBar(prog, color: Colors.white, height: 9),
                const SizedBox(height: 8),
                Row(children: [
                  Text('${(prog * 100).round()}% bajarildi',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(prog == 0 ? 'Boshlash →' : (prog >= 1 ? 'Takrorlash →' : 'Davom etish →'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final ready = p.totalProgress >= 0.5;
    return Panel(
      padding: const EdgeInsets.all(24),
      gradient: const LinearGradient(colors: [Color(0xFF3A2A06), Color(0xFF2A1F52)]),
      borderColor: C.yellow.withValues(alpha: 0.35),
      child: Row(children: [
        const Text('🎓', style: TextStyle(fontSize: 64)),
        const SizedBox(width: 22),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Katta imtihon', style: h2(C.yellow)),
            const SizedBox(height: 6),
            MdText(
              p.certificateDate != null
                  ? "Siz imtihondan o'tgansiz (eng yaxshi natija: **${p.examBest}%**). Sertifikatingiz tayyor!"
                  : "3 ta darsdan 20 ta aralash savol. **70%** va undan yuqori natija — shaxsiy **sertifikat** 📜"
                      "${ready ? '' : "\n\nTavsiya: avval darslarning kamida yarmini tugating."}",
              style: body(C.dim),
            ),
          ]),
        ),
        const SizedBox(width: 16),
        IntrinsicWidth(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BigButton('Imtihonni boshlash', icon: Icons.bolt_rounded, color: C.yellow, color2: C.orange,
              onTap: () => Navigator.of(context).push(fadeRoute(QuizScreen.exam()))),
          if (p.certificateDate != null) ...[
            const SizedBox(height: 10),
            BigButton('Sertifikat', icon: Icons.workspace_premium_rounded, color: C.yellow, outlined: true,
                onTap: () => Navigator.of(context).push(fadeRoute(const CertificateScreen()))),
          ],
        ])),
      ]),
    );
  }
}
