# آپلود App Bundle در کافه‌بازار (فایل bin)

بازار فایل AAB خام را مستقیم قبول نمی‌کند.
باید با ابزار **bundle-signer** از خود بازار، فایل `.bin` بسازی و آن را آپلود کنی.

## پیش‌نیاز
- فایل `app-release.aab` از Artifact گیت‌هاب (`zana-release-aab`)
- همان keystore انتشار: `zana-release.jks` (alias: `zana` / رمز: همان که ساختی)
- Java نصب باشد (`java -version`)

## ۱) دانلود ابزار
از این آدرس آخرین `bundlesigner-*.jar` را بگیر:
https://github.com/cafebazaar/bundle-signer/releases

## ۲) ساخت فایل bin (ویندوز)
فرض:
- `app-release.aab` روی دسکتاپ
- `bundlesigner-x.y.z.jar` روی دسکتاپ
- `zana-release.jks` روی دسکتاپ

```bat
cd C:\Users\1\Desktop
java -jar bundlesigner-0.1.4.jar genbin --bundle app-release.aab --bin . --ks zana-release.jks -v
```

رمز keystore را وقتی پرسید وارد کن.
خروجی یک فایل `.bin` کنار AAB است.

اگر نسخه jar فرق داشت، همان نام فایل دانلودشده را بگذار.

## ۳) پیشخان بازار
1. ایجاد برنامه / رهانش جدید
2. ابتدا AAB را انتخاب/آپلود کن (طبق UI پیشخان)
3. فایل **bin** تولیدشده را در همان مرحله بارگذاری کن
4. بقیه اطلاعات پایه، توضیحات، آیکون ۵۱۲، اسکرین‌شات

## نکته
- همیشه از **همان** keystore نسخه اول استفاده کن
- برای هر AAB جدید باید bin همان AAB را دوباره بسازی
- اگر فقط APK می‌فرستی، معمولاً نیازی به bin نیست؛ بازار برای AAB الزام bin دارد
