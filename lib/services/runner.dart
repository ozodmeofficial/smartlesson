import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Python kodini Judge0 serverida ishga tushirish natijasi.
class RunResult {
  final String stdout;
  final String stderr;
  final int statusId; // 3 = Accepted, 5 = vaqt tugadi, 6 = kompilyatsiya, 11+ = runtime xato
  final String status;
  final String? time;
  final bool networkError;

  const RunResult({
    required this.stdout,
    required this.stderr,
    required this.statusId,
    required this.status,
    this.time,
    this.networkError = false,
  });

  bool get ok => !networkError && statusId == 3 && stderr.trim().isEmpty;

  /// Traceback'ning oxirgi qatori: "NameError: name 'x' is not defined"
  String? get errorLineText {
    final lines = stderr.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;
    return lines.last.trim();
  }

  String? get errorType {
    final l = errorLineText;
    if (l == null) return null;
    final m = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*(?:Error|Exception|Exit|Interrupt))\b').firstMatch(l);
    return m?.group(1);
  }

  String? get errorMessage {
    final l = errorLineText;
    if (l == null) return null;
    final i = l.indexOf(':');
    return i < 0 ? '' : l.substring(i + 1).trim();
  }

  int? get errorLine {
    final ms = RegExp(r'line (\d+)').allMatches(stderr).toList();
    if (ms.isEmpty) return null;
    return int.tryParse(ms.last.group(1)!);
  }
}

class CodeRunner {
  static const endpoint = 'https://tpcg2.tutorialspoint.com/judge0/submissions?base64_encoded=true&wait=true';
  static const pythonLanguageId = 71; // Python 3

  static String _b64(String s) => base64.encode(utf8.encode(s));

  static String _unb64(Object? v) {
    if (v is! String || v.isEmpty) return '';
    try {
      return utf8.decode(base64.decode(v.replaceAll(RegExp(r'\s'), '')), allowMalformed: true);
    } catch (_) {
      return v;
    }
  }

  /// Kodni ishga tushiradi. [stdin] — input() uchun qatorlar (har biri yangi qatorda).
  static Future<RunResult> run(String code, {String stdin = ''}) async {
    try {
      final resp = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'source_code': _b64(code),
              'language_id': pythonLanguageId,
              'stdin': _b64(stdin.isEmpty || stdin.endsWith('\n') ? stdin : '$stdin\n'),
              'base64_encoded': true,
            }),
          )
          .timeout(const Duration(seconds: 25));
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return RunResult(
          stdout: '',
          stderr: '',
          statusId: -1,
          status: 'Server javobi: ${resp.statusCode}',
          networkError: true,
        );
      }
      final j = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final st = (j['status'] as Map?) ?? const {};
      var stderr = _unb64(j['stderr']);
      final compile = _unb64(j['compile_output']);
      if (stderr.isEmpty && compile.isNotEmpty) stderr = compile;
      final id = (st['id'] as num?)?.toInt() ?? 0;
      return RunResult(
        stdout: _unb64(j['stdout']),
        stderr: stderr,
        statusId: id,
        status: (st['description'] as String?) ?? '',
        time: j['time']?.toString(),
      );
    } on TimeoutException {
      return const RunResult(
          stdout: '', stderr: '', statusId: -1, status: 'Server javob bermadi (vaqt tugadi)', networkError: true);
    } catch (e) {
      return RunResult(stdout: '', stderr: '', statusId: -1, status: "Internetga ulanib bo'lmadi", networkError: true);
    }
  }

  /// Darslikdagi `# Natija: ...` izohlaridan kutilgan natijani yig'adi
  /// (internet bo'lmaganda ko'rsatish uchun).
  static String expectedFromComments(String code) {
    final out = <String>[];
    final lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i].trim();
      final m = RegExp(r'#\s*Natija:\s?(.*)$').firstMatch(l);
      if (m == null) continue;
      var v = m.group(1)!.trim();
      if (v.isEmpty && l.startsWith('#')) {
        // ko'p qatorli natija: keyingi "# ..." qatorlar
        for (int j = i + 1; j < lines.length; j++) {
          final n = lines[j].trim();
          if (!n.startsWith('#') || n.contains('Natija')) break;
          out.add(n.substring(1).trimLeft());
          i = j;
        }
        continue;
      }
      // "Natija: 10   — izoh" ko'rinishidagi izohni kesamiz
      v = v.split(RegExp(r'\s+(—|<-|\(|#)')).first.trim();
      out.add(v);
    }
    return out.join('\n');
  }
}

