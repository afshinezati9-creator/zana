# امضای APK در GitHub Actions

## ساخت base64 از jks (ویندوز PowerShell)

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\zana-release.jks")) | Set-Clipboard
```

## Secrets در GitHub

Repository → Settings → Secrets and variables → Actions → New repository secret:

| Secret | مقدار |
|--------|--------|
| KEYSTORE_BASE64 | خروجی base64 بالا |
| KEYSTORE_PASSWORD | رمز keystore |
| KEY_PASSWORD | رمز کلید |
| KEY_ALIAS | مثلاً `zana` یا هر alias که موقع genkey زدی |

Alias را با این دستور ببین:

```bat
keytool -list -v -keystore zana-release.jks
```

بدون این Secrets هم Actions یک APK با امضای debug می‌سازد (فقط برای تست، نه فروشگاه).
