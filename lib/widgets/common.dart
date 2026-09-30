import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/progress.dart';
import '../theme.dart';
import 'md_text.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final double radius;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
    this.gradient,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? C.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? C.border),
      ),
      child: child,
    );
  }
}

/// Katta, "o'yin" uslubidagi tugma: bosilganda biroz cho'kadi.
class BigButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final Color? color2;
  final bool outlined;
  final bool compact;
  const BigButton(this.label,
      {super.key, this.icon, this.onTap, this.color = C.violet, this.color2, this.outlined = false, this.compact = false});

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _down = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final c = enabled ? widget.color : C.faint;
    final c2 = enabled ? (widget.color2 ?? Color.lerp(widget.color, Colors.black, 0.25)!) : C.faint;
    final depth = widget.outlined ? 0.0 : 4.0;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          margin: EdgeInsets.only(top: _down ? depth : 0, bottom: _down ? 0 : depth),
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 16 : 24, vertical: widget.compact ? 10 : 15),
          decoration: BoxDecoration(
            gradient: widget.outlined
                ? null
                : LinearGradient(colors: [
                    _hover && enabled ? Color.lerp(c, Colors.white, 0.1)! : c,
                    widget.color2 != null && enabled ? widget.color2! : c,
                  ]),
            color: widget.outlined ? (_hover && enabled ? c.withValues(alpha: 0.12) : Colors.transparent) : null,
            borderRadius: BorderRadius.circular(16),
            border: widget.outlined ? Border.all(color: c.withValues(alpha: 0.7), width: 2) : null,
            boxShadow: widget.outlined || _down
                ? null
                : [BoxShadow(color: c2.withValues(alpha: enabled ? 0.9 : 0.3), offset: Offset(0, depth))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.outlined ? c : Colors.white, size: widget.compact ? 18 : 22),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.outlined ? c : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: widget.compact ? 14.5 : 16.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, this.color = C.violet, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 15, color: color), const SizedBox(width: 5)],
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color? color2;
  final double height;
  const ProgressBar(this.value, {super.key, this.color = C.violet, this.color2, this.height = 10});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Container(
        height: height,
        color: Colors.white.withValues(alpha: 0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => FractionallySizedBox(
              widthFactor: v,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color2 ?? color]),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ekran yuqorisidagi sarlavha paneli (orqaga tugmasi bilan).
class TopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final double? progress;
  final List<Widget> actions;
  const TopBar({super.key, required this.title, this.subtitle, this.color = C.violet, this.progress, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 14),
      decoration: const BoxDecoration(
        color: C.bg2,
        border: Border(bottom: BorderSide(color: C.border)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Orqaga',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: C.text),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: h3(), overflow: TextOverflow.ellipsis),
                if (subtitle != null) Text(subtitle!, style: small(), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (progress != null) SizedBox(width: 220, child: ProgressBar(progress!, color: color)),
          ...actions,
          const SizedBox(width: 8),
          const XpBadge(),
        ],
      ),
    );
  }
}

class XpBadge extends StatelessWidget {
  const XpBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Pill('🔥 ${p.streak}', color: C.orange),
        const SizedBox(width: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: p.xp, end: p.xp),
          duration: const Duration(milliseconds: 600),
          builder: (_, v, _) => Pill('⚡ $v XP', color: C.yellow),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------ confetti

class ConfettiOverlay extends StatefulWidget {
  final bool play;
  final Widget child;
  const ConfettiOverlay({super.key, required this.play, required this.child});
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  final _rnd = math.Random();
  late List<_Piece> _pieces = [];

  @override
  void initState() {
    super.initState();
    if (widget.play) _start();
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) _start();
  }

  void _start() {
    const colors = [C.violet, C.pink, C.cyan, C.yellow, C.green, C.orange, C.blue];
    _pieces = List.generate(
      140,
      (i) => _Piece(
        x: _rnd.nextDouble(),
        vx: (_rnd.nextDouble() - 0.5) * 0.5,
        vy: 0.35 + _rnd.nextDouble() * 0.7,
        delay: _rnd.nextDouble() * 0.25,
        rot: _rnd.nextDouble() * 6,
        vr: (_rnd.nextDouble() - 0.5) * 14,
        size: 6 + _rnd.nextDouble() * 8,
        color: colors[i % colors.length],
      ),
    );
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) => _c.isAnimating ? CustomPaint(painter: _ConfettiPainter(_pieces, _c.value)) : const SizedBox(),
          ),
        ),
      ),
    ]);
  }
}

class _Piece {
  final double x, vx, vy, delay, rot, vr, size;
  final Color color;
  _Piece({
    required this.x,
    required this.vx,
    required this.vy,
    required this.delay,
    required this.rot,
    required this.vr,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final tt = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (tt <= 0) continue;
      final x = (p.x + p.vx * tt) * size.width;
      final y = -20 + (p.vy * tt + 0.9 * tt * tt) * size.height;
      final paint = Paint()..color = p.color.withValues(alpha: (1 - tt * tt).clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + p.vr * tt);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
              const Radius.circular(2)),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}

/// Yangi yutuqlar va XP haqida chiroyli bildirishnoma.
void showRewards(BuildContext context, {String? message}) {
  final p = ProgressScope.read(context);
  final ach = p.takeUnlocked();
  final messenger = ScaffoldMessenger.of(context);
  if (message != null) {
    messenger.showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
  for (final a in ach) {
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF3B2A7A),
      content: Row(children: [
        Text(a.emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('🏆 Yangi yutuq: ${a.title}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text('${a.description}  (+25 XP)', style: const TextStyle(color: C.dim)),
          ]),
        ),
      ]),
    ));
  }
}

/// Maskot — Pito ilon, maslahat beradi.
class Mascot extends StatelessWidget {
  final String text;
  final double size;
  const Mascot(this.text, {super.key, this.size = 54});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Bob(child: Text('🐍', style: TextStyle(fontSize: size))),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: C.cardHi,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: C.green.withValues(alpha: 0.35)),
            ),
            child: MdText(text, style: body().copyWith(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class _Bob extends StatefulWidget {
  final Widget child;
  const _Bob({required this.child});
  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -4 * Curves.easeInOut.transform(_c.value)),
          child: Transform.rotate(angle: 0.06 * (Curves.easeInOut.transform(_c.value) - 0.5), child: child),
        ),
        child: widget.child,
      );
}

/// Chayqaladigan vidjet (noto'g'ri javob uchun).
class Shake extends StatefulWidget {
  final Widget child;
  final int trigger;
  const Shake({super.key, required this.child, required this.trigger});
  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  @override
  void didUpdateWidget(covariant Shake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) =>
            Transform.translate(offset: Offset(math.sin(_c.value * math.pi * 6) * 10 * (1 - _c.value), 0), child: child),
        child: widget.child,
      );
}

/// Sahifani ochish uchun silliq o'tish.
Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.03), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

/// Ekran ichidagi markazlashgan, keng bo'lmagan kontent.
class Centered extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const Centered({super.key, required this.child, this.maxWidth = 980});
  @override
  Widget build(BuildContext context) =>
      Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}
