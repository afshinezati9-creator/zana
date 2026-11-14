# زانا (ZANA)

کتابخانهٔ رشد و خودآگاهی — آفلاین، رایگان، بدون تبلیغ.

**Package:** `ir.zana.app`  
**Version:** 1.0.0+1

## اجرای توسعه

```bat
flutter pub get
flutter analyze
flutter run -d chrome
```

## انتشار اندروید (کافه‌بازار)

جزئیات کامل: [CAFE_BAZAAR.md](CAFE_BAZAAR.md)

### ساخت APK امضاشده با GitHub Actions

1. ریپو: `https://github.com/afshinezati9-creator/zana`
2. Secrets ریپو:
   - `KEYSTORE_BASE64` = خروجی `certutil -encode zana-release.jks keystore.b64` (فقط بدنهٔ base64)
   - `KEYSTORE_PASSWORD`
   - `KEY_PASSWORD`
   - `KEY_ALIAS`
3. Push به `main` یا اجرای دستی workflow **Android Release APK**
4. از Artifacts فایل `app-release.apk` را دانلود کنید
5. در پیشخان بازار → ایجاد برنامه / رهانش جدید → آپلود APK

### ساخت محلی

```bat
flutter build apk --release
```

## ساختار محتوا

- `content/units/methods/` ابزارها
- `content/units/problems/` مشکلات
- `content/dilemmas.json` دوراهی‌های اخلاقی
- `content/methods_index.json` / `problems_index.json` فهرست

## حریم خصوصی

بدون سرور، بدون ردیابی، بدون تبلیغ. پیشرفت فقط روی دستگاه ذخیره می‌شود.
