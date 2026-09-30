import 'package:flutter/material.dart';

import 'check_helpers.dart';
import 'models.dart';

final lesson2 = Lesson(
  id: 'L2',
  number: 2,
  title: "Ma'lumot turlari",
  subtitle: 'int, float, bool, None va boshqalar',
  emoji: '🧪',
  color: const Color(0xFF06B6D4),
  color2: const Color(0xFF3B82F6),
  intro: r"""Bu darsda Python'dagi asosiy **ma'lumot turlari** (data types) bilan tanishasiz. Har bir qiymat o'z turiga ega bo'lishini va bu nima uchun muhimligini tushunib olasiz.""",
  goals: const [
    "Nima uchun dasturlashda ma'lumot turlari kerakligini",
    "`int` (butun son) va katta sonlarni chiroyli yozishni",
    "`float` (kasr son) va mashhur `0.1 + 0.2` muammosini",
    "`bool` (mantiqiy tur), truthy va falsy qiymatlarni",
    "`None` nima va u qachon ishlatilishini",
    "`type()` va `isinstance()` bilan turni tekshirishni",
  ],
  labs: const [LabKind.typeSorter, LabKind.truthyGame],
  sections: const [
    Section('s1', '🍳', "Nima uchun turlar kerak?", [
      AnalogyBlock('🍳', 'Oshxona idishlari', r"""Oshxonada un uchun — **qop**, sut uchun — **shisha**, tuxum uchun — maxsus **quti** ishlatiladi. Har bir mahsulot o'ziga mos idishda saqlanadi. Sutni qopga quysangiz, hammasi to'kiladi! 🥛💦

Kompyuter xotirasi ham xuddi shunday. Har xil ma'lumot har xil "idish"da saqlanadi. Bu idishlarni **ma'lumot turlari** (data types) deb ataymiz."""),
      TextBlock(r"""Tur nafaqat saqlash usulini, balki qiymat ustida **qanday amallar** bajarish mumkinligini ham belgilaydi:"""),
      CodeBlock(r'''# Sonlarni qo'shsak - matematik qo'shish bo'ladi
print(5 + 3)
# Natija: 8

# Matnlarni "qo'shsak" - ular birikadi
print("5" + "3")
# Natija: 53'''),
      TextBlock(r"""Bir xil `+` belgisi, lekin natija **butunlay boshqacha**. Sababi — turlar har xil."""),
      MnemonicBlock(r"""**Tur = idish 🫙.** Idish nima solish mumkinligini va u bilan nima qilish mumkinligini belgilaydi. `5 + 3 = 8`, lekin `"5" + "3" = "53"` — *raqamlar qo'shiladi, matnlar yopishadi*."""),
    ], check: QuickCheck("Natija nima?", ['8', '53', '"8"', 'Xato'], 1,
        "Ikkalasi ham matn (str) — `+` ularni yopishtiradi.", code: 'print("5" + "3")')),
    Section('s2', '🔢', "int — butun sonlar", [
      TextBlock(r"""`int` (integer, butun son) — kasr qismisiz sonlar. Musbat, manfiy yoki nol bo'lishi mumkin."""),
      CodeBlock(r'''yosh = 25
harorat = -7
nol = 0

print(yosh, harorat, nol)
# Natija: 25 -7 0'''),
      TextBlock(r"""Python'da `int` turining **chegarasi yo'q**. Ko'p tillarda son juda katta bo'lsa xato beradi, Python'da esa yo'q:"""),
      CodeBlock(r'''# 2 ning 100-darajasi - juda katta son
katta = 2 ** 100
print(katta)
# Natija: 1267650600228229401496703205376

print(type(katta))
# Natija: <class 'int'>'''),
      TextBlock(r"""### Pastki chiziq bilan ajratish
Katta sonni o'qish qiyin. Python'da raqamlar orasiga `_` qo'yish mumkin — bu **faqat ko'z uchun**, qiymatga ta'sir qilmaydi:"""),
      CodeBlock(r'''maosh1 = 15000000       # Oddiy yozuv - o'qish qiyin
maosh2 = 15_000_000     # Ajratgich bilan - ancha tushunarli

print(maosh1 == maosh2)
# Natija: True

print(maosh2)
# Natija: 15000000'''),
      MnemonicBlock(r"""**int — cheksiz narvon 🪜.** Python'da butun son qancha katta bo'lsa ham sig'adi. `_` esa — *minglik "vergul"i*: `15_000_000` = 15 million."""),
    ], check: QuickCheck("`print(1_000_000)` nima chiqaradi?", ['1_000_000', '1000000', '1,000,000', 'SyntaxError'], 1,
        "`_` faqat o'qish qulayligi uchun — chiqarishda ko'rinmaydi.")),
    Section('s3', '🌊', "float — kasr sonlar", [
      TextBlock(r"""`float` (floating point, suzuvchi nuqta) — kasr qismi bor sonlar. Python'da kasr **nuqta** bilan yoziladi, vergul bilan emas."""),
      CodeBlock(r'''narx = 19.99
pi = 3.14159
manfiy = -0.5

# Faqat nuqta qo'ysangiz ham float bo'ladi
son = 5.0
print(type(son))
# Natija: <class 'float'>'''),
      TextBlock(r"""Juda katta yoki kichik sonlar uchun **ilmiy yozuv** ishlatiladi:"""),
      CodeBlock(r'''katta = 1.5e6      # 1.5 * 10 ning 6-darajasi
print(katta)
# Natija: 1500000.0

kichik = 2.5e-3    # 2.5 * 10 ning -3-darajasi
print(kichik)
# Natija: 0.0025'''),
      TextBlock(r"""### 🤯 Mashhur 0.1 + 0.2 muammosi"""),
      CodeBlock(r'''natija = 0.1 + 0.2
print(natija)
# Natija: 0.30000000000000004

print(natija == 0.3)
# Natija: False'''),
      AnalogyBlock('🍰', "Tortni 3 ga bo'lish", r"""Bu Python'ning xatosi emas! Kompyuter sonlarni **ikkilik** (binary) sanoq sistemasida saqlaydi. `0.1` ni ikkilikda aniq yozib bo'lmaydi — xuddi `1/3` ni o'nlikda `0.3333...` deb **cheksiz** yozganimiz kabi. Qayerdadir kesishga to'g'ri keladi — kichik "qoldiq" paydo bo'ladi."""),
      TextBlock(r"""Yechim — `round()` funksiyasi yoki farqni tekshirish:"""),
      CodeBlock(r'''natija = 0.1 + 0.2

# 1-usul: yaxlitlash
print(round(natija, 2))
# Natija: 0.3

print(round(natija, 2) == 0.3)
# Natija: True

# 2-usul: juda kichik farqni tekshirish
farq = abs(natija - 0.3)
print(farq < 0.000001)
# Natija: True'''),
      NoteBlock(r"""Pul bilan ishlaganda `float` ishlatmang. Buning uchun Python'da maxsus `decimal` moduli bor. Yoki summani **tiyinlarda** butun son sifatida saqlang.""", kind: NoteKind.warning),
      MnemonicBlock(r"""**"0.1 + 0.2 ≠ 0.3" — float suzadi 🛶.** Kasr sonlar suvdagi qayiq kabi biroz tebranadi. Shuning uchun ularni `==` bilan emas, `round()` bilan solishtiring."""),
    ], check: QuickCheck("`0.1 + 0.2 == 0.3` nima qaytaradi?", ['True', 'False', '0.3', 'Xato'], 1,
        "Ikkilik tizimdagi yaxlitlash sababli 0.1 + 0.2 = 0.30000000000000004 bo'ladi.")),
    Section('s4', '💡', "bool — rost yoki yolg'on", [
      TextBlock(r"""`bool` (boolean, mantiqiy tur) faqat ikkita qiymatga ega: `True` (rost) va `False` (yolg'on). Diqqat — **bosh harf** bilan yoziladi."""),
      CodeBlock(r'''yoqdi = True
tugadi = False
print(yoqdi, tugadi)
# Natija: True False

# Taqqoslash natijasi ham bool bo'ladi
print(10 > 5)
# Natija: True

print(3 == 7)
# Natija: False'''),
      TextBlock(r"""Qiziq tomoni: `bool` aslida `int` ning bir turi. `True` = 1, `False` = 0:"""),
      CodeBlock(r'''print(True + True)
# Natija: 2

print(False * 100)
# Natija: 0'''),
      TextBlock(r"""### Truthy va Falsy qiymatlar
Har qanday qiymatni `bool()` orqali rost yoki yolg'onga aylantirish mumkin. **"Bo'sh" narsalar — yolg'on, qolganlari — rost.**"""),
      CodeBlock(r'''print(bool(0))        # Natija: False
print(bool(0.0))      # Natija: False
print(bool(""))       # Natija: False (bo'sh matn)
print(bool([]))       # Natija: False (bo'sh ro'yxat)
print(bool({}))       # Natija: False (bo'sh lug'at)
print(bool(None))     # Natija: False

# Qolgan hammasi - True
print(bool(1))        # Natija: True
print(bool(-5))       # Natija: True
print(bool("0"))      # Natija: True (bo'sh emas matn!)
print(bool(" "))      # Natija: True (probel ham belgi)
print(bool([0]))      # Natija: True (bo'sh emas ro'yxat)''', runnable: true),
      MnemonicBlock(r"""**"Bo'sh cho'ntak yolg'on gapiradi" 👖.** Falsy oilasi — **0, 0.0, "", [], {}, None**: hammasi "hech narsa". Ichida *bitta bo'lsa ham* narsa bor (hatto `" "` yoki `"0"`) — bu **True**!"""),
    ], check: QuickCheck("`bool(\"0\")` nima qaytaradi?", ['True', 'False', '0', 'Xato'], 0,
        "\"0\" — bo'sh emas matn (ichida bitta belgi bor), shuning uchun True.")),
    Section('s5', '🕳️', "None — hech narsa", [
      TextBlock(r"""`None` — bu **"qiymat yo'q"** degani. Bu nol ham emas, bo'sh matn ham emas. Bu — bo'shliqning o'zi."""),
      AnalogyBlock('🍎', 'Quti va olmalar', r"""Stol ustida quti turibdi. Agar quti ichida **0 ta olma** bo'lsa — bu `0`.
Agar **qutining o'zi yo'q** bo'lsa — bu `None`."""),
      CodeBlock(r'''natija = None

print(natija)
# Natija: None

print(type(natija))
# Natija: <class 'NoneType'>'''),
      TextBlock(r"""`None` qachon kerak?"""),
      CodeBlock(r'''# 1. O'zgaruvchini hozircha bo'sh qoldirish uchun
foydalanuvchi = None

# 2. Funksiya hech narsa qaytarmasa - avtomatik None qaytaradi
def salomlash(ism):
    print("Salom,", ism)

javob = salomlash("Ali")
# Natija: Salom, Ali

print(javob)
# Natija: None'''),
      TextBlock(r"""`None` ni tekshirishda `==` emas, **`is`** ishlatiladi:"""),
      CodeBlock(r'''qiymat = None

if qiymat is None:
    print("Qiymat berilmagan")
# Natija: Qiymat berilmagan'''),
      MnemonicBlock(r"""**None — bo'sh stul 🪑 emas, stulning yo'qligi.** `0` — "nol ball", `""` — "bo'sh qog'oz", `None` — "hali imtihon topshirilmagan"."""),
    ], check: QuickCheck("`None` ni tekshirishning to'g'ri usuli qaysi?", ['`x == None`', '`x is None`', '`x = None`', '`None(x)`'], 1,
        "`is None` — Python uslubi (PEP 8). `x = None` esa qiymat berish!")),
    Section('s6', '🌀', "complex — kompleks sonlar", [
      TextBlock(r"""Python'da matematik kompleks sonlar uchun ham alohida tur bor. Boshlang'ich darajada kamdan-kam kerak bo'ladi, shunchaki **bilib qo'ying**:"""),
      CodeBlock(r'''z = 3 + 4j     # j - mavhum birlik

print(z)
# Natija: (3+4j)

print(type(z))
# Natija: <class 'complex'>

print(z.real, z.imag)
# Natija: 3.0 4.0'''),
      MnemonicBlock(r"""**j — "jinni" son 🧞.** Matematikada `i`, Python'da `j` (muhandislar odati). `3 + 4j` — bitta son, ikki qismli."""),
    ], check: QuickCheck("`type(2j)` nima?", ["<class 'int'>", "<class 'float'>", "<class 'complex'>", 'SyntaxError'], 2,
        "`j` qo'shimchasi mavhum qismni bildiradi — bu complex son.")),
    Section('s7', '🔎', "type() va isinstance()", [
      TextBlock(r"""Qiymatning turini bilish uchun ikkita vosita bor. `type()` — **aniq turni** qaytaradi:"""),
      CodeBlock(r'''print(type(42))
# Natija: <class 'int'>

print(type(3.14))
# Natija: <class 'float'>

print(type("salom"))
# Natija: <class 'str'>

print(type(True))
# Natija: <class 'bool'>'''),
      TextBlock(r"""`isinstance()` — **"bu qiymat shu turdanmi?"** degan savolga `True`/`False` javob beradi. Amalda ko'proq shu ishlatiladi:"""),
      CodeBlock(r'''yosh = 25

print(isinstance(yosh, int))
# Natija: True

print(isinstance(yosh, str))
# Natija: False

# Bir nechta turni birdan tekshirish mumkin
print(isinstance(3.14, (int, float)))
# Natija: True'''),
      TableBlock(['Tur', "To'liq nomi", 'Misol', 'Falsy qiymati', "O'zgarmasmi"], [
        ['`int`', 'Butun son', '`42`, `-7`, `1_000`', '`0`', 'Ha'],
        ['`float`', 'Kasr son', '`3.14`, `-0.5`, `2e3`', '`0.0`', 'Ha'],
        ['`bool`', 'Mantiqiy', '`True`, `False`', '`False`', 'Ha'],
        ['`str`', 'Matn', '`"salom"`', '`""`', 'Ha'],
        ['`None`', "Bo'shliq", '`None`', '`None`', 'Ha'],
        ['`complex`', 'Kompleks son', '`3 + 4j`', '`0j`', 'Ha'],
      ]),
      NoteBlock(r"""**"O'zgarmas" (immutable)** degani — qiymatni yaratgandan keyin uni ichidan o'zgartirib bo'lmaydi. `x = 5` deb, keyin `x = 6` desangiz, 5 soni o'zgarmaydi — shunchaki `x` boshqa songa qaraydi."""),
      MnemonicBlock(r"""**type() — "Sen kimsan?" 🪪, isinstance() — "Sen ... misan?" ✅❌.** Birinchisi ism aytadi, ikkinchisi faqat "ha/yo'q" deydi."""),
    ], check: QuickCheck("`isinstance(True, int)` nima qaytaradi?", ['True', 'False', 'Xato', 'None'], 0,
        "bool — int ning \"farzandi\" (True = 1). Shuning uchun True ham int hisoblanadi!")),
    Section('s8', '⚠️', "Ko'p uchraydigan xatolar", [
      TextBlock(r"""**1. `true` yoki `TRUE` deb yozish.** Python'da faqat `True` va `False` — birinchi harf katta:"""),
      CodeBlock(r'''yoqdi = true
# Natija: NameError: name 'true' is not defined'''),
      TextBlock(r"""**2. Kasr sonni vergul bilan yozish.** `3,14` — bu kasr emas, bu **ikkita alohida son** (tuple):"""),
      CodeBlock(r'''notogri = 3,14
print(type(notogri))
# Natija: <class 'tuple'>

togri = 3.14
print(type(togri))
# Natija: <class 'float'>'''),
      TextBlock(r"""**3. `float` ni `==` bilan aniq taqqoslash** — kutilmagan natija beradi. `round()` ishlating.
**4. `None` ni matn bilan chalkashtirish:**"""),
      CodeBlock(r'''print(None == "None")
# Natija: False'''),
      TextBlock(r"""**5. `None` ni `==` bilan tekshirish.** Ishlaydi, lekin to'g'ri uslub emas. Har doim `is None` yoki `is not None` yozing."""),
    ], check: QuickCheck("`x = 3,14` dan keyin `type(x)` nima?", ["<class 'float'>", "<class 'tuple'>", "<class 'str'>", 'SyntaxError'], 1,
        "Vergul Python'da elementlarni ajratadi — ikkita sondan iborat tuple hosil bo'ladi.")),
  ],
  tasks: [
    CodeTask(
      id: 't1',
      title: "Beshta idish",
      description: r"""5 ta o'zgaruvchi yarating: **butun son, kasr son, matn, mantiqiy qiymat va `None`**. Har birining turini `type()` bilan chiqaring.""",
      starter: r'''butun = 7
# qolganlarini yarating

print(type(butun))
''',
      solution: r'''butun = 7
kasr = 3.5
matn = "salom"
mantiqiy = True
hech = None

print(type(butun))
print(type(kasr))
print(type(matn))
print(type(mantiqiy))
print(type(hech))
''',
      hints: ["`kasr = 3.5`, `matn = \"salom\"`, `mantiqiy = True`, `hech = None`"],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        for (final t in ['int', 'float', 'str', 'bool', 'NoneType']) {
          if (!r.stdout.contains("<class '$t'>")) return fail("`<class '$t'>` natijada yo'q.");
        }
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't2',
      title: "Pastki chiziq sirri",
      description: r"""`1_000_000` va `1000000` sonlarini `==` bilan taqqoslang va natijani chiqaring. Nima uchun `True` chiqishini izohda (`#`) yozing.""",
      starter: r'''a = 1_000_000
b = 1000000
# taqqoslang:
''',
      solution: r'''a = 1_000_000
b = 1000000
print(a == b)
# True, chunki _ faqat o'qish uchun, qiymatga ta'sir qilmaydi
''',
      hints: ["`print(a == b)`"],
      check: (code, run) async {
        if (!codeHas(code, r'1_000_000')) return fail("`1_000_000` yozuvidan foydalaning.");
        if (!code.contains('#')) return fail("Sababini izohda (`# ...`) yozing.");
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (!r.stdout.contains('True')) return fail("Natijada True chiqishi kerak.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't3',
      title: "Suzuvchi nuqtani qo'lga olish",
      description: r"""`0.1 + 0.2 + 0.3` ni hisoblang. Avval xom natijani, keyin `round()` bilan **2 xonagacha** yaxlitlangan natijani chiqaring.""",
      starter: r'''natija = 0.1 + 0.2 + 0.3
print(natija)
''',
      solution: r'''natija = 0.1 + 0.2 + 0.3
print(natija)
print(round(natija, 2))
''',
      hints: ["`round(natija, 2)`"],
      check: (code, run) async {
        if (!codeHas(code, r'round\(')) return fail("`round()` funksiyasidan foydalaning.");
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (!outLines(r).contains('0.6')) return fail("Yaxlitlangan natija `0.6` alohida qatorda chiqsin.");
        return const TaskVerdict(true, "Barakalla! Xom natija 0.6000000000000001 edi — round() uni tartibga keltirdi. 🛶");
      },
    ),
    CodeTask(
      id: 't4',
      title: "Truthy/Falsy bashorat",
      description: r"""Quyidagi qiymatlarni **shu tartibda** `bool()` ga bering va natijani chiqaring:
`0`, `""`, `" "`, `[]`, `[0]`, `"False"`, `None`

Avval natijani o'zingiz taxmin qiling, keyin tekshiring! 🔮""",
      starter: r'''print(bool(0))
''',
      solution: r'''print(bool(0))
print(bool(""))
print(bool(" "))
print(bool([]))
print(bool([0]))
print(bool("False"))
print(bool(None))
''',
      hints: ["Har biri uchun alohida `print(bool(...))`", "Esda tuting: `\"False\"` — bo'sh emas matn!"],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        final words = RegExp(r'\b(True|False)\b').allMatches(r.stdout).map((m) => m.group(0)).toList();
        const expected = ['False', 'False', 'True', 'False', 'True', 'True', 'False'];
        if (words.length != 7) return fail("Aynan 7 ta natija chiqishi kerak, sizda ${words.length} ta.");
        for (int i = 0; i < 7; i++) {
          if (words[i] != expected[i]) return fail("${i + 1}-natija ${expected[i]} bo'lishi kerak edi. Tartibni tekshiring.");
        }
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't5',
      title: "input() siri",
      description: r"""Foydalanuvchidan yoshini `input()` bilan so'rang. `isinstance()` bilan uning turi `str` ekanini tekshirib chiqaring va **sababini izohda** yozing.""",
      starter: r'''yosh = input("Yoshingiz: ")
''',
      solution: r'''yosh = input("Yoshingiz: ")
print(isinstance(yosh, str))
# True, chunki input() har doim matn (str) qaytaradi
''',
      hints: ["`print(isinstance(yosh, str))`"],
      usesInput: true,
      check: (code, run) async {
        if (!codeHas(code, r'isinstance\(')) return fail("`isinstance()` dan foydalaning.");
        if (!code.contains('#')) return fail("Sababini izohda yozing.");
        final r = await run('15');
        final e = mustRun(r);
        if (e != null) return e;
        if (!r.stdout.contains('True')) return fail("Natijada True chiqishi kerak.");
        return const TaskVerdict(true, "To'g'ri! input() har doim str qaytaradi — hatto 15 kiritilsa ham. Son kerak bo'lsa: int(input()).");
      },
    ),
    CodeTask(
      id: 't6',
      title: "🐞 Xatolarni tuzating",
      description: r"""Kodni tuzating: natija aynan `True 3.14 True` bo'lsin.""",
      starter: r'''yoqdi = true
pi = 3,14
natija = 0.1 + 0.2
print(yoqdi, pi, natija == 0.3)
''',
      solution: r'''yoqdi = True
pi = 3.14
natija = 0.1 + 0.2
print(yoqdi, pi, round(natija, 2) == 0.3)
''',
      hints: ["`True` bosh harf bilan", "Kasr — nuqta bilan: `3.14`", "float'ni `round(natija, 2) == 0.3` bilan solishtiring"],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (r.stdout.trim() != 'True 3.14 True') return fail("Natija `True 3.14 True` bo'lishi kerak. Hozir: ${r.stdout.trim()}");
        return TaskVerdict.pass;
      },
    ),
  ],
  pairs: const [
    MemoryPair('42', 'int', "Butun son — chegarasi yo'q."),
    MemoryPair('3.14', 'float', "Kasr son — nuqta bilan."),
    MemoryPair('"42"', 'str', "Tirnoq ichida — bu matn!"),
    MemoryPair('True', 'bool', "Mantiqiy — bosh harf bilan."),
    MemoryPair('None', 'NoneType', "\"Qiymat yo'q\"."),
    MemoryPair('3 + 4j', 'complex', "Kompleks son."),
    MemoryPair('0.1 + 0.2', '0.30000000000000004', "Ikkilik tizimdagi yaxlitlash."),
    MemoryPair('bool("")', 'False', "Bo'sh matn — falsy."),
    MemoryPair('bool(" ")', 'True', "Probel ham belgi!"),
    MemoryPair('True + True', '2', "True = 1."),
    MemoryPair('15_000_000', '15000000', "`_` — faqat ko'z uchun."),
    MemoryPair('1.5e6', '1500000.0', "Ilmiy yozuv float beradi."),
  ],
  quiz: const [
    QuizQ("`type(5.0)` nima qaytaradi?", ["<class 'int'>", "<class 'float'>", "<class 'str'>", "<class 'number'>"], 1,
        "Nuqta bo'lsa — hatto .0 bo'lsa ham — float."),
    QuizQ("Natija nima?", ['0.3', '0.30000000000000004', '0.30', 'Xato'], 1, "Ikkilik sanoq sistemasi sababli.",
        code: 'print(0.1 + 0.2)'),
    QuizQ("Qaysi qiymat **falsy** EMAS?", ['`0`', '`""`', '`"0"`', '`None`'], 2, "`\"0\"` — bitta belgili matn, bo'sh emas → True."),
    QuizQ("Natija nima?", ['2', 'TrueTrue', 'True', 'Xato'], 0, "True = 1, 1 + 1 = 2.", code: 'print(True + True)'),
    QuizQ("`print(2 ** 100)` nima bo'ladi?", ['OverflowError', 'inf', 'Juda katta aniq butun son', 'float son'], 2,
        "Python'da int chegarasiz — aniq son chiqadi: 1267650600228229401496703205376."),
    QuizQ("Funksiya `return` qilmasa nima qaytaradi?", ['0', '""', 'None', 'False'], 2, "Avtomatik `None` qaytaradi."),
    QuizQ("Natija nima?", ["<class 'float'>", "<class 'tuple'>", "<class 'int'>", 'SyntaxError'], 1,
        "Vergul — ajratuvchi. 3,14 → (3, 14) tuple.", code: 'x = 3,14\nprint(type(x))'),
    QuizQ("`isinstance(3.14, (int, float))` nima qaytaradi?", ['True', 'False', 'Xato', '(False, True)'], 0,
        "Tuple ichidagi turlardan birortasi mos kelsa — True."),
    QuizQ("Pul hisoblash uchun nima tavsiya etiladi?", ['float', '`decimal` moduli yoki tiyinlarda int', 'str', 'complex'], 1,
        "float yaxlitlash xatolari beradi — pulga `decimal` yoki butun tiyinlar."),
    QuizQ("`None == \"None\"` nima qaytaradi?", ['True', 'False', 'Xato', 'None'], 1, "None — maxsus qiymat, \"None\" — oddiy matn."),
    QuizQ("Natija nima?", ['1500000', '1500000.0', '1.5e6', '15000000.0'], 1, "Ilmiy yozuv har doim float beradi.",
        code: 'print(1.5e6)'),
    QuizQ("`yoqdi = true` nima beradi?", ['True', 'SyntaxError', "NameError: name 'true' is not defined", 'False'], 2,
        "Kichik harfli `true` — Python uchun noma'lum nom."),
    QuizQ("Natija nima?", ['True', 'False', '0.3', 'Xato'], 0, "Yaxlitlangandan keyin 0.3 == 0.3.",
        code: 'print(round(0.1 + 0.2, 2) == 0.3)'),
  ],
  cards: const [
    FlashCard('L2c1', "int nima?", "Butun son. Python'da chegarasi yo'q (2**100 ham sig'adi)."),
    FlashCard('L2c2', "`15_000_000` nima?", "15000000 — `_` faqat o'qish qulayligi uchun."),
    FlashCard('L2c3', "`0.1 + 0.2` nimaga teng?", "0.30000000000000004 — ikkilik tizim tufayli."),
    FlashCard('L2c4', "float'larni qanday solishtirish kerak?", "", backCode: 'round(a, 2) == round(b, 2)\nabs(a - b) < 0.000001'),
    FlashCard('L2c5', "Falsy qiymatlar ro'yxati?", "0, 0.0, \"\", [], {}, None (va False)"),
    FlashCard('L2c6', "`bool(\" \")` nima?", "True — probel ham belgi!"),
    FlashCard('L2c7', "`True + True` nimaga teng?", "2 (True = 1, False = 0)"),
    FlashCard('L2c8', "None nima?", "\"Qiymat yo'q\". Turi — NoneType."),
    FlashCard('L2c9', "None qanday tekshiriladi?", "", backCode: 'if x is None:\n    ...'),
    FlashCard('L2c10', "type() va isinstance() farqi?", "type() — aniq turni beradi; isinstance() — \"shu turdanmi?\" (True/False)."),
    FlashCard('L2c11', "`1.5e6` nima?", "1500000.0 — ilmiy yozuv, turi float."),
    FlashCard('L2c12', "Immutable (o'zgarmas) nima degani?", "Obyektni ichidan o'zgartirib bo'lmaydi; o'zgaruvchi faqat boshqa obyektga ko'chadi."),
    FlashCard('L2c13', "`3,14` nima?", "Kasr emas! Ikkita sondan iborat tuple: (3, 14)."),
  ],
  summary: const [
    "Har bir qiymat o'z **turiga** ega, tur qanday amallar mumkinligini belgilaydi",
    "`int` — butun son, Python'da chegarasi yo'q, `_` bilan chiroyli yoziladi",
    "`float` — kasr son, aniq taqqoslash uchun `round()` ishlating",
    "`bool` — faqat `True`/`False`, bo'sh qiymatlar `False` hisoblanadi (falsy)",
    "`None` — \"qiymat yo'q\" degani, `is None` bilan tekshiriladi",
    "`type()` aniq turni, `isinstance()` esa moslikni tekshiradi",
    "Bu turlarning hammasi **o'zgarmas** (immutable)",
  ],
);
