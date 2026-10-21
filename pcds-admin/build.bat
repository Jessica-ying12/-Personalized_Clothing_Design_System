@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 项目配置
set "PROJECT_NAME=hammer-admin-frontend"
set "CONTAINER_NAME=hammer-admin-frontend-container"
set "DEFAULT_PORT=80"
set "HOST_PORT=8080"

:: 镜像仓库配置
set "REGISTRY=registry.example.com:5000"
set "NAMESPACE=pcds"
set "IMAGE_NAME=pcds-admin-frontend"

:: 自动获取镜像标签（基于 Git 分支）
call :get_git_info
set "FULL_IMAGE=%REGISTRY%/%NAMESPACE%/%IMAGE_NAME%:%IMAGE_TAG%"

:: 主逻辑 - 参数处理
set "COMMAND=%~1"

if "%COMMAND%"=="" (
    call :show_system_info
    call :show_help
    goto :eof
)

if "%COMMAND%"=="clean" (
    if "%~2"=="--images" (
        call :clean_docker true
    ) else (
        call :clean_docker false
    )
    goto :eof
)

if "%COMMAND%"=="build" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :build_docker_image default
    goto :eof
)

if "%COMMAND%"=="build:prod" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :build_docker_image production
    goto :eof
)

if "%COMMAND%"=="build:test" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :build_docker_image test
    goto :eof
)

if "%COMMAND%"=="build:dev" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :build_docker_image development
    goto :eof
)

if "%COMMAND%"=="build:amd64" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :build_docker_image_amd64 default
    goto :eof
)

if "%COMMAND%"=="run" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :run_docker_container default
    goto :eof
)

if "%COMMAND%"=="run:prod" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :run_docker_container production
    goto :eof
)

if "%COMMAND%"=="run:test" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :run_docker_container test
    goto :eof
)

if "%COMMAND%"=="run:dev" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :run_docker_container development
    goto :eof
)

if "%COMMAND%"=="push" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :push_to_registry
    goto :eof
)

if "%COMMAND%"=="deploy" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :clean_docker false
    call :build_docker_image_amd64 default
    if errorlevel 1 exit /b 1
    call :push_to_registry
    if errorlevel 1 exit /b 1
    call :print_message "🎉 部署流程完成！"
    goto :eof
)

if "%COMMAND%"=="deploy:prod" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :clean_docker false
    call :build_docker_image_amd64 production
    if errorlevel 1 exit /b 1
    call :push_to_registry
    if errorlevel 1 exit /b 1
    call :print_message "🎉 生产环境部署流程完成！"
    goto :eof
)

if "%COMMAND%"=="deploy:test" (
    call :show_system_info
    call :check_docker
    if errorlevel 1 exit /b 1
    call :clean_docker false
    call :build_docker_image_amd64 test
    if errorlevel 1 exit /b 1
    call :push_to_registry
    if errorlevel 1 exit /b 1
    call :print_message "🎉 测试环境部署流程完成！"
    goto :eof
)

if "%COMMAND%"=="help" goto :show_help
if "%COMMAND%"=="--help" goto :show_help
if "%COMMAND%"=="-h" goto :show_help

call :print_message "❌ 未知命令: %COMMAND%"
call :show_help
exit /b 1


:: ==========================================
:: 函数定义区域
:: ==========================================

:print_message
set "MSG=%~1"
echo [%DATE% %TIME%] %MSG%
ver > nul
goto :eof

:get_git_info
set "GIT_ROOT="
set "TEMP_DIR=%CD%"

:find_git_loop
if exist "%TEMP_DIR%\.git" (
    set "GIT_ROOT=%TEMP_DIR%"
    goto :git_found
)
for %%I in ("%TEMP_DIR%\..") do set "PARENT_DIR=%%~fI"
if "%PARENT_DIR%"=="%TEMP_DIR%" goto :git_not_found
set "TEMP_DIR=%PARENT_DIR%"
goto :find_git_loop

:git_found
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "BRANCH_NAME=%%i"
if "%BRANCH_NAME%"=="" set "BRANCH_NAME=main"
set "IMAGE_TAG=%BRANCH_NAME%"
set "IMAGE_TAG=!IMAGE_TAG:/=-!"
set "IMAGE_TAG=!IMAGE_TAG:\=-!"
set "IMAGE_TAG=!IMAGE_TAG::=-!"
call :print_message "📌 Git 分支: %BRANCH_NAME% -> 镜像标签: %IMAGE_TAG%"
ver > nul
goto :eof

