import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:python_sarguzashti/data/lessons.dart';
import 'package:python_sarguzashti/data/models.dart';
import 'package:python_sarguzashti/screens/achievements.dart';
import 'package:python_sarguzashti/screens/certificate.dart';
import 'package:python_sarguzashti/screens/home.dart';
import 'package:python_sarguzashti/screens/labs/labs.dart';
import 'package:python_sarguzashti/screens/lesson_hub.dart';
import 'package:python_sarguzashti/screens/memory_game.dart';
import 'package:python_sarguzashti/screens/playground.dart';
import 'package:python_sarguzashti/screens/quiz.dart';
import 'package:python_sarguzashti/screens/review.dart';
import 'package:python_sarguzashti/screens/tasks.dart';
import 'package:python_sarguzashti/screens/theory.dart';
import 'package:python_sarguzashti/services/progress.dart';
import 'package:python_sarguzashti/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Har bir ekranni bir nechta oyna o'lchamida ochib, layout xatolari yo'qligini tekshiradi.
void main() {
  late Progress progress;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    progress = await Progress.load();
    progress.setName('Aziza');
  });

  Future<void> open(WidgetTester tester, Widget screen, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(ProgressScope(
      progress: progress,
      child: MaterialApp(theme: buildTheme(), home: screen),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  }

  final screens = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'review': () => const ReviewScreen(),
    'playground': () => const PlaygroundScreen(),
    'achievements': () => const AchievementsScreen(),
    'certificate': () => const CertificateScreen(),
    'exam': () => QuizScreen.exam(),
    for (final l in lessons) ...{
      'hub ${l.id}': () => LessonHubScreen(lesson: l),
      for (int i = 0; i < l.sections.length; i++) 'theory ${l.id} $i': () => TheoryScreen(lesson: l, start: i),
      for (int i = 0; i < l.tasks.length; i++) 'task ${l.id} $i': () => TasksScreen(lesson: l, index: i),
      'memory ${l.id}': () => MemoryGameScreen(lesson: l),
      'quiz ${l.id}': () => QuizScreen.lesson(l),
      for (final k in l.labs) 'lab ${l.id} ${k.name}': () => labScreen(l, k),
    },
  };

  for (final size in const [Size(1920, 1080), Size(1280, 760)]) {
    for (final e in screens.entries) {
      testWidgets('${e.key} @ ${size.width.toInt()}', (tester) async {
        await open(tester, e.value(), size);
        tester.view.resetPhysicalSize();
      });
    }
  }

  testWidgets('labs ishga tushadi', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(ProgressScope(
      progress: progress,
      child: MaterialApp(theme: buildTheme(), home: labScreen(lessons[0], LabKind.memoryLab)),
    ));
    await tester.pump();
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.textContaining(RegExp('Boshlash|Keyingi qadam')).first);
      await tester.pump(const Duration(milliseconds: 900));
      if (find.textContaining('Keyingi qadam').evaluate().isEmpty) break;
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    tester.view.resetPhysicalSize();
  });
}
