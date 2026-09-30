import 'package:flutter/material.dart';

import '../../data/models.dart';
import 'memory_lab.dart';
import 'name_game.dart';
import 'slice_lab.dart';
import 'slice_ninja.dart';
import 'truthy_game.dart';
import 'type_sorter.dart';

(String, String, String) labInfo(LabKind k) => switch (k) {
      LabKind.memoryLab => ('🔬', 'Xotira laboratoriyasi', "Yorliqlar va id() ni animatsiyada ko'ring"),
      LabKind.nameGame => ('🏷️', 'Nom tekshiruvchi', "To'g'ri, yomon yoki xato nom?"),
      LabKind.typeSorter => ('⚡', 'Tur saralash', "60 soniyada qiymatlarni turlarga ajrating"),
      LabKind.truthyGame => ('⚖️', 'Truthy yoki Falsy?', "bool() nima qaytaradi — tez javob bering"),
      LabKind.sliceLab => ('🔪', 'Slicing ustaxonasi', "start, stop, step ni surib ko'ring"),
      LabKind.sliceNinja => ('🥷', 'Slice ninja', "10 daraja: kerakli bo'lakni kesib oling"),
    };

Widget labScreen(Lesson l, LabKind k) => switch (k) {
      LabKind.memoryLab => MemoryLabScreen(lesson: l),
      LabKind.nameGame => NameGameScreen(lesson: l),
      LabKind.typeSorter => TypeSorterScreen(lesson: l),
      LabKind.truthyGame => TruthyGameScreen(lesson: l),
      LabKind.sliceLab => SliceLabScreen(lesson: l),
      LabKind.sliceNinja => SliceNinjaScreen(lesson: l),
    };

/// Python'dagi slice.indices() algoritmi — tanlangan indekslarni qaytaradi.
List<int> sliceIndices(int? start, int? stop, int? step, int len) {
  final st = step ?? 1;
  if (st == 0) return const [];
  final lower = st > 0 ? 0 : -1;
  final upper = st > 0 ? len : len - 1;
  int norm(int? v, int def) {
    if (v == null) return def;
    var x = v;
    if (x < 0) {
      x += len;
      if (x < lower) x = lower;
    } else if (x > upper) {
      x = upper;
    }
    return x;
  }

  final a = norm(start, st < 0 ? upper : lower);
  final b = norm(stop, st < 0 ? lower : upper);
  final out = <int>[];
  if (st > 0) {
    for (int i = a; i < b; i += st) {
      out.add(i);
    }
  } else {
    for (int i = a; i > b; i += st) {
      out.add(i);
    }
  }
  return out;
}

/// Laboratoriya o'yinlari uchun umumiy "natija" oynasi.
Future<void> showLabResult(BuildContext context,
    {required String emoji, required String title, required String text, required Color color}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: const Color(0xFF1A1F4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFA3A9D6))),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Davom etish', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ]),
        ),
      ),
    ),
  );
}
