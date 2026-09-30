import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:python_sarguzashti/data/lessons.dart';
import 'package:python_sarguzashti/main.dart';
import 'package:python_sarguzashti/screens/labs/labs.dart';
import 'package:python_sarguzashti/screens/labs/slice_ninja.dart';
import 'package:python_sarguzashti/services/progress.dart';
import 'package:python_sarguzashti/services/runner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('slice algoritmi Python bilan mos', () {
    String sl(String s, int? a, int? b, int? c) => sliceIndices(a, b, c, s.length).map((i) => s[i]).join();
    expect(sl('Python', 0, 3, null), 'Pyt');
    expect(sl('salom', null, null, -1), 'molas');
    expect(sl('0123456789', 1, null, 2), '13579');
    expect(sl('hisobot.pdf', null, -4, null), 'hisobot');
    expect(sl('Python', -1, -4, -1), 'noh');
    expect(sl('Python', 4, 1, null), '');
    expect(evalSlice('abcdefgh', '[7:1:-2]'), 'hfd');
    expect(evalSlice('Python', '[-1]'), 'n');
    expect(evalSlice('Python', '[10]'), '⛔ IndexError');
  });

  test('izohlardan kutilgan natija', () {
    const code = 'x = 10\nprint(x)\n# Natija: 10   — izoh\nprint(bool(""))       # Natija: False (bo\'sh matn)\nprint(1)\n# Natija:\n# a\n# b';
    expect(CodeRunner.expectedFromComments(code), '10\nFalse\na\nb');
  });

  test('darslik tarkibi to\'liq', () {
    for (final l in lessons) {
      expect(l.sections.length, greaterThanOrEqualTo(7));
      expect(l.tasks.length, 6);
      expect(l.quiz.length, greaterThanOrEqualTo(12));
      expect(l.pairs.length, greaterThanOrEqualTo(8));
      for (final q in l.quiz) {
        expect(q.correct, lessThan(q.options.length));
      }
      for (final s in l.sections) {
        if (s.check != null) expect(s.check!.correct, lessThan(s.check!.options.length));
      }
    }
  });

  testWidgets('ilova ochiladi va darslarga o\'tadi', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    SharedPreferences.setMockInitialValues({});
    final p = await Progress.load();
    await tester.pumpWidget(PythonSarguzashtiApp(progress: p));
    await tester.pump();
    expect(find.text('Ismingiz nima?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Aziza');
    await tester.pump();
    await tester.tap(find.text('Sarguzashtni boshlash'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Aziza'), findsWidgets);
    await tester.ensureVisible(find.text("O'zgaruvchilar").first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("O'zgaruvchilar").first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Nazariya'), findsOneWidget);
    await tester.ensureVisible(find.text("O'zgaruvchi nima?"));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("O'zgaruvchi nima?"));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('TEZKOR SAVOL'), findsOneWidget);
    // Ogohlantirishsiz barcha ekranlarni ochib chiqamiz
    tester.view.resetPhysicalSize();
  });
}
