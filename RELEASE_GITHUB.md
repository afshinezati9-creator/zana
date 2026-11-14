# انتشار زانا — APK و AAB

## شناسه برنامه
- Package: `ir.zana.app`
- Alias مورد انتظار: `zana`
- targetSdk: 34

## دو حالت ساخت
1. **CI / Test:** در pushهای عادی، اگر کلید انتشار تنظیم نشده باشد، خروجی با debug signing ساخته می‌شود. این خروجی صرفاً برای تست است و نباید در کافه‌بازار منتشر شود.
2. **Production:** از Actions → Android Release APK → Run workflow گزینه `production` را انتخاب کنید. هر چهار Repository Secret زیر باید معتبر باشند؛ در غیر این صورت Workflow با پیام روشن متوقف می‌شود.

## Secrets لازم
- `KEYSTORE_BASE64`: محتوای Base64 فایل keystore
- `KEYSTORE_PASSWORD`: رمز keystore
- `KEY_PASSWORD`: رمز کلید
- `KEY_ALIAS`: alias کلید

مقادیر واقعی را فقط در GitHub Secrets ذخیره کنید؛ هرگز رمز یا محتوای keystore را در فایل‌های مخزن، کد یا لاگ قرار ندهید. رمزهایی که قبلاً در یک فایل عمومی مخزن درج شده بودند افشا شده‌اند و نباید دوباره استفاده شوند.

## خروجی‌ها
- `zana-ci-debug-signed-apk` یا `zana-production-signed-apk`
- `zana-ci-debug-signed-aab` یا `zana-production-signed-aab`

خروجی CI با debug key فقط برای تست است. برای انتشار، فقط Artifactهای production را استفاده کنید.
