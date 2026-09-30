import 'package:flutter/material.dart';

import 'check_helpers.dart';
import 'models.dart';

final lesson3 = Lesson(
  id: 'L3',
  number: 3,
  title: 'Stringlar (matnlar)',
  subtitle: "Indekslash, slicing va metodlar sehri",
  emoji: '📿',
  color: const Color(0xFFF97316),
  color2: const Color(0xFFF43F5E),
  intro: r"""Bu darsda **matn (string)** turi bilan chuqur tanishasiz: uni qanday yaratish, bo'laklarga ajratish va tayyor metodlar yordamida qayta ishlashni o'rganasiz.""",
  goals: const [
    "String yaratishning barcha usullari va tirnoq turlari",
    "Indekslash (indexing) va manfiy indekslar",
    "Kesib olish (slicing) `[start:stop:step]` ni batafsil",
    "`+`, `*` operatorlari va `len()` funksiyasi",
    "11 ta eng kerakli string metodi",
    "Maxsus belgilar (`\\n`, `\\t`, `\\\\`) va string o'zgarmasligi",
  ],
  labs: const [LabKind.sliceLab, LabKind.sliceNinja],
  sections: const [
    Section('s1', '📿', "String nima?", [
      TextBlock(r"""**String** (matn satri) — bu **belgilar ketma-ketligi**. Harflar, raqamlar, probellar, emojilar — hammasi."""),
      AnalogyBlock('📿', 'Munchoq shodasi', r"""String — bu **munchoq shodasi**. Har bir munchoq — bitta belgi. Shoda **tartibli**, har bir munchoqning o'z **raqami** bor."""),
      BeadsBlock('Aziza'),
      CodeBlock(r'''ism = "Aziza"
shahar = 'Toshkent'

print(ism, shahar)
# Natija: Aziza Toshkent

print(type(ism))
# Natija: <class 'str'>'''),
      TextBlock(r"""### Tirnoq turlari
Python'da 3 xil tirnoq bor va har birining o'z vazifasi:"""),
      CodeBlock(r'''a = 'Salom'      # 1. Bir tirnoq
b = "Salom"      # 2. Qo'sh tirnoq
print(a == b)
# Natija: True

# Ichida tirnoq bo'lsa - boshqasini tashqi qiling
c = "Bu men'ning kitobim"
d = 'U "salom" dedi'
print(c)
# Natija: Bu men'ning kitobim
print(d)
# Natija: U "salom" dedi

# 3. Uch tirnoq - ko'p qatorli matn uchun
xat = """Hurmatli mijoz,
Sizning buyurtmangiz qabul qilindi.
Rahmat!"""
print(xat)
# Natija:
# Hurmatli mijoz,
# Sizning buyurtmangiz qabul qilindi.
# Rahmat!'''),
      MnemonicBlock(r"""**O'zbekcha matn — qo'sh tirnoqda!** `"o'zbek"` — ichidagi `'` xavfsiz. Qoida: *ichkarida qaysi tirnoq bo'lsa, tashqariga boshqasini kiyg'iz* 🧥."""),
    ], check: QuickCheck("Qaysi yozuv XATO beradi?", ["`\"men'ning\"`", "`'U \"ha\" dedi'`", "`'men'ning'`", '`"""matn"""`'], 2,
        "Bir tirnoq ichida `'` bo'lsa, matn o'sha joyda \"yopilib\" qoladi → SyntaxError.")),
    Section('s2', '👉', "Indekslash — belgini olish", [
      TextBlock(r"""Har bir belgining o'z raqami (**indeks**) bor. **Sanash 0 dan boshlanadi** — bu boshlovchilar uchun eng g'alati qoida."""),
      BeadsBlock('Python'),
      CodeBlock(r'''soz = "Python"

#  P  y  t  h  o  n
#  0  1  2  3  4  5     <- oldinga
# -6 -5 -4 -3 -2 -1     <- orqaga

print(soz[0])
# Natija: P

print(soz[3])
# Natija: h

print(soz[-1])
# Natija: n

print(soz[-2])
# Natija: o'''),
      TextBlock(r"""**Manfiy indeks** juda qulay: oxirgi belgini olish uchun uzunlikni hisoblash shart emas, `[-1]` yetarli."""),
      CodeBlock(r'''matn = "Backend dasturlash"

print(matn[0], matn[-1])
# Natija: B h

# Mavjud bo'lmagan indeks - xato beradi
print(matn[100])
# Natija: IndexError: string index out of range'''),
      MnemonicBlock(r"""**Chizg'ich 📏 0 dan boshlanadi!** Birinchi santimetr 0 dan 1 gacha. `[-1]` esa — *"oxiridan birinchi"*: xuddi navbatning eng oxiridagi odam 🚶."""),
    ], check: QuickCheck("`\"Python\"[2]` nima?", ['`y`', '`t`', '`h`', '`P`'], 1,
        "P=0, y=1, t=2. Sanash 0 dan boshlanadi!")),
    Section('s3', '🔪', "Slicing — bo'lak kesib olish", [
      TextBlock(r"""**Slicing** (kesish) yordamida stringning bir qismini olamiz. Sintaksis: `[start:stop:step]`.

Eng muhim qoida: **`start` kiradi, `stop` kirmaydi.**"""),
      AnalogyBlock('🍞', 'Non kesish', r"""Non kesayotgandek tasavvur qiling. `[2:5]` degani — **2-kesikdan 5-kesikgacha** bo'lgan bo'lak. Kesiklar belgilar **orasida** turadi, shuning uchun bo'lak uzunligi doim `stop − start` ga teng: `5 − 2 = 3` belgi."""),
      BeadsBlock('Dasturlash', from: 0, to: 6),
      CodeBlock(r'''soz = "Dasturlash"

print(soz[0:6])     # 0-indeksdan 6-gacha (6 kirmaydi)
# Natija: Dastur

print(soz[:6])      # Boshidan boshlansa - 0 ni yozmasa ham bo'ladi
# Natija: Dastur

print(soz[6:])      # Oxirigacha - stop ni yozmang
# Natija: lash

print(soz[:])       # Hammasi - nusxa olish
# Natija: Dasturlash'''),
      TextBlock(r"""### Manfiy indeks bilan slicing"""),
      CodeBlock(r'''fayl = "hisobot.pdf"

print(fayl[-3:])    # Oxirgi 3 belgi
# Natija: pdf

print(fayl[:-4])    # Oxirgi 4 belgidan tashqari hammasi
# Natija: hisobot'''),
      TextBlock(r"""### Qadam (step)
Uchinchi son — **qadam**. Har nechanchi belgini olishni bildiradi."""),
      CodeBlock(r'''raqamlar = "0123456789"

print(raqamlar[::2])     # Har ikkinchi belgi
# Natija: 02468

print(raqamlar[1::2])    # 1-indeksdan boshlab har ikkinchi
# Natija: 13579

print(raqamlar[::-1])    # Manfiy qadam - teskari o'qish!
# Natija: 9876543210

soz = "salom"
print(soz[::-1])
# Natija: molas'''),
      NoteBlock(r"""`[::-1]` — stringni **teskari aylantirishning** eng mashhur usuli. Eslab qoling! 🔁 **Laboratoriya**da slicing'ni sichqoncha bilan boshqarib ko'ring.""", kind: NoteKind.tip),
      MnemonicBlock(r"""**"Start — kirish eshigi 🚪, stop — chiqish eshigi (u yerda tushib qolasiz)".** Avtobusda 2-bekatdan chiqib, 5-bekatda tushasiz: 2, 3, 4-bekatlarni ko'rasiz, 5-ni emas. **Uzunlik = stop − start.**"""),
    ], check: QuickCheck("`\"Dasturlash\"[2:5]` nima?", ['`ast`', '`stu`', '`stur`', '`as`'], 1,
        "D=0 a=1 **s=2 t=3 u=4** r=5. 5-indeks kirmaydi → \"stu\" (uzunligi 5−2 = 3).")),
    Section('s4', '➕', "len(), + va *", [
      CodeBlock(r'''matn = "Python"

print(len(matn))     # Uzunlik - nechta belgi bor
# Natija: 6

print(len(""))       # Bo'sh string uzunligi 0
# Natija: 0

# Qo'shish (konkatenatsiya)
ism = "Ali"
familiya = "Valiyev"
to_liq = ism + " " + familiya
print(to_liq)
# Natija: Ali Valiyev

# Ko'paytirish - takrorlash
print("-" * 20)
# Natija: --------------------

print("ha" * 3)
# Natija: hahaha'''),
      NoteBlock(r"""String va sonni `+` bilan qo'shib bo'lmaydi. `"Yosh: " + 25` → `TypeError`. Avval sonni `str(25)` bilan matnga aylantiring yoki **f-string** ishlating.""", kind: NoteKind.warning),
      MnemonicBlock(r"""**`+` — yelim 🧴, `*` — nusxa ko'chirish apparati 🖨️.** `"ha" * 3` → apparat 3 ta nusxa chiqaradi: `hahaha`."""),
    ], check: QuickCheck("`len(\"Salom dunyo\")` nechaga teng?", ['10', '11', '12', '2'], 1,
        "Probel ham belgi! 5 + 1 + 5 = 11.")),
    Section('s5', '🛠️', "Asosiy string metodlari", [
      TextBlock(r"""**Metod** — bu qiymatga biriktirilgan funksiya. Nuqta orqali chaqiriladi: `matn.metod()`.

### Registr (katta-kichik harf)"""),
      CodeBlock(r'''matn = "salom Dunyo"

print(matn.upper())
# Natija: SALOM DUNYO

print(matn.lower())
# Natija: salom dunyo

print(matn.title())
# Natija: Salom Dunyo

print(matn.capitalize())
# Natija: Salom dunyo'''),
      TextBlock(r"""### Tozalash va almashtirish"""),
      CodeBlock(r'''kiritilgan = "   ali@mail.com   "
print(kiritilgan.strip())       # chetlaridagi probellarni olib tashlaydi
# Natija: ali@mail.com

print("   matn".lstrip())       # faqat chapdan
# Natija: matn
print("matn   ".rstrip() + "|") # faqat o'ngdan
# Natija: matn|

matn = "Men Java yaxshi ko'raman"
print(matn.replace("Java", "Python"))
# Natija: Men Python yaxshi ko'raman

print("a b c".replace(" ", ""))
# Natija: abc'''),
      TextBlock(r"""### Bo'lish va birlashtirish"""),
      CodeBlock(r'''matn = "olma anor uzum"
mevalar = matn.split()           # ro'yxatga ajratadi
print(mevalar)
# Natija: ['olma', 'anor', 'uzum']

sana = "2026-09-19"
print(sana.split("-"))           # belgi bo'yicha bo'lish
# Natija: ['2026', '09', '19']

sozlar = ["Backend", "dasturlash", "kursi"]
print(" ".join(sozlar))          # ro'yxatni stringga birlashtiradi
# Natija: Backend dasturlash kursi

print("-".join(["2026", "09", "19"]))
# Natija: 2026-09-19'''),
      TextBlock(r"""### Qidirish va tekshirish"""),
      CodeBlock(r'''matn = "Python dasturlash tili"

print(matn.find("dastur"))   # indeksni qaytaradi
# Natija: 7
print(matn.find("Java"))     # topilmasa -1
# Natija: -1

print("banana".count("a"))   # necha marta uchraydi
# Natija: 3

fayl = "hisobot.pdf"
print(fayl.endswith(".pdf"))
# Natija: True
print(fayl.startswith("hisob"))
# Natija: True

print("12345".isdigit())     # faqat raqamlardanmi
# Natija: True
print("12a45".isdigit())
# Natija: False
print("".isdigit())
# Natija: False'''),
      TableBlock(['Metod', 'Vazifasi', 'Misol', 'Natija'], [
        ['`upper()`', 'Katta harfga', '`"ali".upper()`', '`"ALI"`'],
        ['`lower()`', 'Kichik harfga', '`"ALI".lower()`', '`"ali"`'],
        ['`title()`', "Har so'z bosh harfi", '`"ali vali".title()`', '`"Ali Vali"`'],
        ['`strip()`', 'Chet probellarni olish', '`" a ".strip()`', '`"a"`'],
        ['`replace()`', 'Almashtirish', '`"abc".replace("b","X")`', '`"aXc"`'],
        ['`split()`', "Ro'yxatga bo'lish", '`"a b".split()`', "`['a','b']`"],
        ['`join()`', 'Birlashtirish', '`",".join(["a","b"])`', '`"a,b"`'],
        ['`find()`', 'Indeksni topish', '`"abc".find("c")`', '`2`'],
        ['`count()`', 'Sanash', '`"aab".count("a")`', '`2`'],
        ['`startswith()`', 'Boshini tekshirish', '`"abc".startswith("a")`', '`True`'],
        ['`isdigit()`', 'Faqat raqammi', '`"12".isdigit()`', '`True`'],
      ]),
      NoteBlock(r"""Metodlar stringni **o'zgartirmaydi**, balki **yangi string qaytaradi**. `matn.upper()` deb yozsangiz, `matn` o'zgarmaydi — natijani o'zgaruvchiga saqlashingiz kerak.""", kind: NoteKind.warning),
      MnemonicBlock(r"""**split ✂️ — qaychi, join 🧵 — igna.** `split` bitta matnni bo'laklarga qirqadi, `join` bo'laklarni ip bilan tikadi: `"-".join(...)` — ip `-` rangida!"""),
    ], check: QuickCheck("`\"a,b,c\".split(\",\")` nima qaytaradi?", ["`'abc'`", "`['a', 'b', 'c']`", "`('a','b','c')`", "`['a,b,c']`"], 1,
        "split() ro'yxat (list) qaytaradi — vergul bo'yicha qirqildi.")),
    Section('s6', '🧙', "Maxsus belgilar va f-string", [
      TextBlock(r"""Ba'zi belgilarni to'g'ridan-to'g'ri yozib bo'lmaydi. Ular uchun **teskari chiziq** `\` ishlatiladi."""),
      CodeBlock(r'''print("Birinchi qator\nIkkinchi qator")   # \n - yangi qator
# Natija:
# Birinchi qator
# Ikkinchi qator

print("Ism\tYosh")                          # \t - tabulyatsiya
print("Ali\t25")

print("C:\\Users\\Ali")                    # \\ - teskari chiziqning o'zi
# Natija: C:\Users\Ali

print("U \"salom\" dedi")                  # \" - tirnoq
# Natija: U "salom" dedi

print(r"C:\yangi\papka")                   # r"" - xom (raw) string
# Natija: C:\yangi\papka'''),
      TextBlock(r"""### f-string haqida qisqacha
Stringga o'zgaruvchi qo'shishning eng qulay usuli — **f-string**. Keyingi darsda batafsil o'rganamiz:"""),
      CodeBlock(r'''ism = "Aziza"
yosh = 22

# Eski usul
print("Mening ismim " + ism + ", yoshim " + str(yosh))
# Natija: Mening ismim Aziza, yoshim 22

# f-string - ancha qulay
print(f"Mening ismim {ism}, yoshim {yosh}")
# Natija: Mening ismim Aziza, yoshim 22'''),
      MnemonicBlock(r"""**`\n` — "new line" (yangi qator) ↵, `\t` — "tab" ⇥.** Teskari chiziq `\` — sehrli tayoqcha: keyingi harfni oddiy harf emas, *buyruq* qiladi. `r""` esa tayoqchani tortib oladi 🪄🚫."""),
    ], check: QuickCheck("`print(\"A\\nB\")` necha qator chiqaradi?", ['1', '2', '3', 'Xato'], 1,
        "`\\n` — yangi qator belgisi. A va B alohida qatorlarda.")),
    Section('s7', '🗿', "String o'zgarmas (immutable)", [
      TextBlock(r"""String yaratilgandan keyin uning ichidagi belgini **o'zgartirib bo'lmaydi**."""),
      CodeBlock(r'''soz = "kitob"
soz[0] = "K"
# Natija: TypeError: 'str' object does not support item assignment'''),
      CodeBlock(r'''soz = "kitob"

yangi = "K" + soz[1:]     # To'g'ri yo'l - yangi string yasash
print(yangi)
# Natija: Kitob

print(soz.capitalize())   # Yoki metod orqali
# Natija: Kitob

print(soz)
# Natija: kitob'''),
      MnemonicBlock(r"""**String — toshga o'yilgan yozuv 🗿.** Harfini o'chirib bo'lmaydi — faqat **yangi tosh** o'yish mumkin. Shuning uchun har bir metod *yangi* string qaytaradi."""),
    ], check: QuickCheck("`soz = \"ota\"; soz.upper(); print(soz)` nima chiqaradi?", ['`OTA`', '`ota`', '`Ota`', 'Xato'], 1,
        "upper() yangi string qaytardi, lekin u hech qayerga saqlanmadi. `soz` o'zgarmagan.")),
    Section('s8', '⚠️', "Ko'p uchraydigan xatolar", [
      TextBlock(r"""**1. Metod natijasini saqlamaslik.** Eng ko'p uchraydigan xato:"""),
      CodeBlock(r'''matn = "  salom  "
matn.strip()          # Natija hech qayerga saqlanmadi!
print(f"[{matn}]")
# Natija: [  salom  ]

matn = matn.strip()   # To'g'ri
print(f"[{matn}]")
# Natija: [salom]'''),
      TextBlock(r"""**2. Indeksni 1 dan boshlash.** `soz[1]` — bu **ikkinchi** belgi, birinchi emas.
**3. `stop` kiradi deb o'ylash.** `"Python"[0:3]` → `"Pyt"`, `"Pyth"` emas.
**4. String va sonni `+` bilan qo'shish:**"""),
      CodeBlock(r'''print("Yosh: " + str(25))    # To'g'ri
# Natija: Yosh: 25

print("Yosh: " + 25)         # Xato
# Natija: TypeError: can only concatenate str (not "int") to str'''),
      TextBlock(r"""**5. `find()` natijasini `if` ichida to'g'ridan-to'g'ri ishlatish.** Agar so'z 0-indeksda bo'lsa, `find()` → `0` qaytaradi, `0` esa **falsy**! `!= -1` deb tekshiring yoki `in` ishlating:"""),
      CodeBlock(r'''matn = "Python zo'r"
if matn.find("Python"):
    print("topildi (1)")
else:
    print("topilmadi?! (1)")
# Natija: topilmadi?! (1)

if "Python" in matn:
    print("topildi (2)")
# Natija: topildi (2)'''),
    ], check: QuickCheck("`\"Python\"[0:3]` nima?", ['`Pyt`', '`Pyth`', '`yth`', '`Py`'], 0,
        "stop (3) kirmaydi: 0, 1, 2 → P, y, t.")),
  ],
  tasks: [
    CodeTask(
      id: 't1',
      title: "Ismingiz munchoqlari",
      description: r"""O'z ismingizni o'zgaruvchiga yozing. Uning **birinchi harfini**, **oxirgi harfini** va **uzunligini** chiqaring.""",
      starter: r'''ism = "Aziza"
''',
      solution: r'''ism = "Aziza"
print(ism[0])
print(ism[-1])
print(len(ism))
''',
      hints: ["Birinchi: `ism[0]`", "Oxirgi: `ism[-1]`", "Uzunlik: `len(ism)`"],
      check: (code, run) async {
        if (!codeHas(code, r'\[0\]')) return fail("Birinchi harf uchun `[0]` ishlating.");
        if (!codeHas(code, r'\[-1\]')) return fail("Oxirgi harf uchun `[-1]` ishlating.");
        if (!codeHas(code, r'len\(')) return fail("Uzunlik uchun `len()` ishlating.");
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (outLines(r).isEmpty) return fail("Natijani print() bilan chiqaring.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't2',
      title: "Oyna ichidagi matn",
      description: r"""`"Python dasturlash"` stringini `[::-1]` yordamida **teskari** chiqaring.""",
      starter: r'''matn = "Python dasturlash"
''',
      solution: r'''matn = "Python dasturlash"
print(matn[::-1])
''',
      hints: ["`print(matn[::-1])`"],
      check: (code, run) async {
        if (!codeHas(code, r'\[::-1\]')) return fail("`[::-1]` slicing'idan foydalaning.");
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (!r.stdout.contains('hsalrutsad nohtyP')) return fail("Natijada `hsalrutsad nohtyP` chiqishi kerak.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't3',
      title: "FAMILIYA Ism",
      description: r"""Foydalanuvchidan to'liq ismini so'rang, `split()` bilan ism va familiyaga ajrating, keyin `FAMILIYA Ism` ko'rinishida chiqaring.

💡 Tekshiruvda `Ali Valiyev` kiritiladi → `VALIYEV Ali` chiqishi kerak.""",
      starter: r'''toliq = input("To'liq ismingiz: ")
''',
      solution: r'''toliq = input("To'liq ismingiz: ")
ism, familiya = toliq.split()
print(familiya.upper(), ism)
''',
      hints: ["`ism, familiya = toliq.split()`", "`familiya.upper()`"],
      usesInput: true,
      check: (code, run) async {
        if (!codeHas(code, r'\.split\(')) return fail("`split()` metodidan foydalaning.");
        final r = await run('Ali Valiyev');
        final e = mustRun(r);
        if (e != null) return e;
        if (!r.stdout.contains('VALIYEV Ali')) return fail("`Ali Valiyev` kiritilganda `VALIYEV Ali` chiqishi kerak.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't4',
      title: "Email tozalagich",
      description: r"""`"  ALI@GMAIL.COM  "` stringini toza, kichik harfli manzilga aylantiring (`strip()` va `lower()`) va chiqaring.""",
      starter: r'''email = "  ALI@GMAIL.COM  "
''',
      solution: r'''email = "  ALI@GMAIL.COM  "
toza = email.strip().lower()
print(toza)
''',
      hints: ["Metodlarni zanjir qilish mumkin: `email.strip().lower()`"],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (!r.stdout.split('\n').contains('ali@gmail.com')) return fail("Aynan `ali@gmail.com` (probelsiz) chiqishi kerak.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't5',
      title: "Palindrom detektori",
      description: r"""Bitta so'z so'rang va uning **palindrom** (teskari o'qiganda ham bir xil) ekanini tekshiring. Masalan: `radar`, `kiyik`.

💡 Tekshiruv `radar` va `salom` so'zlari bilan o'tkaziladi.""",
      starter: r'''soz = input("So'z: ")
''',
      solution: r'''soz = input("So'z: ")
if soz == soz[::-1]:
    print("Palindrom!")
else:
    print("Palindrom emas")
''',
      hints: ["Teskarisi: `soz[::-1]`", "`if soz == soz[::-1]:` — yoki shunchaki `print(soz == soz[::-1])`"],
      usesInput: true,
      check: (code, run) async {
        final a = await run('radar');
        final e = mustRun(a);
        if (e != null) return e;
        final b = await run('salom');
        final e2 = mustRun(b);
        if (e2 != null) return e2;
        if (a.stdout.trim() == b.stdout.trim()) return fail("`radar` va `salom` uchun natija bir xil chiqdi — tekshiruvni qo'shing.");
        final low = a.stdout.toLowerCase();
        if (low.contains('emas') || low.contains('false')) return fail("`radar` palindrom, lekin dastur buni inkor qildi.");
        return TaskVerdict.pass;
      },
    ),
    CodeTask(
      id: 't6',
      title: "🐞 Xatolarni tuzating",
      description: r"""Bu kodda **3 ta** klassik string xatosi bor. Tuzating — natija 3 qator bo'lsin:
```
Kitob
Yosh: 25
[salom]
```""",
      starter: r'''soz = "kitob"
soz[0] = "K"
print(soz)

yosh = 25
print("Yosh: " + yosh)

matn = "  salom  "
matn.strip()
print(f"[{matn}]")
''',
      solution: r'''soz = "kitob"
soz = "K" + soz[1:]
print(soz)

yosh = 25
print("Yosh: " + str(yosh))

matn = "  salom  "
matn = matn.strip()
print(f"[{matn}]")
''',
      hints: [
        "String o'zgarmas: `soz = \"K\" + soz[1:]` yoki `soz.capitalize()`",
        "`str(yosh)` bilan matnga aylantiring",
        "Natijani saqlang: `matn = matn.strip()`",
      ],
      check: (code, run) async {
        final r = await run('');
        final e = mustRun(r);
        if (e != null) return e;
        if (outLines(r).join('|') != 'Kitob|Yosh: 25|[salom]') {
          return fail("Natija aynan 3 qator bo'lishi kerak: Kitob / Yosh: 25 / [salom]");
        }
        return TaskVerdict.pass;
      },
    ),
  ],
  pairs: const [
    MemoryPair('soz[0]', 'Birinchi belgi', "Sanash 0 dan boshlanadi."),
    MemoryPair('soz[-1]', 'Oxirgi belgi', "Manfiy indeks oxiridan sanaydi."),
    MemoryPair('soz[::-1]', 'Teskari string', "Manfiy qadam — orqaga o'qish."),
    MemoryPair('"Python"[0:3]', '"Pyt"', "stop kirmaydi!"),
    MemoryPair('"ha" * 3', '"hahaha"', "* — takrorlash."),
    MemoryPair('len("Salom")', '5', "len() belgilar sonini beradi."),
    MemoryPair('.strip()', 'Chet probellarni olish', "lstrip/rstrip — bir tomondan."),
    MemoryPair('.split()', "Ro'yxatga bo'lish", "Qaychi ✂️."),
    MemoryPair('"-".join(x)', 'Birlashtirish', "Igna 🧵."),
    MemoryPair('.find("Java")', '-1', "Topilmasa -1 qaytaradi."),
    MemoryPair('"\\n"', 'Yangi qator', "Escape belgisi."),
    MemoryPair('soz[0] = "K"', 'TypeError', "String o'zgarmas (immutable)."),
  ],
  quiz: const [
    QuizQ("`\"Python\"[-1]` nima?", ['`P`', '`n`', '`o`', 'IndexError'], 1, "Manfiy indeks oxiridan: -1 — oxirgi belgi."),
    QuizQ("Natija nima?", ['`Dastur`', '`Dasturl`', '`astur`', '`Dastu`'], 0, "0 dan 6 gacha, 6 kirmaydi → 6 ta belgi.",
        code: 'print("Dasturlash"[0:6])'),
    QuizQ("Natija nima?", ['`02468`', '`13579`', '`0246`', '`9753`'], 1, "1-indeksdan boshlab, har 2-belgi.",
        code: 'print("0123456789"[1::2])'),
    QuizQ("Stringni teskari aylantirish usuli?", ['`s.reverse()`', '`s[::-1]`', '`s[-1:]`', '`reversed(s)` natijasini print qilish'], 1,
        "`s[::-1]` — eng mashhur va qisqa usul."),
    QuizQ("Natija nima?", ['`  salom  `', '`salom`', "`[  salom  ]`", '`[salom]`'], 2,
        "strip() natijasi saqlanmadi — matn o'zgarmagan.", code: 'matn = "  salom  "\nmatn.strip()\nprint(f"[{matn}]")'),
    QuizQ("`\"banana\".count(\"a\")` nechaga teng?", ['1', '2', '3', '6'], 2, "b-**a**-n-**a**-n-**a** → 3 ta."),
    QuizQ("`\"Yosh: \" + 25` nima beradi?", ['`Yosh: 25`', 'TypeError', '`Yosh: `', 'SyntaxError'], 1,
        "Matnga son qo'shib bo'lmaydi. `str(25)` yoki f-string kerak."),
    QuizQ("`\"hisobot.pdf\"[-3:]` nima?", ['`pdf`', '`.pdf`', '`hisobot`', '`df`'], 0, "Oxirgi 3 belgi."),
    QuizQ("`\"olma anor\".split()` nima qaytaradi?", ["`'olma', 'anor'`", "`['olma', 'anor']`", "`['olma anor']`", "`('olma', 'anor')`"], 1,
        "split() — ro'yxat (list) qaytaradi."),
    QuizQ("Natija nima?", ['0', '-1', '7', 'Xato'], 2, "\"Python \" — 7 ta belgi, \"dastur\" 7-indeksdan boshlanadi.",
        code: 'print("Python dasturlash".find("dastur"))'),
    QuizQ("`soz = \"kitob\"; soz[0] = \"K\"` nima bo'ladi?", ['`Kitob`', 'TypeError', '`kitob`', 'IndexError'], 1,
        "String o'zgarmas — elementni almashtirib bo'lmaydi."),
    QuizQ("`r\"C:\\new\"` nima?", ["Yangi qatorli matn", "`C:\\new` — escape ishlamaydi", 'SyntaxError', "`C:ew`"], 1,
        "r-prefiks \"xom\" string yaratadi: teskari chiziq oddiy belgi bo'ladi."),
    QuizQ("`\"12a\".isdigit()` nima?", ['True', 'False', '12', 'Xato'], 1, "Faqat raqamlardan iborat bo'lsagina True."),
  ],
  cards: const [
    FlashCard('L3c1', "String indeksi nechadan boshlanadi?", "0 dan! soz[0] — birinchi belgi."),
    FlashCard('L3c2', "Oxirgi belgini qanday olasiz?", "", backCode: 'soz[-1]'),
    FlashCard('L3c3', "Slicing qoidasi `[start:stop]`?", "start kiradi, stop kirmaydi. Uzunlik = stop − start."),
    FlashCard('L3c4', "Stringni teskari aylantirish?", "", backCode: 'soz[::-1]'),
    FlashCard('L3c5', "`\"ha\" * 3` nima?", "\"hahaha\""),
    FlashCard('L3c6', "strip() nima qiladi?", "Chetlaridagi probellarni olib tashlaydi."),
    FlashCard('L3c7', "split() nima qaytaradi?", "Ro'yxat (list)", backCode: '"a b".split()  # [\'a\', \'b\']'),
    FlashCard('L3c8', "join() qanday ishlatiladi?", "", backCode: '"-".join(["2026", "09", "19"])\n# 2026-09-19'),
    FlashCard('L3c9', "find() topmasa nima qaytaradi?", "-1"),
    FlashCard('L3c10', "String metodlari asl stringni o'zgartiradimi?", "Yo'q! Yangi string qaytaradi — natijani saqlang."),
    FlashCard('L3c11', "`\\n` va `\\t` nima?", "`\\n` — yangi qator, `\\t` — tabulyatsiya."),
    FlashCard('L3c12', "`soz[0] = \"K\"` nega xato?", "String o'zgarmas (immutable). TypeError."),
    FlashCard('L3c13', "Ichida `'` bo'lgan matnni qanday yozasiz?", "Qo'sh tirnoqda: \"men'ning\""),
  ],
  summary: const [
    "String — belgilar ketma-ketligi, 1, 2 yoki 3 tirnoq bilan yoziladi",
    "Indekslash **0 dan** boshlanadi, manfiy indeks oxiridan sanaydi",
    "Slicing `[start:stop:step]` — `start` kiradi, `stop` kirmaydi; `[::-1]` teskari aylantiradi",
    "`len()` uzunlikni, `+` birlashtirishni, `*` takrorlashni bajaradi",
    "Metodlar (`upper`, `strip`, `split`, `join`, `replace`, ...) **yangi string qaytaradi**, natijani saqlash kerak",
    "`\\n`, `\\t`, `\\\\` — maxsus belgilar; `r\"\"` ularni oddiy matn qiladi",
    "String **o'zgarmas** (immutable) — ichidagi belgini almashtirib bo'lmaydi",
  ],
);
