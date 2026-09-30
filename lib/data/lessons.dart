import 'lesson1.dart';
import 'lesson2.dart';
import 'lesson3.dart';
import 'models.dart';

final lessons = <Lesson>[lesson1, lesson2, lesson3];

Lesson lessonById(String id) => lessons.firstWhere((l) => l.id == id);

/// Barcha flesh-kartalar (id -> (dars, karta)).
final Map<String, (Lesson, FlashCard)> allCards = {
  for (final l in lessons)
    for (final c in l.cards) c.id: (l, c),
};

class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  const Achievement(this.id, this.emoji, this.title, this.description);
}

const achievements = <Achievement>[
  Achievement('first_step', '👣', 'Birinchi qadam', "Birinchi nazariya bo'limini tugatdingiz"),
  Achievement('L1_done', '🏷️', 'Yorliq ustasi', "O'zgaruvchilar darsini to'liq tugatdingiz"),
  Achievement('L2_done', '🧪', 'Tur detektivi', "Ma'lumot turlari darsini to'liq tugatdingiz"),
  Achievement('L3_done', '📿', 'String sehrgari', "Stringlar darsini to'liq tugatdingiz"),
  Achievement('perfect_quiz', '💯', 'Mukammal natija', "Testni 100% bilan yakunladingiz"),
  Achievement('memory_champ', '🧠', 'Xotira chempioni', "Xotira o'yinini 12 yurishdan kam yutdingiz"),
  Achievement('coder5', '💻', 'Kod yozuvchi', "5 ta amaliy vazifani yechdingiz"),
  Achievement('coder_all', '🚀', 'Kod ustasi', "Barcha 18 ta amaliy vazifani yechdingiz"),
  Achievement('sorter', '⚡', 'Tezkor saralovchi', "Tur saralash o'yinida 15+ ball to'pladingiz"),
  Achievement('ninja', '🥷', 'Slice ninja', "Slice ninja o'yinining barcha darajalarini o'tdingiz"),
  Achievement('reviewer', '🔁', 'Takrorchi', "20 ta flesh-kartani takrorladingiz"),
  Achievement('streak3', '🔥', 'Olov', "3 kun ketma-ket o'qidingiz"),
  Achievement('debugger', '🐞', 'Xato ovchisi', "3 ta \"xatolarni tuzating\" vazifasini yechdingiz"),
  Achievement('graduate', '🎓', 'Python sarguzashtchisi', "Katta imtihondan o'tib, sertifikat oldingiz"),
];
