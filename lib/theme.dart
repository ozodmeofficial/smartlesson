import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF0C0F2A);
  static const bg2 = Color(0xFF12163A);
  static const card = Color(0xFF1A1F4A);
  static const cardHi = Color(0xFF232A5E);
  static const border = Color(0x1FFFFFFF);
  static const text = Color(0xFFEEF0FF);
  static const dim = Color(0xFFA3A9D6);
  static const faint = Color(0xFF6B72A8);
  static const code = Color(0xFF080B20);

  static const violet = Color(0xFF8B5CF6);
  static const pink = Color(0xFFF472B6);
  static const cyan = Color(0xFF22D3EE);
  static const blue = Color(0xFF60A5FA);
  static const green = Color(0xFF34D399);
  static const yellow = Color(0xFFFACC15);
  static const orange = Color(0xFFFB923C);
  static const red = Color(0xFFF87171);
  static const grey = Color(0xFF94A3B8);

  /// Python turlarining doimiy ranglari — butun ilovada bir xil
  /// (ranglar esda qolishga yordam beradi).
  static Color forType(String t) {
    switch (t) {
      case 'int':
        return blue;
      case 'float':
        return cyan;
      case 'str':
        return green;
      case 'bool':
        return orange;
      case 'NoneType':
      case 'None':
        return grey;
      case 'complex':
        return pink;
      case 'list':
      case 'tuple':
        return violet;
    }
    return yellow;
  }
}

const mono = 'JetBrainsMono';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Nunito',
    fontFamilyFallback: const ['NotoEmoji', 'JetBrainsMono'],
    colorScheme: const ColorScheme.dark(
      primary: C.violet,
      secondary: C.cyan,
      surface: C.card,
      error: C.red,
    ),
    scaffoldBackgroundColor: C.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.text, displayColor: C.text),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(color: C.cardHi, borderRadius: BorderRadius.all(Radius.circular(8))),
      textStyle: TextStyle(color: C.text, fontFamily: 'Nunito'),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.18)),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(8),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: C.cardHi,
      contentTextStyle: TextStyle(color: C.text, fontFamily: 'Nunito', fontSize: 15),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

TextStyle h1([Color c = C.text]) => TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: c, height: 1.15);
TextStyle h2([Color c = C.text]) => TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c, height: 1.2);
TextStyle h3([Color c = C.text]) => TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c);
TextStyle body([Color c = C.text]) => TextStyle(fontSize: 16, height: 1.55, color: c, fontWeight: FontWeight.w500);
TextStyle small([Color c = C.dim]) => TextStyle(fontSize: 13.5, color: c, fontWeight: FontWeight.w600);