:git_not_found
set "IMAGE_TAG=latest"
call :print_message "⚠️ 非 Git 仓库，使用默认标签: %IMAGE_TAG%"
ver > nul
goto :eof

:show_system_info
call :print_message "========================================"
call :print_message "   Hammer Admin Frontend 构建脚本"
call :print_message "========================================"
echo 项目名称: %PROJECT_NAME%
echo 镜像标签: %IMAGE_TAG%
echo 完整镜像: %FULL_IMAGE%
echo 容器端口: %DEFAULT_PORT% -^> 主机端口: %HOST_PORT%
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('docker --version') do echo Docker  : %%v
) else (
    echo Docker  : Not Installed
)
call :print_message "========================================"
ver > nul
goto :eof

:check_docker
where docker >nul 2>&1
if %errorlevel% neq 0 (
    call :print_message "❌ 错误: 未找到命令 'docker'"
    exit /b 1
)
docker info >nul 2>&1
if %errorlevel% neq 0 (
    call :print_message "❌ 错误: Docker 服务未响应"
    call :print_message "💡 请检查 Docker Desktop 是否已启动并正在运行"
    exit /b 1
)
ver > nul
goto :eof


:select_dockerfile
set "ENV_MODE=%~1"
if "%ENV_MODE%"=="" set "ENV_MODE=default"
set "DOCKERFILE=Dockerfile"

if "%ENV_MODE%"=="production" (
    if exist "prod.Dockerfile" set "DOCKERFILE=prod.Dockerfile"
    if exist "Dockerfile.prod" set "DOCKERFILE=Dockerfile.prod"
)
if "%ENV_MODE%"=="test" (
    if exist "test.Dockerfile" set "DOCKERFILE=test.Dockerfile"
    if exist "Dockerfile.test" set "DOCKERFILE=Dockerfile.test"
)
if "%ENV_MODE%"=="development" (
    if exist "local.Dockerfile" set "DOCKERFILE=local.Dockerfile"
    if exist "Dockerfile.dev" set "DOCKERFILE=Dockerfile.dev"
)

if not exist "%DOCKERFILE%" (
    call :print_message "❌ 错误: Dockerfile '%DOCKERFILE%' 不存在"
    exit /b 1
)
set "SELECTED_DOCKERFILE=%DOCKERFILE%"
ver > nul
goto :eof

:clean_docker
set "CLEAN_IMAGES=%~1"
call :print_message "🧹 清理 Docker 资源..."

docker ps -a --format "{{.Names}}" | findstr /x "%CONTAINER_NAME%" >nul
if %errorlevel% equ 0 (
    call :print_message "🛑 停止并删除容器: %CONTAINER_NAME%"
    docker stop "%CONTAINER_NAME%" >nul 2>&1
    docker rm "%CONTAINER_NAME%" >nul 2>&1
) else (
    call :print_message "ℹ️  容器 %CONTAINER_NAME% 未运行"
)

if "%CLEAN_IMAGES%"=="true" (
    call :print_message "🐳 清理本地 Docker 镜像..."
    docker images --format "{{.Repository}}:{{.Tag}}" | findstr /x "%PROJECT_NAME%:%IMAGE_TAG%" >nul
    if %errorlevel% equ 0 (
        docker rmi "%PROJECT_NAME%:%IMAGE_TAG%"
        call :print_message "✅ Docker 镜像已清理: %PROJECT_NAME%:%IMAGE_TAG%"
    ) else (
        call :print_message "ℹ️  没有找到需要清理的镜像: %PROJECT_NAME%:%IMAGE_TAG%"
    )
)
call :print_message "✅ 清理完成"
ver > nul
goto :eof

:build_docker_image
set "ENV_MODE=%~1"
call :select_dockerfile "%ENV_MODE%"
if %errorlevel% neq 0 exit /b 1

call :print_message "🐳 构建 Docker 镜像 (环境: %ENV_MODE%)..."
call :print_message "📄 使用 Dockerfile: %SELECTED_DOCKERFILE%"
call :print_message "🏷️  镜像标签: %PROJECT_NAME%:%IMAGE_TAG%"

docker build -f "%SELECTED_DOCKERFILE%" -t "%PROJECT_NAME%:%IMAGE_TAG%" .
if %errorlevel% neq 0 (
    call :print_message "❌ 镜像构建失败"
    exit /b 1
)
call :print_message "✅ 镜像构建完成: %PROJECT_NAME%:%IMAGE_TAG%"
ver > nul
goto :eof

:build_docker_image_amd64
set "ENV_MODE=%~1"
call :select_dockerfile "%ENV_MODE%"
if %errorlevel% neq 0 exit /b 1

