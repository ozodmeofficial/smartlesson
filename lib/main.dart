import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'services/progress.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await Progress.load();
  runApp(PythonSarguzashtiApp(progress: progress));
}

class PythonSarguzashtiApp extends StatelessWidget {
  final Progress progress;
  const PythonSarguzashtiApp({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      progress: progress,
      child: MaterialApp(
        title: 'Python Sarguzashti',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: p.name.isEmpty ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
