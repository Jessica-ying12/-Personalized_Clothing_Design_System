@echo off
chcp 65001 >nul
echo ========================================
echo   个性化服装设计系统 - 数据库初始化
echo ========================================
echo.

echo [1/3] 启动 MySQL 服务...
net start MySQL80
if %errorlevel% neq 0 (
    echo MySQL 服务已在运行或启动失败，继续...
)
timeout /t 3 /nobreak >nul

echo.
echo [2/3] 创建数据库 pcds_db...
"D:\develop\Mysql\bin\mysql.exe" -u root -proot123 -e "CREATE DATABASE IF NOT EXISTS pcds_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if %errorlevel% equ 0 (
    echo 数据库创建成功！
) else (
    echo 数据库创建失败，请检查 MySQL 是否正常运行
    pause
    exit /b 1
)

echo.
echo [3/3] 验证数据库...
"D:\develop\Mysql\bin\mysql.exe" -u root -proot123 -e "SHOW DATABASES LIKE 'pcds_db';"

echo.
echo ========================================
echo   完成！数据库已就绪
echo   现在可以启动后端了：
echo   cd pcds-backend\backend
echo   python main.py
echo ========================================
pause
