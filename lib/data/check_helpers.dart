import '../services/runner.dart';
import 'models.dart';

/// Amaliy vazifalarni tekshirish uchun yordamchi funksiyalar.

TaskVerdict? mustRun(RunResult r) {
  if (r.networkError) {
    return TaskVerdict(false, "Tekshirish uchun internet kerak: ${r.status}");
  }
  if (r.errorType == 'EOFError') {
    return const TaskVerdict(false, "Dastur kutilganidan ko'proq input() so'radi.");
  }
  if (!r.ok) {
    return TaskVerdict(false, "Kod xato bilan tugadi: ${r.errorLineText ?? r.status}");
  }
  return null;
}

TaskVerdict fail(String msg) => TaskVerdict(false, msg);

List<String> outLines(RunResult r) =>
    r.stdout.split('\n').map((l) => l.trimRight()).where((l) => l.isNotEmpty).toList();

/// Koddagi izohlarni olib tashlaydi (qidirish uchun).
String codeOnly(String code) {
  return code.split('\n').map((l) {
    final i = _commentStart(l);
    return i < 0 ? l : l.substring(0, i);
  }).join('\n');
}

int _commentStart(String line) {
  String? q;
  for (int i = 0; i < line.length; i++) {
    final c = line[i];
    if (q != null) {
      if (c == '\\') {
        i++;
      } else if (c == q) {
        q = null;
      }
    } else if (c == '"' || c == "'") {
      q = c;
    } else if (c == '#') {
      return i;
    }
  }
  return -1;
}

int countOf(String code, String what) {
  final c = codeOnly(code);
  int n = 0, i = 0;
  while ((i = c.indexOf(what, i)) >= 0) {
    n++;
    i += what.length;
  }
  return n;
}

bool codeHas(String code, String pattern) => RegExp(pattern, multiLine: true).hasMatch(codeOnly(code));
