@echo off
echo ============================================
echo  Nettoyage complet du cache Gradle + Flutter
echo ============================================
echo.

echo [1/5] Arret du daemon Gradle...
cd android
call gradlew --stop 2>nul
cd ..

echo [2/5] Suppression de .gradle et build dans le projet...
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "build" rmdir /s /q "build"
if exist "android\build" rmdir /s /q "android\build"
if exist "android\app\build" rmdir /s /q "android\app\build"

echo [3/5] Suppression du cache Gradle 8.9 global...
if exist "%USERPROFILE%\.gradle\caches\8.9" rmdir /s /q "%USERPROFILE%\.gradle\caches\8.9"
if exist "%USERPROFILE%\.gradle\caches\transforms-4" rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-4"
if exist "%USERPROFILE%\.gradle\caches\modules-2\metadata-2.106" rmdir /s /q "%USERPROFILE%\.gradle\caches\modules-2\metadata-2.106"

echo [4/5] Nettoyage Flutter...
call flutter clean

echo [5/5] Reinstallation des dependances...
call flutter pub get

echo.
echo ============================================
echo  Termine ! Tu peux maintenant lancer :
echo    flutter run
echo ============================================
pause
