@echo off
chcp 65001 >nul
echo ========================================
echo   重置 MySQL 密码（方法二）
echo   必须以管理员身份运行！
echo ========================================
echo.

set MYSQL_BIN=D:\develop\Mysql\bin
set MYSQL_INI=D:\develop\Mysql\my.ini

echo [1/6] 停止 MySQL 服务...
net stop MySQL80 2>nul
timeout /t 3 /nobreak >nul

echo.
echo [2/6] 在 my.ini 中添加 skip-grant-tables...
:: 备份 my.ini
copy "%MYSQL_INI%" "%MYSQL_INI%.bak" >nul

:: 在 [mysqld] 段后插入 skip-grant-tables
powershell -Command "(Get-Content '%MYSQL_INI%') -replace '\[mysqld\]', '[mysqld]`nskip-grant-tables`nskip-networking' | Set-Content '%MYSQL_INI%'"
echo my.ini 已修改

echo.
echo [3/6] 启动 MySQL（免密模式）...
net start MySQL80
timeout /t 5 /nobreak >nul

echo.
echo [4/6] 重置密码并创建数据库...
(
echo FLUSH PRIVILEGES;
echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root123';
echo FLUSH PRIVILEGES;
echo CREATE DATABASE IF NOT EXISTS pcds_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
) > "%TEMP%\pcds_reset.sql"

"%MYSQL_BIN%\mysql.exe" -u root < "%TEMP%\pcds_reset.sql"
echo 密码重置完成

echo.
echo [5/6] 恢复 my.ini（移除 skip-grant-tables）...
copy "%MYSQL_INI%.bak" "%MYSQL_INI%" >nul
echo my.ini 已恢复

echo.
echo [6/6] 重启 MySQL 正常模式...
net stop MySQL80 2>nul
timeout /t 3 /nobreak >nul
net start MySQL80
timeout /t 4 /nobreak >nul

echo.
echo ========== 验证 ==========
"%MYSQL_BIN%\mysql.exe" -u root -proot123 --connect-timeout=5 -e "SELECT '密码正确！' as 结果; SHOW DATABASES LIKE 'pcds_db';"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   成功！
    echo   密码：root123
    echo   数据库 pcds_db 已创建
    echo   现在双击"启动后端.bat"即可
    echo ========================================
) else (
    echo 失败，请截图发给我
)

del "%TEMP%\pcds_reset.sql" >nul 2>&1
del "%MYSQL_INI%.bak" >nul 2>&1
echo.
pause