/// Python xatolarini o'zbek tilida tushuntirish.
String explainError(String? type, String? message) {
  final m = message ?? '';
  switch (type) {
    case 'NameError':
      final n = RegExp(r"name '([^']+)'").firstMatch(m)?.group(1);
      return "Python `${n ?? 'bu nom'}` degan nomni topa olmadi. Avval unga qiymat bering "
          "yoki harflarni tekshiring — `ism` va `Ism` Python uchun butunlay boshqa nomlar!";
    case 'SyntaxError':
      if (m.contains('invalid decimal literal')) {
        return "O'zgaruvchi nomi raqam bilan boshlanmaydi. Masalan `2narx` emas, `narx2` yozing.";
      }
      if (m.contains('cannot assign to expression')) {
        return "Nomda `-` belgisi bo'lishi mumkin emas — Python uni ayirish deb o'ylaydi. `_` ishlating: `narx_yangi`.";
      }
      if (m.contains('cannot assign to literal')) {
        return "`=` chap tomonida doim o'zgaruvchi nomi turadi: `narx = 1000`, `1000 = narx` emas.";
      }
      if (m.contains('unterminated string')) {
        return "Matn tirnog'i yopilmagan. Ichida `'` bo'lsa, tashqariga qo'sh tirnoq qo'ying: \"men'ning\".";
      }
      if (m.contains('never closed')) return "Qavs ochilgan, lekin yopilmagan. Har bir `(` uchun `)` bo'lishi kerak.";
      return "Python yozilish qoidasi buzilgan. Nomda bo'shliq yo'qmi? Kalit so'z (`class`, `for`...) nom qilinmaganmi?";
    case 'IndentationError':
      return "Chekinish (bo'shliq) noto'g'ri. `if`, `for`, `def` dan keyingi qatorlar 4 ta bo'shliq bilan ichkariga suriladi.";
    case 'TypeError':
      if (m.contains('can only concatenate str')) {
        return "Matnga son qo'shib bo'lmaydi. Sonni `str(25)` bilan matnga aylantiring yoki f-string ishlating: f\"Yosh: {yosh}\".";
      }
      if (m.contains('does not support item assignment')) {
        return "String o'zgarmas (immutable)! Ichidagi harfni almashtirib bo'lmaydi — yangi string yasang: \"K\" + soz[1:].";
      }
      if (m.contains('not callable')) {
        return "Siz funksiya bo'lmagan narsani chaqiryapsiz. Ehtimol `str`, `list`, `print` kabi nomni o'zgaruvchi qilib qo'ygansiz.";
      }
      if (m.contains('not supported between')) return "Har xil turdagi qiymatlarni (masalan, matn va son) `<`, `>` bilan solishtirib bo'lmaydi.";
      if (m.contains('unsupported operand')) return "Bu amal bu turlar uchun ishlamaydi. Qiymatlar turini `type()` bilan tekshiring.";
      return "Qiymat turi mos emas. `type()` yordamida turlarni tekshiring.";
    case 'IndexError':
      return "Bunday indeks yo'q. Esda tuting: indekslar 0 dan boshlanadi, oxirgi indeks = len() - 1.";
    case 'ValueError':
      if (m.contains('invalid literal for int')) return "Bu matnni butun songa aylantirib bo'lmaydi — unda raqam bo'lmagan belgilar bor.";
      return "Qiymat to'g'ri turda, lekin mazmuni yaroqsiz.";
    case 'AttributeError':
      return "Bu turda bunday metod yo'q. Nomini tekshiring (masalan `uper` emas, `upper`).";
    case 'ZeroDivisionError':
      return "Nolga bo'lish mumkin emas!";
    case 'EOFError':
      return "Dastur input() so'radi, lekin kiritma (stdin) bo'sh. Pastdagi «Kiritma» maydoniga qiymat yozing.";
    case 'KeyError':
      return "Lug'atda bunday kalit yo'q.";
  }
  return "Xato matnini diqqat bilan o'qing — oxirgi qator eng muhim ma'lumotni beradi.";
}
