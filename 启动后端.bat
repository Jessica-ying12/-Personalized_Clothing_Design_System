
@echo off
chcp 65001 >nul
echo ========================================
echo   启动后端服务
echo ========================================
echo.
cd /d G:\biye\-Personalized_Clothing_Design_System\pcds-backend\backend
echo 启动中，请稍候...
echo 看到 "个性化服装设计系统后端启动成功" 就好了
echo 按 Ctrl+C 可以停止
echo.
python main.py
pause