call :print_message "🐳 构建 Linux/amd64 平台镜像 (环境: %ENV_MODE%)..."
call :print_message "📄 使用 Dockerfile: %SELECTED_DOCKERFILE%"

docker build --platform linux/amd64 --load -f "%SELECTED_DOCKERFILE%" -t "%PROJECT_NAME%:%IMAGE_TAG%" .
if %errorlevel% neq 0 (
    call :print_message "❌ amd64 镜像构建失败"
    exit /b 1
)
call :print_message "✅ amd64 镜像构建完成: %PROJECT_NAME%:%IMAGE_TAG%"
ver > nul
goto :eof


:run_docker_container
set "ENV_MODE=%~1"
call :print_message "🚀 启动 Docker 容器 (环境: %ENV_MODE%)..."

docker images --format "{{.Repository}}:{{.Tag}}" | findstr /x "%PROJECT_NAME%:%IMAGE_TAG%" >nul
if %errorlevel% neq 0 (
    call :print_message "⚠️  本地镜像 %PROJECT_NAME%:%IMAGE_TAG% 不存在，尝试构建..."
    call :build_docker_image "%ENV_MODE%"
    if %errorlevel% neq 0 exit /b 1
)

docker ps -a --format "{{.Names}}" | findstr /x "%CONTAINER_NAME%" >nul
if %errorlevel% equ 0 (
    call :print_message "🛑 停止现有容器..."
    docker stop "%CONTAINER_NAME%" >nul 2>&1
    docker rm "%CONTAINER_NAME%" >nul 2>&1
)

docker run -d --name "%CONTAINER_NAME%" -p %HOST_PORT%:%DEFAULT_PORT% "%PROJECT_NAME%:%IMAGE_TAG%"
if %errorlevel% neq 0 (
    call :print_message "❌ 容器启动失败"
    exit /b 1
)

call :print_message "✅ 容器启动成功"
call :print_message "🌐 访问地址: http://localhost:%HOST_PORT%/"
call :print_message "📋 查看日志: docker logs -f %CONTAINER_NAME%"
ver > nul
goto :eof

:push_to_registry
call :print_message "☁️  准备推送镜像到仓库..."

docker image inspect "%PROJECT_NAME%:%IMAGE_TAG%" >nul 2>&1
if %errorlevel% neq 0 (
    call :print_message "❌ 错误: 本地镜像 %PROJECT_NAME%:%IMAGE_TAG% 不存在"
    call :print_message "💡 请先运行 build 命令构建镜像"
    exit /b 1
)

if not "%REGISTRY%"=="docker.io" (
    call :print_message "🔐 正在推送到 Registry: %REGISTRY%"
)

call :print_message "🏷️  标记镜像: %FULL_IMAGE%"
docker tag "%PROJECT_NAME%:%IMAGE_TAG%" "%FULL_IMAGE%"

call :print_message "📤 推送镜像..."
docker push "%FULL_IMAGE%"
if %errorlevel% equ 0 (
    call :print_message "✅ 镜像推送完成: %FULL_IMAGE%"
) else (
    call :print_message "❌ 镜像推送失败"
    exit /b 1
)
ver > nul
goto :eof

:show_help
echo Hammer Admin Frontend Docker 镜像管理脚本
echo.
echo 用法: %~nx0 [命令]
echo.
echo 命令:
echo   clean           清理 Docker 容器
echo   clean --images  清理 Docker 容器和镜像
echo   build           构建 Docker 镜像（默认环境）
echo   build:prod      构建生产环境镜像
echo   build:test      构建测试环境镜像
echo   build:dev       构建开发环境镜像
echo   build:amd64     构建 amd64 平台镜像（用于服务器部署）
echo   run             运行 Docker 容器（默认环境）
echo   run:prod        运行生产环境容器
echo   run:test        运行测试环境容器
echo   run:dev         运行开发环境容器
echo   push            推送镜像到仓库
echo   deploy          完整部署流程 (build:amd64 + push)
echo   deploy:prod     生产环境完整部署
echo   deploy:test     测试环境完整部署
echo   help            显示此帮助信息
echo.
echo 镜像标签策略:
echo   - Git 仓库: 自动使用当前分支名作为标签 (当前: %IMAGE_TAG%)
echo   - 非 Git:   使用默认标签 'latest'
echo.
echo 示例:
echo   %~nx0 build:prod      # 构建生产环境镜像
echo   %~nx0 run             # 本地运行容器
echo   %~nx0 deploy          # 构建 amd64 镜像并推送到仓库
echo.
ver > nul
goto :eof