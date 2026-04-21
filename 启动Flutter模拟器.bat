@echo off
chcp 65001 >nul
echo ========================================
echo   启动 Flutter APP（模拟器）
echo ========================================
echo.

cd /d G:\biye\-Personalized_Clothing_Design_System\Personalized_Clothing_Design_System-app-flutter

echo 检查 Flutter...
flutter --version
if %errorlevel% neq 0 (
    echo 错误：未找到 Flutter，请先安装 Flutter SDK
    pause
    exit /b 1
)

echo.
echo 获取依赖...
flutter pub get

echo.
echo 查看可用设备...
flutter devices

echo.
echo 运行 APP（dev 版本）...
echo 注意：请先启动 Android 模拟器！
echo.
flutter run --flavor dev -t lib/main_dev.dart
pause
