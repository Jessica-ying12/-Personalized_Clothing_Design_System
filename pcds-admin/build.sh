#!/bin/bash

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="hammer-admin-frontend"           # 项目名称
CONTAINER_NAME="hammer-admin-frontend-container" # 容器名称
DEFAULT_PORT=80                                # 容器内端口 (Nginx 默认端口)
HOST_PORT=8080                                 # 主机映射端口

# 镜像仓库配置
REGISTRY="registry.example.com:5000"
NAMESPACE="pcds"
IMAGE_NAME="pcds-admin-frontend"             # 镜像名称

# 自动获取镜像标签（基于 Git 分支）
if [ -d ".git" ]; then
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    # 将分支名中的特殊字符替换为 -
    IMAGE_TAG=$(echo "$BRANCH_NAME" | sed 's/[^a-zA-Z0-9._-]/-/g')
else
    IMAGE_TAG="latest"
fi

FULL_IMAGE="$REGISTRY/$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"

# -----------------------------------------------------------------------------
# 辅助函数
# -----------------------------------------------------------------------------

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_message $RED "❌ 错误: 未找到命令 '$1'"
        print_message $YELLOW "💡 请先安装 $1"
        exit 1
    fi
}

show_system_info() {
    print_message $BLUE "========================================"
    print_message $BLUE "   Hammer Admin Frontend 构建脚本"
    print_message $BLUE "========================================"
    echo "项目名称: $PROJECT_NAME"
    echo "镜像标签: $IMAGE_TAG"
    echo "完整镜像: $FULL_IMAGE"
    echo "容器端口: $DEFAULT_PORT -> 主机端口: $HOST_PORT"
    echo "操作系统: $(uname -s) $(uname -m)"
    print_message $BLUE "========================================"
    echo ""
}

# 根据环境自动选择 Dockerfile
select_dockerfile() {
    local env_mode=${1:-"production"}
    local dockerfile="Dockerfile"
    
    # 优先级：环境专用 Dockerfile > 默认 Dockerfile
    if [ "$env_mode" = "production" ]; then
        if [ -f "prod.Dockerfile" ]; then
            dockerfile="prod.Dockerfile"
        elif [ -f "Dockerfile.prod" ]; then
            dockerfile="Dockerfile.prod"
        fi
    elif [ "$env_mode" = "development" ] || [ "$env_mode" = "dev" ]; then
        if [ -f "local.Dockerfile" ]; then
            dockerfile="local.Dockerfile"
        elif [ -f "Dockerfile.dev" ]; then
            dockerfile="Dockerfile.dev"
        fi
    elif [ "$env_mode" = "test" ]; then
        if [ -f "test.Dockerfile" ]; then
            dockerfile="test.Dockerfile"
        elif [ -f "Dockerfile.test" ]; then
            dockerfile="Dockerfile.test"
        fi
    fi
    
    # 检查文件是否存在
    if [ ! -f "$dockerfile" ]; then
        print_message $RED "❌ 错误: Dockerfile '$dockerfile' 不存在"
        exit 1
    fi
    
    echo "$dockerfile"
}

# -----------------------------------------------------------------------------
# 核心功能
# -----------------------------------------------------------------------------

# 1. 清理 Docker 资源
clean_docker() {
    local clean_images=${1:-"false"}
    print_message $YELLOW "🧹 清理 Docker 资源..."
    
    # 停止并删除容器
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        print_message $YELLOW "🛑 停止并删除容器: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    else
        print_message $YELLOW "ℹ️  容器 $CONTAINER_NAME 不存在或已停止"
    fi
    
    # 清理镜像（可选）
    if [ "$clean_images" = "true" ]; then
        print_message $YELLOW "🐳 清理本地 Docker 镜像..."
        # 注意：这里只清理与当前项目相关的镜像
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "$PROJECT_NAME"; then
            docker images --format "{{.Repository}}:{{.Tag}}" | grep "$PROJECT_NAME" | xargs -r docker rmi -f
            print_message $GREEN "✅ Docker 镜像已清理"
        else
            print_message $YELLOW "ℹ️  没有找到需要清理的镜像"
        fi
    fi
    
    print_message $GREEN "✅ 清理完成"
}

# 2. 构建 Docker 镜像
build_docker_image() {
    local env_mode=${1:-"production"}
    local dockerfile=$(select_dockerfile "$env_mode")
    local platform_arg=""

    # 如果指定了 amd64 平台
    if [ "$2" = "amd64" ]; then
        platform_arg="--platform linux/amd64"
        print_message $BLUE "🐳 构建 Linux/amd64 平台镜像 (环境: $env_mode)..."
    else
        print_message $BLUE "🐳 构建 Docker 镜像 (环境: $env_mode)..."
    fi

    print_message $BLUE "📄 使用 Dockerfile: $dockerfile"
    print_message $BLUE "🏷️  镜像标签: $PROJECT_NAME:$IMAGE_TAG"
    
    # 构建命令
    docker build $platform_arg -f "$dockerfile" -t "$PROJECT_NAME:$IMAGE_TAG" .
    
    print_message $GREEN "✅ 镜像构建完成: $PROJECT_NAME:$IMAGE_TAG"
}

# 3. 运行 Docker 容器
run_docker_container() {
    local env_mode=${1:-"production"}
    print_message $BLUE "🚀 启动 Docker 容器 (环境: $env_mode)..."
    
    # 停止并删除现有容器
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        print_message $YELLOW "🛑 停止现有容器..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    
    # 启动新容器
    print_message $BLUE "映射端口: $HOST_PORT -> $DEFAULT_PORT"
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p $HOST_PORT:$DEFAULT_PORT \
        "$PROJECT_NAME:$IMAGE_TAG"
    
    print_message $GREEN "✅ 容器启动成功"
    print_message $BLUE "🌐 访问地址: http://localhost:$HOST_PORT/"
}

