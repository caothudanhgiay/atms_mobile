@echo off
setlocal enabledelayedexpansion

:: =======================================================
:: HUONG DAN CHAY: .\android_build_app.bat
:: 1. Mo cmd toi thu muc atms hoac terminal trong android studio
:: 2. Chay lenh .\android_build_app.bat
:: =======================================================

echo =======================================================
echo STARTING BUILD PROCESS FOR ANDROID
echo =======================================================

:: 1. Thiet lap thu muc dich (build_output ben trong project)
set OUTPUT_DIR=build_output

:: khong muon xoa
::if not exist "!OUTPUT_DIR!" (

:: xoa tat ca truoc khi copy
 if exist "!OUTPUT_DIR!" (
     echo [INFO] Cleaning output directory: !OUTPUT_DIR!...
     del /q "!OUTPUT_DIR!\*"
 ) else (
    mkdir "!OUTPUT_DIR!"
    echo [INFO] Created directory: !OUTPUT_DIR!
)

:: 2. Lay Version tu android/app/build.gradle
set GRADLE_FILE=android\app\build.gradle
for /f "tokens=2" %%a in ('findstr /C:"versionCode " %GRADLE_FILE%') do (
    set VERSION_CODE=%%a
)
for /f "tokens=2" %%a in ('findstr /C:"versionName " %GRADLE_FILE%') do (
    set VERSION_NAME=%%a
    set VERSION_NAME=!VERSION_NAME:"=!
)

echo [INFO] Detected Version: %VERSION_NAME% (Code: %VERSION_CODE%)

:: 3. Clean
echo [1/4] Cleaning project...
call fvm flutter clean || (echo [LOI] Khong the xoa build folder. & pause & exit /b)

echo [2/4] Fetching dependencies...
call fvm flutter pub get

:: 4. Build APK & Bundle
echo [3/4] Building APK...
call fvm flutter build apk --release --no-tree-shake-icons

echo [4/4] Building App Bundle...
call fvm flutter build appbundle --release --no-tree-shake-icons

:: 5. Rename va Copy vao thu muc build_output
echo =======================================================
echo [DONE] RENAME AND COPY TO !OUTPUT_DIR!
echo =======================================================

set APK_NEW_NAME=atms%VERSION_NAME%(%VERSION_CODE%).apk
set AAB_NEW_NAME=atms%VERSION_NAME%(%VERSION_CODE%).aab

:: Tim file APK va Copy
set FOUND_APK=0
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "!OUTPUT_DIR!\%APK_NEW_NAME%" /Y >nul
    set FOUND_APK=1
)

:: Tim file AAB va Copy
set FOUND_AAB=0
if exist "build\app\outputs\bundle\release\app-release.aab" (
    copy "build\app\outputs\bundle\release\app-release.aab" "!OUTPUT_DIR!\%AAB_NEW_NAME%" /Y >nul
    set FOUND_AAB=1
)

:: Thong bao ket qua
if !FOUND_APK! equ 1 (
    echo [+] SUCCESS: Copied APK to !OUTPUT_DIR! -> %APK_NEW_NAME%
) else (
    echo [!] ERROR: Could not find APK file to copy.
)

if !FOUND_AAB! equ 1 (
    echo [+] SUCCESS: Copied AAB to !OUTPUT_DIR! -> %AAB_NEW_NAME%
) else (
    echo [!] ERROR: Could not find AAB file to copy.
)

echo =======================================================
echo FINISHED!
echo -------------------------------------------------------
echo San pham build nam tai: !OUTPUT_DIR!\
echo =======================================================
pause