# فاز ۱ — معماری محتوا (فایل واحد)

## ساختار
- `methods_index.json` — فهرست سبک ابزارها (بدون سطح دشواری)
- `problems_index.json` — فهرست سبک مشکلات
- `units/methods/{id}.json` — `{ meta, slides }` هر ابزار
- `units/problems/{id}.json` — آبجکت کامل هر مشکل
- `by_category/methods/{cat}/{id}.json` — همان محتوا گروه‌بندی‌شده برای نویسندگی
- `by_category/problems/{cat}/{id}.json`

## رفتار اپ
- لیست ابزار از ایندکس
- اسلاید ابزار از `units/methods/{id}.json` (با پشتیبان method_slides.json)
- مشکلات از فایل واحد (با پشتیبان problems.json)

## حذف‌شده از متا/UI
- سطح دشواری ابزار از کارت کتابخانه
- فیلد diff در meta ایندکس جدید

## فاز ۲
تب مدیریت برای ایجاد/ویرایش/حذف روی همین فایل‌ها
