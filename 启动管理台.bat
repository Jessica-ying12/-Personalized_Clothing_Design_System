@echo off
chcp 65001 >nul
echo ========================================
echo   启动管理台
echo ========================================
echo.

cd /d G:\biye\-Personalized_Clothing_Design_System\pcds-admin

echo 检查 Node.js...
node --version
if %errorlevel% neq 0 (
    echo 错误：未找到 Node.js，请先安装 Node.js 18+
    pause
    exit /b 1
)

echo.
if not exist node_modules (
    echo 首次运行，安装依赖（约需 5 分钟）...
    yarn install
) else (
    echo 依赖已存在，跳过安装
)

echo.
echo 启动管理台（端口 5183）...
echo 启动后请访问：http://localhost:5183
echo 按 Ctrl+C 停止服务
echo.
yarn dev
pause
