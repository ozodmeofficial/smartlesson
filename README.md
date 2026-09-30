# 🐍 Python Sarguzashti

O'zgaruvchilar, ma'lumot turlari va stringlar mavzularini **o'yin, laboratoriya va jonli kod** orqali o'rgatadigan interaktiv darslik. Flutter'da yozilgan, Windows uchun `.exe` sifatida yig'iladi.

## Nimalar bor

| Bo'lim | Tavsif |
|---|---|
| 📖 **Nazariya** | 3 dars × 8 bo'lim. Har bir bo'limda analogiya, rangli kod, «Eslab qolish kaliti» (mnemonika) va tezkor savol |
| ▶️ **Jonli kod** | Har bir misolni bir tugma bilan haqiqiy Python 3 da ishga tushirish, «O'zgartirib ko'r» — Python maydonida tahrirlash |
| 🔬 **Laboratoriyalar** | Xotira laboratoriyasi (yorliqlar va `id()` animatsiyasi), Nom tekshiruvchi, Tur saralash (60 s), Truthy/Falsy, Slicing ustaxonasi, Slice ninja (10 daraja) |
| 💻 **Amaliyot** | 18 ta vazifa (har darsda 6 ta, jumladan «🐞 Xatolarni tuzating»), avtomatik tekshiruv, bosqichli maslahatlar |
| 🧠 **Xotira o'yini** | Kod ↔ ma'no juftliklarini topish |
| 📝 **Testlar** | Har dars uchun 13 savol + 20 savollik **Katta imtihon** → shaxsiy **sertifikat** |
| 🔁 **Takrorlash** | Leitner tizimidagi 39 flesh-karta (oraliqli takrorlash — bilim yillar davomida saqlanadi) |
| 🏆 **Motivatsiya** | XP, darajalar, kunlik seriya 🔥, 14 ta yutuq, konfetti |

Xato bo'lsa, Python xabari bilan birga **o'zbekcha tushuntirish** ham chiqadi.

## Yuklab olish (Windows)

GitHub'dagi **Releases** bo'limidan (yoki Actions → oxirgi «Windows .exe build» → Artifacts):

- `PythonSarguzashti-Setup.exe` — o'rnatuvchi (administrator huquqi shart emas);
- `PythonSarguzashti-Portable.zip` — o'rnatmasdan ishlatish: arxivni oching → `python_sarguzashti.exe`.

Har bir push'da `.github/workflows/windows.yml` Windows runner'da ilovani yig'adi, testlardan o'tkazadi va yangi release yaratadi.

## Kod qanday ishga tushadi

Python kodi Judge0 API orqali bajariladi (`lib/services/runner.dart`, `CodeRunner.endpoint`). Shuning uchun kodni ishga tushirish va vazifalarni tekshirish uchun **internet kerak**. Internet bo'lmasa, darslik misollari uchun kutilgan natija (`# Natija:` izohlaridan) ko'rsatiladi; nazariya, o'yinlar, laboratoriyalar, testlar va takrorlash internetsiz ham to'liq ishlaydi.

## O'zingiz yig'ish

```bash
flutter pub get
flutter test
flutter build windows --release   # faqat Windows'da
```

Natija: `build\windows\x64\runner\Release\python_sarguzashti.exe` (butun `Release` papkasi birga tarqatiladi).

## Tuzilishi

```
lib/
  data/        darslar kontenti (lesson1..3.dart), modellar, yutuqlar
  services/    runner.dart (Judge0), progress.dart (XP, Leitner, saqlash)
  screens/     bosh sahifa, nazariya, test, vazifalar, o'yinlar, labs/
  widgets/     kod ko'rinishi va muharrir, munchoqlar, umumiy UI
installer/     Inno Setup skripti
```

Yangi emoji qo'shsangiz, `assets/fonts/Emoji.ttf` (Noto Color Emoji'ning kichik to'plami) ni qayta yig'ing — aks holda Windows tizim shriftidan foydalaniladi.

Shriftlar: Nunito, JetBrains Mono, Noto Color Emoji — SIL Open Font License (`assets/fonts/OFL-*.txt`).
