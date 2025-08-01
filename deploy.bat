@echo off
echo ========================================
echo   DEPLOY DASHBOARD TO FIREBASE HOSTING
echo ========================================
echo.

echo [1/3] Building Flutter web app...
flutter build web --release --base-href "/"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)

echo.
echo [2/3] Build completed successfully!
echo Files ready in: build\web\
echo.

echo [3/3] Next steps:
echo 1. Go to https://console.firebase.google.com/
echo 2. Select your project or create new one
echo 3. Go to Hosting section
echo 4. Upload all files from build\web\ folder
echo 5. Deploy!
echo.

echo Opening build folder...
start explorer build\web

echo.
echo ========================================
echo   BUILD COMPLETED - READY TO DEPLOY!
echo ========================================
pause