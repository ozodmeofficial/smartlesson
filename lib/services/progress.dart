import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/lessons.dart';
import '../data/models.dart';

/// Leitner qutilari: har bir quti — keyingi takrorlashgacha necha kun.
const leitnerDays = [0, 1, 3, 7, 16, 35];

class CardState {
  int box; // 0..5
  DateTime due;
  CardState(this.box, this.due);
  Map<String, dynamic> toJson() => {'b': box, 'd': due.millisecondsSinceEpoch};
  static CardState fromJson(Map<String, dynamic> j) =>
      CardState(j['b'] as int, DateTime.fromMillisecondsSinceEpoch(j['d'] as int));
}

class Progress extends ChangeNotifier {
  static const _key = 'progress_v1';
  SharedPreferences? _prefs;

  String name = '';
  int xp = 0;
  final Set<String> done = {};
  final Map<String, int> quizBest = {}; // darsId -> foiz
  final Map<String, CardState> cards = {};
  final Set<String> unlocked = {};
  int reviewed = 0;
  int streak = 0;
  String lastDay = '';
  int examBest = 0;
  String? certificateDate;
  int bestSorter = 0;
  int bestMemoryMoves = 0;

  /// Yangi ochilgan yutuqlar (UI ko'rsatib bo'lgach tozalaydi).
  final List<Achievement> justUnlocked = [];
  int lastXpGain = 0;

  static Future<Progress> load() async {
    final p = Progress();
    try {
      p._prefs = await SharedPreferences.getInstance();
      final raw = p._prefs!.getString(_key);
      if (raw != null) p._fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('progress load error: $e');
    }
    p._touchStreak();
    return p;
  }

  void _fromJson(Map<String, dynamic> j) {
    name = j['name'] as String? ?? '';
    xp = j['xp'] as int? ?? 0;
    done.addAll(((j['done'] as List?) ?? []).cast<String>());
    (j['quiz'] as Map? ?? {}).forEach((k, v) => quizBest[k as String] = v as int);
    (j['cards'] as Map? ?? {}).forEach((k, v) => cards[k as String] = CardState.fromJson((v as Map).cast()));
    unlocked.addAll(((j['ach'] as List?) ?? []).cast<String>());
    reviewed = j['reviewed'] as int? ?? 0;
    streak = j['streak'] as int? ?? 0;
    lastDay = j['lastDay'] as String? ?? '';
    examBest = j['examBest'] as int? ?? 0;
    certificateDate = j['cert'] as String?;
    bestSorter = j['sorter'] as int? ?? 0;
    bestMemoryMoves = j['memMoves'] as int? ?? 0;
  }

  Map<String, dynamic> _toJson() => {
        'name': name,
        'xp': xp,
        'done': done.toList(),
        'quiz': quizBest,
        'cards': cards.map((k, v) => MapEntry(k, v.toJson())),
        'ach': unlocked.toList(),
        'reviewed': reviewed,
        'streak': streak,
        'lastDay': lastDay,
        'examBest': examBest,
        'cert': certificateDate,
        'sorter': bestSorter,
        'memMoves': bestMemoryMoves,
      };

  Future<void> _save() async {
    try {
      await _prefs?.setString(_key, jsonEncode(_toJson()));
    } catch (e) {
      debugPrint('progress save error: $e');
    }
  }