# 4. 检查 Registry 登录状态
check_registry_login() {
    local registry=$1
    print_message $BLUE "🔐 检查 Registry 登录状态: $registry"
    
    # 检查 Docker 配置文件中是否有该 registry 的认证信息
    local auth_exists=false
    if [ -f "$HOME/.docker/config.json" ]; then
        # 尝试从配置文件中查找认证信息
        if grep -q "$registry" "$HOME/.docker/config.json"; then
            auth_exists=true
        fi
    fi
    
    if [ "$auth_exists" = false ]; then
        print_message $YELLOW "⚠️  未登录到 Registry: $registry"
        print_message $YELLOW "💡 请提供登录凭据"
        docker login "$registry" || {
            print_message $RED "❌ 登录失败"
            exit 1
        }
    else
        print_message $GREEN "✅ 已登录到 Registry: $registry"
    fi
}

# 5. 推送镜像到仓库
push_to_registry() {
    print_message $BLUE "☁️  推送镜像到仓库..."
    
    # 检查本地镜像是否存在
    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$PROJECT_NAME:$IMAGE_TAG$"; then
        print_message $RED "❌ 错误: 本地镜像 $PROJECT_NAME:$IMAGE_TAG 不存在"
        print_message $YELLOW "💡 请先运行 build 命令构建镜像"
        exit 1
    fi
    
    # 检查 Registry 登录状态
    if [ -n "$REGISTRY" ] && [ "$REGISTRY" != "docker.io" ]; then
        check_registry_login "$REGISTRY"
    fi
    
    # 标记镜像
    print_message $YELLOW "🏷️  标记镜像: $FULL_IMAGE"
    docker tag "$PROJECT_NAME:$IMAGE_TAG" "$FULL_IMAGE"
    
    # 推送镜像
    print_message $YELLOW "📤 推送镜像..."
    docker push "$FULL_IMAGE"
    
    # 清理本地标记（可选，保留本地构建的原始镜像）
    print_message $YELLOW "🧹 清理本地标记..."
    docker rmi "$FULL_IMAGE"
    
    print_message $GREEN "✅ 镜像推送完成: $FULL_IMAGE"
}

# 帮助信息
show_help() {
    echo "项目 Docker 镜像管理脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  clean           清理 Docker 容器"
    echo "  clean --images  清理 Docker 容器和镜像"
    echo "  build           构建 Docker 镜像（默认环境，使用 Dockerfile）"
    echo "  build:prod      构建生产环境镜像（使用 prod.Dockerfile）"
    echo "  build:test      构建测试环境镜像（使用 test.Dockerfile）"
    echo "  build:dev       构建开发环境镜像（使用 local.Dockerfile）"
    echo "  build:amd64     构建 amd64 平台镜像（默认环境，用于跨平台部署）"
    echo "  run             运行 Docker 容器（默认环境）"
    echo "  run:prod        运行生产环境容器"
    echo "  run:test        运行测试环境容器"
    echo "  run:dev         运行开发环境容器"
    echo "  push            推送镜像到仓库"
    echo "  deploy          完整部署流程（默认环境：清理 -> 构建amd64 -> 推送）"
    echo "  deploy:prod     完整部署流程（生产环境）"
    echo "  deploy:test     完整部署流程（测试环境）"
    echo "  help            显示此帮助信息"
    echo ""
    echo "当前配置:"
    echo "  项目名称: $PROJECT_NAME"
    echo "  镜像标签: $IMAGE_TAG (基于 Git 分支)"
    echo "  完整镜像: $FULL_IMAGE"
    echo "  Dockerfile: [prod.Dockerfile, test.Dockerfile, local.Dockerfile, Dockerfile]"
}

# -----------------------------------------------------------------------------
# 主逻辑
# -----------------------------------------------------------------------------

# 检查是否有参数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

command=$1
shift # 移除第一个参数，以便后续处理参数

case $command in
    "clean")
        if [ "$1" = "--images" ]; then
            clean_docker "true"
        else
            clean_docker "false"
        fi
        ;;
    
    "build")
        check_command docker
        show_system_info
        build_docker_image "default"
        ;;
        
    "build:prod")
        check_command docker
        show_system_info
        build_docker_image "production"
        ;;
        
    "build:dev")
        check_command docker
        show_system_info
        build_docker_image "development"
        ;;

    "build:test")
        check_command docker
        show_system_info
        build_docker_image "test"
        ;;

    "build:amd64")
        check_command docker
        show_system_info
        build_docker_image "default" "amd64"
        ;;
        
    "run")
        check_command docker
        run_docker_container "default"
        ;;
        
    "run:prod")
        check_command docker
        run_docker_container "production"
        ;;

    "run:dev")
        check_command docker
        run_docker_container "development"
        ;;

    "run:test")
        check_command docker
        run_docker_container "test"
        ;;
        
    "push")
        check_command docker
        show_system_info
        push_to_registry
        ;;
        
    "deploy" | "deploy:prod")
        show_system_info
        check_command docker
        clean_docker "false"
        # 默认部署生产环境，且通常部署到服务器需要 amd64 架构
        build_docker_image "production" "amd64"
        push_to_registry
        print_message $GREEN "🎉 生产环境部署完成！"
        ;;

    "deploy:test")
        show_system_info
        check_command docker
        clean_docker "false"
        build_docker_image "test" "amd64"
        push_to_registry
        print_message $GREEN "🎉 测试环境部署完成！"
        ;;
        
    "help" | "--help" | "-h")
        show_help
        ;;
        
    *)
        print_message $RED "❌ 未知命令: $command"
        show_help
        exit 1
        ;;
esac