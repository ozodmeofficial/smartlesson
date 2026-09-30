import 'package:flutter/material.dart';

import 'check_helpers.dart';
import 'models.dart';

final lesson1 = Lesson(
  id: 'L1',
  number: 1,
  title: "O'zgaruvchilar",
  subtitle: "Ma'lumotni xotirada saqlash san'ati",
  emoji: '📦',
  color: const Color(0xFF8B5CF6),
  color2: const Color(0xFFEC4899),
  intro: r"""Bu darsda ma'lumotni xotirada saqlashni — **o'zgaruvchilarni** o'rganasiz. Ularni qanday nomlash, qanday almashtirish va Python xotirada **aslida** nima qilishini bilib olasiz.""",
  goals: const [
    "O'zgaruvchi nima va u xotirada qanday ishlaydi",
    "`=` operatori aslida nima qiladi",
    "Nomlash qoidalari va PEP 8 `snake_case` uslubi",
    "Taqiqlangan nomlar va Python kalit so'zlari",
    "Bir vaqtda bir nechta qiymat berish va `a, b = b, a` hiylasi",
    "`type()`, `id()` funksiyalari va xotira",
    "Konstantalar, `+=` operatorlari va `del` bilan o'chirish",
  ],
  labs: const [LabKind.memoryLab, LabKind.nameGame],
  sections: const [
    Section('s1', '📦', "O'zgaruvchi nima?", [
      AnalogyBlock('📦', 'Quti analogiyasi', r"""Tasavvur qiling, sizda bir nechta quti bor. Har biriga **yorliq** yopishtirasiz va ichiga biror narsa solasiz:

• "Ism" yorliqli qutiga — `"Ali"` deb yozilgan qog'oz
• "Yosh" yorliqli qutiga — `25` raqami

Keyin sizga "Ism" kerak bo'lsa, qutini ochib qaraysiz. Mana shu — **o'zgaruvchi (variable)**."""),
      TextBlock(r"""O'zgaruvchi — bu kompyuter xotirasidagi **nomlangan joy**. Siz unga qiymat saqlaysiz va keyin **nomi orqali** qaytarib olasiz."""),
      CodeBlock(r'''ism = "Ali"       # "Ism" qutisiga "Ali" ni soldik
yosh = 25         # "Yosh" qutisiga 25 ni soldik

print(ism)
# Natija: Ali

print(yosh)
# Natija: 25'''),
      TextBlock(r"""Nomi "o'zgaruvchi" — chunki qiymatini istalgan paytda **o'zgartirish** mumkin:"""),
      CodeBlock(r'''yosh = 25
print(yosh)
# Natija: 25

yosh = 26         # Eski qiymat o'chdi, yangisi keldi
print(yosh)
# Natija: 26'''),
      NoteBlock(r"""Aniqroq analogiya — quti emas, **yorliq (label)**. Python'da o'zgaruvchi qiymatni ichida saqlamaydi, balki qiymatga **"ishora qiladi"**. Buni `id()` bo'limida va **Xotira laboratoriyasi**da o'z ko'zingiz bilan ko'rasiz."""),
      MnemonicBlock(r"""**O'zgaruvchi = yorliq 🏷️.** Qiymat — xotiradagi narsa, nom — unga yopishtirilgan yorliq. Yorliqni boshqa narsaga ko'chirish mumkin!"""),
    ], check: QuickCheck(
      "Quyidagi koddan keyin `yosh` nimaga teng?",
      ['25', '26', '51', 'Xato beradi'],
      1,
      "O'zgaruvchi oxirgi berilgan qiymatni saqlaydi. `yosh = 26` qatori eski 25 ni almashtirdi.",
      code: 'yosh = 25\nyosh = 26',
    )),
    Section('s2', '⬅️', "= operatori", [
      TextBlock(r"""`=` belgisi matematikadagi **"teng"** degani EMAS. Python'da u **"o'ngdagini chapdagiga saqla"** degani. Buni o'q kabi tasavvur qiling: `←`."""),
      CodeBlock(r'''x = 10       # 10 ni x ga saqladik
x = x + 5    # x ning eski qiymatiga 5 qo'shib, natijani yana x ga saqladik
print(x)
# Natija: 15'''),
      TextBlock(r"""Matematikada `x = x + 5` mumkin emas. Python'da esa bu mutlaqo normal, chunki `=` — bu **saqlash amali**. Python avval **o'ng tomonni hisoblaydi**, keyin natijani chapdagi nomga beradi."""),
      CodeBlock(r'''# Chap tomon — doim o'zgaruvchi nomi
narx = 1000          # TO'G'RI
print(narx)
# Natija: 1000

# 1000 = narx       — XATO: SyntaxError'''),
      MnemonicBlock(r"""**`=` bu o'q `←`.** "x = x + 5" ni shunday o'qing: *"x ga — x plyus 5 ni sol"*. O'ngdan chapga oqadi, xuddi daryo kabi 🌊."""),
    ], check: QuickCheck(
      "`x = x + 5` qatori nima qiladi?",
      [
        "x ning 5 ga tengligini tekshiradi",
        "x ning eski qiymatiga 5 qo'shib, natijani yana x ga saqlaydi",
        "Xato beradi, chunki x ≠ x + 5",
        "5 ni x ga saqlaydi",
      ],
      1,
      "`=` — tenglik emas, saqlash! Avval o'ng tomon hisoblanadi (x + 5), keyin natija x ga yoziladi.",
    )),
    Section('s3', '📏', "Nomlash qoidalari", [
      TextBlock(r"""Python'da o'zgaruvchi nomlari uchun **qat'iy qoidalar** bor:"""),
      TableBlock(['Qoida', "To'g'ri", "Noto'g'ri"], [
        ["Harf yoki `_` bilan boshlanadi", '`ism`, `_temp`', '`1ism`'],
        ["Bo'shliq bo'lmaydi", '`talaba_ismi`', '`talaba ismi`'],
        ['Faqat harf, raqam, `_`', '`narx_2`', '`narx-2`, `narx!`'],
        ["Kalit so'z bo'lmaydi", '`sinf`', '`class`'],
        ['Katta-kichik harf farqlanadi', '`ism` ≠ `Ism`', '—'],
      ]),
      CodeBlock(r'''# TO'G'RI nomlar:
ism = "Ali"
talaba_yoshi = 20
_maxfiy = "sir"
narx2 = 5000
print(ism, talaba_yoshi, _maxfiy, narx2)
# Natija: Ali 20 sir 5000

# XATO nomlar (bular ishlamaydi):
# 2narx = 100        → SyntaxError: raqam bilan boshlangan
# talaba ismi = "A"  → SyntaxError: bo'shliq bor
# narx-yangi = 10    → SyntaxError: chiziqcha mumkin emas'''),
      TextBlock(r"""### PEP 8: snake_case uslubi
Qoidalardan tashqari **uslub** ham bor. Python hamjamiyati `snake_case` ishlatadi: hamma harf kichik, so'zlar orasida pastki chiziq."""),
      CodeBlock(r'''# TO'G'RI (PEP 8 — snake_case):
foydalanuvchi_ismi = "Ali"
umumiy_narx = 15000
maksimal_urinishlar = 3

# ISHLAYDI, lekin PEP 8 ga zid:
# foydalanuvchiIsmi = "Ali"    — camelCase (JavaScript uslubi)
# FoydalanuvchiIsmi = "Ali"    — PascalCase (klass nomlari uchun)
# f = "Ali"                     — tushunarsiz nom''', runnable: false),
      NoteBlock(r"""Nomni **ma'noli** qiling. `a`, `x1`, `data2` o'rniga `talaba_yoshi`, `umumiy_narx` yozing. Kod o'zini o'zi tushuntirsin.""", kind: NoteKind.tip),
      MnemonicBlock(r"""**snake_case 🐍 — ilon yerda sudraladi:** hamma harflar pastda (kichik), so'zlar orasida `_` — ilonning yo'li. Raqam esa hech qachon boshda turmaydi: *"ilonning boshi — harf"*."""),
    ], check: QuickCheck(
      "Qaysi nom Python'da XATO beradi?",
      ['`_narx`', '`narx_2`', '`2narx`', '`Narx`'],
      2,
      "O'zgaruvchi nomi raqam bilan boshlana olmaydi. `2narx` → SyntaxError: invalid decimal literal.",
    )),
    Section('s4', '🚫', "Kalit so'zlar (keywords)", [
      TextBlock(r"""Python'da ba'zi so'zlar **band** — ular tilning o'z buyruqlari. Ularni o'zgaruvchi nomi qilib bo'lmaydi."""),
      CodeBlock(r'''import keyword  # Kalit so'zlar ro'yxatini beradigan modul

print(keyword.kwlist)
# Natija:
# ['False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await',
#  'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except',
#  'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is',
#  'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return',
#  'try', 'while', 'with', 'yield']

print(len(keyword.kwlist))
# Natija: 35'''),
      CodeBlock(r'''# XATO — kalit so'zni nom qilib bo'lmaydi:
# class = "11-A"      → SyntaxError
# for = 5             → SyntaxError

# TO'G'RI — ozgina o'zgartiring:
sinf = "11-A"
sinf_nomi = "11-A"
print(sinf)
# Natija: 11-A'''),
      TextBlock(r"""Yana bir nozik moment: `print`, `list`, `sum`, `str`, `input` — bular kalit so'z emas, lekin **tayyor funksiyalar**. Ularni o'zgaruvchi nomi qilsangiz, funksiyani **yo'qotasiz**:"""),
      CodeBlock(r'''# YOMON:
# list = [1, 2, 3]
# Endi list() funksiyasi ishlamaydi!

# YAXSHI:
sonlar_royxati = [1, 2, 3]
print(sonlar_royxati)
# Natija: [1, 2, 3]'''),
      MnemonicBlock(r"""**35 ta band o'rindiq 💺.** Kinoteatrdagi VIP o'rindiqlarga (`if`, `for`, `class`, `True`...) o'tira olmaysiz. `print`, `list`, `str` esa — o'tirsangiz bo'ladi, lekin egasi (funksiya) joyidan quvilib ketadi! 😅"""),
    ], check: QuickCheck(
      "`list = [1, 2, 3]` deb yozsangiz nima bo'ladi?",
      [
        'SyntaxError chiqadi',
        "Ishlaydi, lekin endi `list()` funksiyasidan foydalana olmaysiz",
        "Hech narsa bo'lmaydi, bu mutlaqo normal",
        "Python avtomatik boshqa nom beradi",
      ],
      1,
      "`list` — kalit so'z emas, tayyor funksiya. Uni o'zgaruvchi qilsangiz, ishlaydi, lekin asl funksiya \"yopilib\" qoladi.",
    )),
    Section('s5', '🎯', "Bir nechta qiymat va almashtirish", [
      TextBlock(r"""Python bir qatorda bir nechta o'zgaruvchi yaratishga imkon beradi:"""),
      CodeBlock(r'''# Har biriga alohida qiymat
ism, yosh, shahar = "Ali", 25, "Toshkent"

print(ism)
# Natija: Ali
print(yosh)
# Natija: 25
print(shahar)
# Natija: Toshkent

# Hammasiga bir xil qiymat
x = y = z = 0
print(x, y, z)
# Natija: 0 0 0'''),
      TextBlock(r"""### `a, b = b, a` — qiymatlarni almashtirish
Boshqa tillarda ikkita o'zgaruvchi qiymatini almashtirish uchun **uchinchi vaqtinchalik** o'zgaruvchi kerak. Python'da esa bu **bir qatorda** bo'ladi:"""),
      CodeBlock(r'''a = 10
b = 20

print("Almashtirishdan oldin:", a, b)
# Natija: Almashtirishdan oldin: 10 20

a, b = b, a       # Sehr shu yerda!

print("Almashtirishdan keyin:", a, b)
# Natija: Almashtirishdan keyin: 20 10'''),
      TextBlock(r"""Eski usul (boshqa tillarda shunday qilinadi):"""),
      CodeBlock(r'''a = 10
b = 20

vaqtinchalik = a     # a ni saqlab qo'yamiz
a = b                # a ga b ni beramiz
b = vaqtinchalik     # b ga eski a ni beramiz

print(a, b)
# Natija: 20 10'''),
      AnalogyBlock('🥤', 'Ikki stakan', r"""Bir stakanda choy, ikkinchisida sharbat. Ularni almashtirish uchun **uchinchi bo'sh stakan** kerak — bu eski usul. Python esa sehrgar 🪄: ikkala stakanni bir vaqtda ko'tarib, joyini almashtiradi. Chunki u avval o'ng tomonni `(b, a)` to'liq hisoblab oladi, keyin chapga tarqatadi."""),
      MnemonicBlock(r"""**"a, b = b, a" — xuddi oyna 🪞.** Chapda `a, b`, o'ngda aks: `b, a`."""),
    ], check: QuickCheck(
      "Natija nima bo'ladi?",
      ['5 9', '9 5', '9 9', '5 5'],
      1,
      "`a, b = b, a` qiymatlarni almashtiradi: endi a = 9, b = 5.",
      code: 'a = 5\nb = 9\na, b = b, a\nprint(a, b)',
    )),
    Section('s6', '🔍', "type() va id() — xotiraga nazar", [
      TextBlock(r"""### type() — qiymat turi qanday?"""),
      CodeBlock(r'''ism = "Ali"
yosh = 25
boy = 1.75
ishlaydi = True

print(type(ism))
# Natija: <class 'str'>      — matn

print(type(yosh))
# Natija: <class 'int'>      — butun son

print(type(boy))
# Natija: <class 'float'>    — kasr son

print(type(ishlaydi))
# Natija: <class 'bool'>     — mantiqiy (rost/yolg'on)'''),
      TextBlock(r"""Python'da o'zgaruvchi turi **avtomatik aniqlanadi**. Siz uni oldindan e'lon qilmaysiz — bu Java yoki C++ dan katta farq. Bundan tashqari, bitta o'zgaruvchi **turini o'zgartirishi** mumkin:"""),
      CodeBlock(r'''qiymat = 100
print(type(qiymat))
# Natija: <class 'int'>

qiymat = "yuz"
print(type(qiymat))
# Natija: <class 'str'>    — tur o'zgardi!'''),
      TextBlock(r"""### id() — xotiradagi manzil
`id()` o'zgaruvchi ishora qilayotgan qiymatning **xotiradagi manzilini** beradi:"""),
      CodeBlock(r'''a = 100
b = 100

print(id(a))
# Natija: 4374829264  (sizda boshqa raqam bo'ladi)

print(id(b))
# Natija: 4374829264  (a bilan BIR XIL!)

print(a is b)
# Natija: True   — ikkalasi bir xil obyektga ishora qilyapti'''),
      TextBlock(r"""Bu Python'ning **tejamkorligini** ko'rsatadi: bir xil kichik sonlar (−5 dan 256 gacha) uchun u xotirada **bitta nusxa** saqlaydi va ikkala yorliqni o'shanga bog'laydi."""),
      CodeBlock(r'''x = 10
print(id(x))
# Natija: 4374826384

x = 20        # Yangi qiymat bergandik
print(id(x))
# Natija: 4374826704   — manzil o'zgardi!'''),
      NoteBlock(r"""Demak, qiymat o'zgarmaydi — **yorliq boshqa qiymatga ko'chadi**. Mana shuning uchun "quti" emas, "yorliq" analogiyasi aniqroq. 🔬 **Laboratoriya** bo'limida buni animatsiyada ko'ring!"""),
      MnemonicBlock(r"""**type() — "Kimsan?" 🪪, id() — "Qayerda yashaysan?" 🏠.** Birinchisi pasportni, ikkinchisi uy manzilini ko'rsatadi."""),
    ], check: QuickCheck(
      "`x = 10` dan keyin `x = 20` desak, xotirada nima bo'ladi?",
      [
        "10 soni 20 ga aylanadi",
        "x yorlig'i 20 soniga ko'chadi, id(x) o'zgaradi",
        "x o'chib, qaytadan yaratiladi, id bir xil qoladi",
        "Xato beradi",
      ],
      1,
      "Sonlar o'zgarmas. `x` shunchaki boshqa obyektga — 20 ga ishora qila boshlaydi, shuning uchun `id(x)` ham o'zgaradi.",
    )),
    Section('s7', '🔒', "Konstantalar va +=, -=, *=", [
      TextBlock(r"""**Konstanta** — bu o'zgarmasligi kerak bo'lgan qiymat. Masalan, PI soni yoki soliq foizi. Python'da haqiqiy konstanta yo'q, lekin **kelishuv** bor: konstanta nomini **KATTA HARF** bilan yozing."""),
      CodeBlock(r'''# Konstantalar — KATTA_HARF bilan
PI = 3.14159
SOLIQ_FOIZI = 12
MAKSIMAL_URINISH = 3
SAYT_NOMI = "MyShop"

# Ishlatish:
radius = 5
yuza = PI * radius ** 2       # ** — daraja belgisi
print("Doira yuzasi:", yuza)
# Natija: Doira yuzasi: 78.53975

narx = 100000
soliq = narx * SOLIQ_FOIZI / 100
print("Soliq:", soliq, "so'm")
# Natija: Soliq: 12000.0 so'm'''),
      TextBlock(r"""### Qisqartirilgan operatorlar
O'zgaruvchi qiymatini o'zgartirishni **qisqaroq** yozish mumkin:"""),
      CodeBlock(r'''ball = 10

ball = ball + 5    # Uzun usul
print(ball)
# Natija: 15

ball += 5          # Qisqa usul — xuddi shu ish
print(ball)
# Natija: 20

ball -= 3          # ball = ball - 3
print(ball)
# Natija: 17

ball *= 2          # ball = ball * 2
print(ball)
# Natija: 34

ball /= 4          # ball = ball / 4
print(ball)
# Natija: 8.5'''),
      TableBlock(['Operator', "To'liq yozilishi", 'Misol'], [
        ['`+=`', '`x = x + y`', '`ball += 5`'],
        ['`-=`', '`x = x - y`', '`ball -= 3`'],
        ['`*=`', '`x = x * y`', '`ball *= 2`'],
        ['`/=`', '`x = x / y`', '`ball /= 4`'],
        ['`//=`', '`x = x // y`', "butun bo'lish"],
        ['`%=`', '`x = x % y`', 'qoldiq'],
        ['`**=`', '`x = x ** y`', 'daraja'],
      ]),
      CodeBlock(r'''xabar = "Salom"
xabar += ", dunyo!"      # matnlar bilan ham ishlaydi
print(xabar)
# Natija: Salom, dunyo!'''),
      MnemonicBlock(r"""**KATTA HARF = baqirib aytilgan 📢: "TEGMA!"** `+=` esa — *"o'ziga qo'sh"*: `ball += 5` → *"ballga 5 qo'sh"*. Belgi har doim `=` dan **oldin** turadi."""),
    ], check: QuickCheck(
      "Natija nima bo'ladi?",
      ['8', '10', '16', '6'],
      2,
      "ball = 3 → ball += 5 → 8 → ball *= 2 → 16.",
      code: 'ball = 3\nball += 5\nball *= 2\nprint(ball)',
    )),
    Section('s8', '🗑️', "del va ko'p uchraydigan xatolar", [
      TextBlock(r"""Agar o'zgaruvchi endi kerak bo'lmasa, uni `del` bilan o'chirish mumkin:"""),
      CodeBlock(r'''vaqtinchalik = "bu keraksiz ma'lumot"
print(vaqtinchalik)
# Natija: bu keraksiz ma'lumot

del vaqtinchalik       # O'zgaruvchini o'chirdik

print(vaqtinchalik)
# Natija: NameError: name 'vaqtinchalik' is not defined'''),
      TextBlock(r"""Amalda `del` kam ishlatiladi — Python xotirani o'zi tozalaydi (bu **garbage collector** — "axlat yig'uvchi" deb ataladi). Hech bir yorliq ishora qilmayotgan qiymatni u o'zi olib ketadi 🧹."""),
      TextBlock(r"""### ⚠️ Ko'p uchraydigan xatolar
**1. E'lon qilinmagan o'zgaruvchidan foydalanish** — avval qiymat bering.
**2. Katta-kichik harfni chalkashtirish:**"""),
      CodeBlock(r'''Ism = "Ali"
print(ism)
# Natija: NameError: name 'ism' is not defined
# Python uchun Ism va ism — BUTUNLAY BOSHQA o'zgaruvchilar!'''),
      TextBlock(r"""**3. `=` va `==` ni aralashtirish:**"""),
      CodeBlock(r'''x = 5          # BERISH: x ga 5 ni sakla
print(x == 5)  # SOLISHTIRISH: x 5 ga tengmi?
# Natija: True'''),
      TextBlock(r"""**4. Tayyor funksiya nomini o'zgaruvchi qilish:**"""),
      CodeBlock(r'''str = "salom"
print(str(25))
# Natija: TypeError: 'str' object is not callable'''),
      TextBlock(r"""**5. O'zgaruvchi qiymati o'zgargandan keyin eski qiymatni kutish:**"""),
      CodeBlock(r'''a = 10
b = a         # b ga a ning HOZIRGI qiymati (10) ko'chdi
a = 99        # a o'zgardi

print(b)
# Natija: 10   — b o'zgarmadi'''),
      NoteBlock(r"""`b = a` — bu "b ham a qarayotgan obyektga qarasin" degani. Keyin `a = 99` desak, faqat **a ning yorlig'i** ko'chadi, b esa hamon 10 da qoladi.""", kind: NoteKind.warning),
      MnemonicBlock(r"""**`=` — "sol" 📥, `==` — "solishtir" ⚖️.** Bitta belgi — bitta harakat, ikkita belgi — ikki narsani taroziga qo'yish."""),
    ], check: QuickCheck(
      "Natija nima bo'ladi?",
      ['10', '99', 'NameError', 'None'],
      0,
      "`b = a` paytida b 10 ga ishora qila boshladi. Keyin a boshqa qiymatga ko'chdi, b esa joyida qoldi.",
      code: 'a = 10\nb = a\na = 99\nprint(b)',
    )),
  ],
  tasks: [
    CodeTask(
      id: 't1',
      title: "Shaxsiy kartochka",
      description: r"""4 ta o'zgaruvchi yarating: `ism`, `familiya`, `yosh`, `shahar`. Ularni `print()` bilan chiroyli ko'rinishda chiqaring.

`yosh` butun son (int) bo'lsin!""",
      starter: r'''# 4 ta o'zgaruvchi yarating
ism = ""
familiya = ""
yosh = 0
shahar = ""

# Chiroyli chiqaring:
print("Ism:", ism)
''',
      solution: r'''ism = "Ali"
familiya = "Valiyev"
yosh = 16
shahar = "Toshkent"

print("Ism:", ism)
print("Familiya:", familiya)
print("Yosh:", yosh)
print("Shahar:", shahar)
''',
      hints: [
        "Har bir o'zgaruvchiga qiymat bering: `ism = \"Ali\"`",
        "`yosh = 16` — tirnoqsiz yozilsa int bo'ladi",
        "Har biri uchun alohida `print(\"Familiya:\", familiya)` yozing",
      ],
      check: (code, run) async {
        for (final n in ['ism', 'familiya', 'yosh', 'shahar']) {
          if (!codeHas(code, '^\\s*$n\\s*=')) return fail("`$n` o'zgaruvchisini yarating.");
        }
        if (!codeHas(code, r'^\s*yosh\s*=\s*\d+\s*$')) return fail("`yosh` butun son bo'lsin, masalan `yosh = 16` (tirnoqsiz).");
        if (codeHas(code, r'''^\s*(ism|familiya|shahar)\s*=\s*(""|'')\s*$''')) return fail("Matnli o'zgaruvchilar bo'sh qolmasin — qiymat yozing.");
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (outLines(r).length < 2) return fail("Kamida 2 qator chiqaring — hammasini chiroyli ko'rsating.");
        for (final n in ['familiya', 'yosh', 'shahar']) {
          if (!codeHas(code, 'print\\(.*\\b$n\\b')) return fail("`$n` ni ham print() orqali chiqaring.");
        }
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't2',
      title: "Tur detektivi",
      description: r"""`type()` yordamida **5 xil** qiymatning turini chiqaring: matn, butun son, kasr son, `True` va `None`.""",
      starter: r'''print(type("salom"))
# Qolgan 4 tasini yozing:
''',
      solution: r'''print(type("salom"))
print(type(42))
print(type(3.14))
print(type(True))
print(type(None))
''',
      hints: ["`print(type(42))` — butun son", "`print(type(None))` natijasi `<class 'NoneType'>`"],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        for (final t in ['str', 'int', 'float', 'bool', 'NoneType']) {
          if (!r.stdout.contains("<class '$t'>")) return fail("Natijada `<class '$t'>` ko'rinmayapti.");
        }
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't3',
      title: "Sehrli almashtirish",
      description: r"""Ikkita o'zgaruvchi yarating va ularning qiymatlarini `a, b = b, a` usuli bilan almashtiring. Almashtirishdan **oldin** va **keyin** chiqaring.""",
      starter: r'''a = 10
b = 20
print("Oldin:", a, b)

# Almashtiring:

print("Keyin:", a, b)
''',
      solution: r'''a = 10
b = 20
print("Oldin:", a, b)

a, b = b, a

print("Keyin:", a, b)
''',
      hints: ["Bitta qator yetarli: `a, b = b, a`"],
      check: (code, run) async {
        if (!codeHas(code, r'(\w+)\s*,\s*(\w+)\s*=\s*\2\s*,\s*\1')) {
          return fail("`a, b = b, a` ko'rinishidagi almashtirishni ishlating.");
        }
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        final l = outLines(r);
        if (l.length < 2) return fail("Oldin va keyin — ikkita qator chiqaring.");
        if (l.first == l.last) return fail("Oldingi va keyingi natija bir xil — almashtirish print'lar orasida bo'lsin.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't4',
      title: "QQS kalkulyatori",
      description: r"""Konstanta sifatida `QQS_FOIZI = 12` ni e'lon qiling. Foydalanuvchidan mahsulot narxini `input()` bilan so'rab, QQS bilan **yakuniy summani** hisoblang va chiqaring.

💡 Tekshiruvda narx sifatida `100000` kiritiladi → yakuniy summa `112000` bo'lishi kerak.""",
      starter: r'''QQS_FOIZI = 12

narx = float(input("Narxni kiriting: "))
# Yakuniy summani hisoblang:
''',
      solution: r'''QQS_FOIZI = 12

narx = float(input("Narxni kiriting: "))
yakuniy = narx + narx * QQS_FOIZI / 100
print("Yakuniy summa:", yakuniy)
''',
      hints: [
        "input() matn qaytaradi — uni `float()` bilan songa aylantiring",
        "QQS miqdori: `narx * QQS_FOIZI / 100`",
        "Yakuniy: `narx + qqs`",
      ],
      usesInput: true,
      check: (code, run) async {
        if (!codeHas(code, r'^\s*QQS_FOIZI\s*=\s*12\b')) return fail("`QQS_FOIZI = 12` konstantasini e'lon qiling.");
        if (!codeHas(code, r'input\(')) return fail("Narxni `input()` orqali so'rang.");
        final r = await run('100000');
        final e = mustRun(r);
        if (e != null) return e;
        if (!RegExp(r'112000(\.0+)?\b|112 000').hasMatch(r.stdout)) {
          return fail("100000 kiritilganda natijada 112000 chiqishi kerak edi. Chiqdi: ${r.stdout.trim()}");
        }
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't5',
      title: "Ball hisoblagich",
      description: r"""`ball = 0` dan boshlang. `+=` bilan **3 marta** ball qo'shing, bir marta `-=` bilan ayiring. Har bosqichda `ball` va `id(ball)` qiymatini chiqaring — manzil qanday o'zgarishini kuzating!""",
      starter: r'''ball = 0
print(ball, id(ball))

ball += 10
print(ball, id(ball))
''',
      solution: r'''ball = 0
print(ball, id(ball))

ball += 10
print(ball, id(ball))

ball += 20
print(ball, id(ball))

ball += 5
print(ball, id(ball))

ball -= 15
print(ball, id(ball))
''',
      hints: ["Yana ikkita `ball += ...` va bitta `ball -= ...` qo'shing", "Har biridan keyin `print(ball, id(ball))`"],
      check: (code, run) async {
        if (countOf(code, '+=') < 3) return fail("`+=` kamida 3 marta ishlatilsin.");
        if (countOf(code, '-=') < 1) return fail("Bir marta `-=` bilan ayiring.");
        if (countOf(code, 'id(') < 4) return fail("Har bosqichda `id(ball)` ni chiqaring.");
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (outLines(r).length < 5) return fail("Kamida 5 qator natija bo'lishi kerak (boshlang'ich + 4 bosqich).");
        return const TaskVerdict(true,
            "Zo'r! Ko'rdingizmi: har safar qiymat o'zgarganda id() ham o'zgardi — yorliq yangi obyektga ko'chdi! 🏷️");
      },
    ),
    CodeTask(
      id: 't6',
      title: "🐞 Xatolarni tuzating",
      description: r"""Bu kodda **3 ta** nomlash xatosi bor. Nomlarni PEP 8 bo'yicha to'g'rilang, shunda dastur ishlab `5000 Vali 11-A` ni chiqarsin.""",
      starter: r'''2narx = 5000
talaba ismi = "Vali"
class = "11-A"
print(2narx, talaba ismi, class)
''',
      solution: r'''narx = 5000
talaba_ismi = "Vali"
sinf = "11-A"
print(narx, talaba_ismi, sinf)
''',
      hints: [
        "Nom raqam bilan boshlanmaydi: `narx` yoki `narx2`",
        "Bo'shliq o'rniga `_`: `talaba_ismi`",
        "`class` — kalit so'z. `sinf` deb nomlang",
      ],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (r.stdout.trim() != '5000 Vali 11-A') return fail("Natija aynan `5000 Vali 11-A` bo'lishi kerak.");
        return TaskVerdict.pass;
      },
    ),
  ],
  pairs: const [
    MemoryPair('x = 5', "x ga 5 ni saqla", "`=` — tenglik emas, saqlash (o'q ←)."),
    MemoryPair('x == 5', "x 5 ga tengmi?", "`==` solishtiradi va True/False qaytaradi."),
    MemoryPair('a, b = b, a', "Qiymatlarni almashtirish", "Python o'ng tomonni to'liq hisoblab, keyin tarqatadi."),
    MemoryPair('snake_case', 'umumiy_narx', "PEP 8: kichik harflar va `_`."),
    MemoryPair('PI = 3.14', 'Konstanta', "KATTA HARF — \"o'zgartirmang\" degan kelishuv."),
    MemoryPair('ball += 5', 'ball = ball + 5', "Qisqartirilgan operator."),
    MemoryPair('type(x)', 'Qiymat turi', "`<class 'int'>` kabi javob beradi."),
    MemoryPair('id(x)', 'Xotiradagi manzil', "Qiymat o'zgarsa, yorliq boshqa manzilga ko'chadi."),
    MemoryPair('del x', "O'zgaruvchini o'chirish", "Keyin x ga murojaat → NameError."),
    MemoryPair('2narx = 1', 'SyntaxError', "Nom raqam bilan boshlanmaydi."),
    MemoryPair('keyword.kwlist', "35 ta kalit so'z", "`if`, `for`, `class` ... nom bo'la olmaydi."),
    MemoryPair('x = y = 0', 'Hammasiga bir xil qiymat', "Bir qatorda bir nechta o'zgaruvchi."),
  ],
  quiz: const [
    QuizQ("Python'da `=` belgisi nimani bildiradi?", [
      "Ikki qiymat tengligini tekshiradi",
      "O'ngdagi qiymatni chapdagi nomga saqlaydi",
      "Ikki o'zgaruvchini birlashtiradi",
      "Faqat sonlar uchun ishlatiladi",
    ], 1, "`=` — berish (saqlash) operatori. Solishtirish uchun `==` ishlatiladi."),
    QuizQ("Qaysi nom PEP 8 bo'yicha eng to'g'ri?", ['`TalabaIsmi`', '`talabaIsmi`', '`talaba_ismi`', '`TALABA-ISMI`'], 2,
        "PEP 8 o'zgaruvchilar uchun `snake_case` ni tavsiya qiladi: kichik harflar va `_`."),
    QuizQ("Qaysi qator SyntaxError beradi?", ['`_x = 1`', '`x_1 = 1`', '`narx-2 = 1`', '`Narx = 1`'], 2,
        "`-` belgisi nomda bo'lmaydi — Python uni ayirish deb tushunadi."),
    QuizQ("Natija nima?", ['10 20', '20 10', '20 20', '10 10'], 1, "`a, b = b, a` qiymatlarni almashtiradi.",
        code: 'a = 10\nb = 20\na, b = b, a\nprint(a, b)'),
    QuizQ("Natija nima?", ["<class 'int'>", "<class 'str'>", "<class 'float'>", 'yuz'], 1,
        "O'zgaruvchi turini o'zgartirishi mumkin — oxirgi qiymat matn.", code: 'q = 100\nq = "yuz"\nprint(type(q))'),
    QuizQ("Python'da nechta kalit so'z bor (`keyword.kwlist`)?", ['25', '30', '35', '40'], 2,
        "`len(keyword.kwlist)` → 35."),
    QuizQ("Natija nima?", ['10', '99', '109', 'Xato'], 0,
        "`b = a` paytida b 10 ni oldi. a keyinroq boshqa qiymatga ko'chdi.", code: 'a = 10\nb = a\na = 99\nprint(b)'),
    QuizQ("Natija nima?", ['17', '8.5', '34', '8'], 1, "10 → 15 → 20 → 17 → 34 → 8.5. `/=` doim float beradi.",
        code: 'ball = 10\nball += 5\nball += 5\nball -= 3\nball *= 2\nball /= 4\nprint(ball)'),
    QuizQ("Qaysi nom kalit so'z EMAS (demak, xato bermaydi)?", ['`class`', '`for`', '`print`', '`True`'], 2,
        "`print` — tayyor funksiya, kalit so'z emas. Lekin uni nom qilish yomon odat!"),
    QuizQ("`a = 100; b = 100` dan keyin `a is b` nima qaytaradi?", ['True', 'False', 'Xato', 'None'], 0,
        "Kichik sonlar (−5…256) Python'da bitta nusxada saqlanadi — ikkala yorliq bitta obyektga qaraydi."),
    QuizQ("`del x` dan keyin `print(x)` nima beradi?", ['None', '0', 'NameError', "Bo'sh qator"], 2,
        "`del` nomni o'chiradi — endi bunday o'zgaruvchi yo'q."),
    QuizQ("Konstanta qanday nomlanadi?", ['`soliq_foizi`', '`SoliqFoizi`', '`SOLIQ_FOIZI`', '`_soliq`'], 2,
        "Konstantalar KATTA_HARF bilan — \"o'zgartirmang\" degan signal."),
    QuizQ("Natija nima?", ['0 0 0', 'x y z', 'Xato', '0'], 0, "`x = y = z = 0` — hammasiga bir xil qiymat.",
        code: 'x = y = z = 0\nprint(x, y, z)'),
  ],
  cards: const [
    FlashCard('L1c1', "O'zgaruvchi nima?", "Xotiradagi qiymatga qo'yilgan nom — yorliq 🏷️."),
    FlashCard('L1c2', "`=` operatori nima qiladi?", "O'ngdagini hisoblab, chapdagi nomga saqlaydi (←)."),
    FlashCard('L1c3', "Nom nima bilan boshlanishi mumkin?", "Harf yoki `_` bilan. Raqam bilan — YO'Q."),
    FlashCard('L1c4', "PEP 8 dagi o'zgaruvchi uslubi?", "`snake_case`: kichik harflar + `_`", backCode: 'umumiy_narx = 15000'),
    FlashCard('L1c5', "Ikki o'zgaruvchi qiymatini bir qatorda qanday almashtirasiz?", "", backCode: 'a, b = b, a'),
    FlashCard('L1c6', "Python'da nechta kalit so'z bor?", "35 ta. Ko'rish: `import keyword; keyword.kwlist`"),
    FlashCard('L1c7', "`type()` nima qaytaradi?", "Qiymat turini: `<class 'int'>`, `<class 'str'>` ..."),
    FlashCard('L1c8', "`id()` nima qaytaradi?", "Obyektning xotiradagi manzilini (raqam)."),
    FlashCard('L1c9', "Konstanta qanday yoziladi?", "KATTA_HARF bilan", backCode: 'SOLIQ_FOIZI = 12'),
    FlashCard('L1c10', "`ball += 5` nimaga teng?", "", backCode: 'ball = ball + 5'),
    FlashCard('L1c11', "`del x` nima qiladi?", "x nomini o'chiradi. Keyin `print(x)` → NameError."),
    FlashCard('L1c12', "`ism` va `Ism` — bir xil o'zgaruvchimi?", "Yo'q! Python katta-kichik harfni farqlaydi."),
    FlashCard('L1c13', "Nega `list = [1,2]` yomon?", "`list()` funksiyasini \"yopib\" qo'yadi — endi uni chaqira olmaysiz."),
  ],
  summary: const [
    "**O'zgaruvchi** — xotiradagi qiymatga qo'yilgan yorliq; `=` operatori \"o'ngdagini chapga saqla\" degani",
    "Nom **harf yoki `_`** bilan boshlanadi, bo'shliq va maxsus belgilar bo'lmaydi, kalit so'z bo'lmaydi",
    "PEP 8 uslubi — **`snake_case`**: `foydalanuvchi_ismi`, `umumiy_narx`",
    "Python'da **35 ta kalit so'z** bor; `print`, `list`, `str` kabi funksiya nomlarini ham band qilmang",
    "`a, b = b, a` — qiymatlarni bir qatorda almashtirish",
    "`type()` turni, `id()` xotiradagi manzilni ko'rsatadi; qiymat o'zgarsa, yorliq boshqa manzilga ko'chadi",
    "**Konstantalar** KATTA_HARF bilan; `+=`, `-=`, `*=` — qisqartirilgan operatorlar; `del` o'zgaruvchini o'chiradi",
  ],
);