  static String _day(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void _touchStreak() {
    final today = DateTime.now();
    final t = _day(today);
    if (lastDay == t) return;
    final yesterday = _day(today.subtract(const Duration(days: 1)));
    streak = lastDay == yesterday ? streak + 1 : 1;
    lastDay = t;
    if (streak >= 3) _unlock('streak3');
    _save();
  }

  void setName(String n) {
    name = n.trim();
    _changed();
  }

  // --------------------------------------------------------------- level

  int get level => 1 + xp ~/ 150;
  int get levelXp => xp % 150;
  static const levelSize = 150;

  String get levelTitle {
    const titles = [
      'Yangi boshlovchi 🌱',
      "Qiziquvchan o'quvchi 🔎",
      'Kod shogirdi 🧩',
      'Python sayohatchisi 🧭',
      'Yorliq ustasi 🏷️',
      'Tur detektivi 🕵️',
      'String sehrgari 🪄',
      'Python ritsari ⚔️',
      'Python ustozi 🧙',
    ];
    return titles[(level - 1).clamp(0, titles.length - 1)];
  }

  // -------------------------------------------------------------- actions

  void addXp(int amount) {
    xp += amount;
    lastXpGain = amount;
    _changed();
  }

  bool isDone(String key) => done.contains(key);

  /// Qadamni bajarilgan deb belgilaydi. Birinchi marta bo'lsa XP beradi.
  bool complete(String key, {int xpReward = 0}) {
    if (done.contains(key)) return false;
    done.add(key);
    if (xpReward > 0) {
      xp += xpReward;
      lastXpGain = xpReward;
    }
    _checkAchievements();
    _changed();
    return true;
  }

  void recordQuiz(String lessonId, int percent) {
    final prev = quizBest[lessonId] ?? 0;
    if (percent > prev) quizBest[lessonId] = percent;
    if (percent >= 60) done.add('$lessonId.quiz');
    if (percent == 100) _unlock('perfect_quiz');
    _checkAchievements();
    _changed();
  }

  void recordSorter(int score) {
    if (score > bestSorter) bestSorter = score;
    if (score >= 15) _unlock('sorter');
    _changed();
  }

  void recordMemory(int moves) {
    if (bestMemoryMoves == 0 || moves < bestMemoryMoves) bestMemoryMoves = moves;
    if (moves < 12) _unlock('memory_champ');
    _changed();
  }

  void recordExam(int percent) {
    if (percent > examBest) examBest = percent;
    if (percent >= 70) {
      certificateDate ??= _fmtDate(DateTime.now());
      _unlock('graduate');
    }
    _changed();
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  // ------------------------------------------------------ lesson progress

  List<String> lessonSteps(Lesson l) => [
        for (final s in l.sections) '${l.id}.sec.${s.id}',
        for (final lab in l.labs) '${l.id}.lab.${lab.name}',
        for (final t in l.tasks) '${l.id}.task.${t.id}',
        '${l.id}.memory',
        '${l.id}.quiz',
      ];

  double lessonProgress(Lesson l) {
    final steps = lessonSteps(l);
    return steps.where(done.contains).length / steps.length;
  }

  int lessonStars(Lesson l) {
    final q = quizBest[l.id] ?? 0;
    if (lessonProgress(l) < 1) return q >= 60 ? 1 : 0;
    if (q >= 100) return 3;
    if (q >= 80) return 2;
    return 1;
  }

  double get totalProgress {
    double s = 0;
    for (final l in lessons) {
      s += lessonProgress(l);
    }
    return s / lessons.length;
  }

  // ---------------------------------------------------------- flashcards

  /// Darsning bo'limlari o'qilganda, uning kartalari takrorlash tizimiga qo'shiladi.
  void enrollCards(Lesson l) {
    bool any = false;
    for (final c in l.cards) {
      if (!cards.containsKey(c.id)) {
        cards[c.id] = CardState(0, DateTime.now());
        any = true;
      }
    }
    if (any) _changed();
  }

  /// Testda xato qilingan mavzuni birinchi qutiga qaytarish uchun.
  void enrollAll() {
    for (final l in lessons) {
      enrollCards(l);
    }
  }

  List<String> dueCards() {
    final now = DateTime.now();
    final list = cards.entries.where((e) => !e.value.due.isAfter(now)).map((e) => e.key).toList();
    list.sort((a, b) => cards[a]!.box.compareTo(cards[b]!.box));
    return list;
  }

  void answerCard(String id, bool remembered) {
    final c = cards[id] ?? CardState(0, DateTime.now());
    if (remembered) {
      c.box = (c.box + 1).clamp(0, leitnerDays.length - 1);
    } else {
      c.box = 0;
    }
    final days = leitnerDays[c.box];
    c.due = days == 0 ? DateTime.now().add(const Duration(minutes: 10)) : DateTime.now().add(Duration(days: days));
    cards[id] = c;
    reviewed++;
    xp += remembered ? 3 : 1;
    if (reviewed >= 20) _unlock('reviewer');
    _changed();
  }

  int get masteredCards => cards.values.where((c) => c.box >= 3).length;

  // -------------------------------------------------------- achievements

  void _unlock(String id) {
    if (unlocked.add(id)) {
      final a = achievements.where((a) => a.id == id);
      if (a.isNotEmpty) justUnlocked.add(a.first);
      xp += 25;
    }
  }

  void _checkAchievements() {
    if (done.any((d) => d.contains('.sec.'))) _unlock('first_step');
    for (final l in lessons) {
      if (lessonProgress(l) >= 1) _unlock('${l.id}_done');
    }
    final tasks = done.where((d) => d.contains('.task.')).length;
    if (tasks >= 5) _unlock('coder5');
    if (tasks >= 18) _unlock('coder_all');
    if (done.where((d) => d.endsWith('.task.t6')).length >= 3) _unlock('debugger');
    if (done.contains('L3.lab.sliceNinja')) _unlock('ninja');
  }

  List<Achievement> takeUnlocked() {
    final l = List<Achievement>.from(justUnlocked);
    justUnlocked.clear();
    return l;
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    final n = name;
    xp = 0;
    done.clear();
    quizBest.clear();
    cards.clear();
    unlocked.clear();
    reviewed = 0;
    examBest = 0;
    certificateDate = null;
    bestSorter = 0;
    bestMemoryMoves = 0;
    name = n;
    _changed();
  }
}

/// Progress'ni vidjetlar daraxtiga uzatuvchi.
class ProgressScope extends InheritedNotifier<Progress> {
  const ProgressScope({super.key, required Progress progress, required super.child}) : super(notifier: progress);

  static Progress of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;

  static Progress read(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<ProgressScope>()!.widget as ProgressScope).notifier!;
}
