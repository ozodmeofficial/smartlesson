import 'package:flutter/material.dart';

import '../theme.dart';

/// Stringni munchoqlar shodasi sifatida chizadi: yuqorida musbat,
/// pastda manfiy indekslar. [selected] — ajratilgan indekslar (tartibi bilan).
class BeadsView extends StatelessWidget {
  final String text;
  final List<int> selected;
  final double size;
  final bool showNegative;
  final Color color;
  const BeadsView(this.text,
      {super.key, this.selected = const [], this.size = 46, this.showNegative = true, this.color = C.orange});

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');
    final n = chars.length;
    final idxStyle = TextStyle(fontFamily: mono, fontSize: size * 0.28, color: C.dim, fontWeight: FontWeight.w700);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ip
          Positioned(
            left: size / 2,
            right: size / 2,
            child: Container(height: 3, color: Colors.white.withValues(alpha: 0.18)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < n; i++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.07),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$i', style: idxStyle.copyWith(color: selected.contains(i) ? C.yellow : C.dim)),
                    const SizedBox(height: 4),
                    _Bead(
                      char: chars[i],
                      size: size,
                      selected: selected.contains(i),
                      order: selected.indexOf(i),
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    if (showNegative) Text('${i - n}', style: idxStyle.copyWith(color: C.faint)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bead extends StatelessWidget {
  final String char;
  final double size;
  final bool selected;
  final int order;
  final Color color;
  const _Bead({required this.char, required this.size, required this.selected, required this.order, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250 + (order < 0 ? 0 : order * 40)),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: selected
              ? [Color.lerp(color, Colors.white, 0.45)!, color]
              : [const Color(0xFF3B4280), const Color(0xFF222857)],
        ),
        boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 14)] : null,
        border: Border.all(color: Colors.white.withValues(alpha: selected ? 0.5 : 0.12)),
      ),
      child: Text(
        char == ' ' ? '␣' : char,
        style: TextStyle(
          fontFamily: mono,
          fontSize: size * 0.44,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : (char == ' ' ? C.faint : C.text),
        ),
      ),
    );
  }
}
