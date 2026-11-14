@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ===== 1) CLEAN =====
flutter clean

echo ===== 2) PUB GET =====
flutter pub get

echo ===== 3) ANALYZE =====
flutter analyze

echo ===== 4) TEST =====
flutter test

echo ===== 5) RUN CHROME =====
flutter run -d chrome

pause
