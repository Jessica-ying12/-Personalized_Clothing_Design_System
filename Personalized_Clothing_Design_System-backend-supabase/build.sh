#!/usr/bin/env bash
set -euo pipefail

# 读取构建配置（默认 .build.env，可通过 BUILD_ENV_FILE 覆盖）
if [[ -f "${BUILD_ENV_FILE:-.build.env}" ]]; then
  source "${BUILD_ENV_FILE:-.build.env}"
fi

# 命令行参数：第一个参数通常是 project_ref，第二个参数是 action
ARG1="${1:-}"
ARG2="${2:-}"
ARG3="${3:-}"
EXTRA_ARGS=("${@:4}")

# 目标项目：优先使用环境变量 SUPABASE_PROJECT_REF，再使用命令行参数
PROJECT_REF="${SUPABASE_PROJECT_REF:-}"
ACTION=""

# 能力开关：1/true 表示开启；0/false 表示关闭
ENABLE_SUPABASE_LINK="${ENABLE_SUPABASE_LINK:-1}"
ENABLE_DB_PUSH="${ENABLE_DB_PUSH:-1}"
ENABLE_DB_RESET="${ENABLE_DB_RESET:-1}"
ENABLE_DEPLOY_FUNCTION="${ENABLE_DEPLOY_FUNCTION:-1}"
ENABLE_DEPLOY_ALL_FUNCTIONS="${ENABLE_DEPLOY_ALL_FUNCTIONS:-1}"
ENABLE_TEST_FUNCTION="${ENABLE_TEST_FUNCTION:-1}"
ENABLE_SYNC_BRANCH="${ENABLE_SYNC_BRANCH:-1}"
FUNCTION_ALLOWLIST="${FUNCTION_ALLOWLIST:-}"

# 简版用法提示（参数错误时显示）
print_usage() {
  echo "用法: ./build.sh <project_ref> <action> [function_name|function_list|all|changed]"
  echo "action: db-push | db-reset | deploy-function | deploy-functions-all | test-function | test-functions | verify-migrations | verify-functions | sync-branch | print-config"
  echo "更多说明: ./build.sh --help"
}

# 完整帮助信息（--help/-h/help）
print_help() {
  cat <<'EOF'
Personalized_Clothing_Design_System-backend Build Script

基础用法:
  ./build.sh <project_ref> <action> [function_name|function_list|all|changed]

可用 action:
  db-push               推送数据库迁移
  db-reset              重置数据库
  deploy-function       部署单个函数（需 function_name）
  deploy-functions-all  部署所有函数目录
  test-function         运行单个函数测试（需 function_name）
  test-functions        批量运行函数测试（需 function_list、all 或 changed；changed 支持 --base-ref/--head-ref/--no-fallback，仅传 --base-ref 时 --head-ref 默认 HEAD）
  verify-migrations     校验远端迁移状态（只读）
  verify-functions      查看远端函数状态（只读）
  sync-branch           自动创建/更新 Supabase Preview Branch 并 link（支持 ./build.sh auto sync-branch）
  print-config          打印当前能力开关配置

快速开始:
  cp .build.env.example .build.env
  ./build.sh <project_ref> print-config
  ./build.sh <project_ref> db-push
  ./build.sh <project_ref> deploy-function auth-api
  ./build.sh <project_ref> deploy-functions-all
  ./build.sh <project_ref> test-function auth-api
  ./build.sh <project_ref> test-functions auth-api,profile-api
  ./build.sh <project_ref> test-functions all
  ./build.sh <project_ref> test-functions changed
  ./build.sh <project_ref> test-functions changed --base-ref origin/main
  ./build.sh <project_ref> test-functions changed --base-ref origin/main --head-ref HEAD
  ./build.sh <project_ref> test-functions changed --base-ref origin/main --no-fallback
  ./build.sh <project_ref> verify-migrations
  ./build.sh <project_ref> verify-functions
  ./build.sh auto sync-branch

能力开关（在 .build.env 配置）:
  ENABLE_SUPABASE_LINK
    - 作用: 控制是否执行 supabase link --project-ref
    - 建议: 常开。关闭后脚本不会自动切换目标项目

  ENABLE_DB_PUSH
    - 作用: 控制 db-push 动作（推送迁移到目标项目）
    - 风险: 会修改远程数据库结构

  ENABLE_DB_RESET
    - 作用: 控制 db-reset 动作（重置数据库并重跑迁移）
    - 风险: 可能清空现有数据，生产建议关闭（设置为 0）

  ENABLE_DEPLOY_FUNCTION
    - 作用: 控制 deploy-function 动作（部署单个函数）
    - 风险: 会覆盖线上函数版本

  ENABLE_DEPLOY_ALL_FUNCTIONS
    - 作用: 控制 deploy-functions-all 动作（批量部署函数）
    - 风险: 会批量覆盖线上函数版本

  ENABLE_TEST_FUNCTION
    - 作用: 控制 test-function 动作（运行单个函数测试）
    - 建议: 常开，保证 TDD 流程可执行

  ENABLE_SYNC_BRANCH
    - 作用: 控制 sync-branch 动作
    - 建议: 开启后可将当前 Git 分支自动映射为 Supabase Preview Branch
    - 前提: Supabase 项目需开通 Branching（Pro 及以上）

  FUNCTION_ALLOWLIST
    - 作用: 限制可部署/可测试函数白名单（逗号分隔）
    - 示例: FUNCTION_ALLOWLIST=auth-api,profile-api

  SUPABASE_PROJECT_REF
    - 作用: 默认目标项目 Ref（ARG1=auto 时用于 sync-branch）
    - 示例: SUPABASE_PROJECT_REF=ignoyhpjkppcjrcslxpz

说明:
  本脚本不内置生产项目 Ref
  生产限制建议通过 build-prod.sh + 关闭 ENABLE_DB_RESET 实现
  可复制 build.sh 为 build-prod.sh，按需关闭能力开关
EOF
}

# 统一解析开关值，兼容 1/true/TRUE
is_enabled() {
  [[ "${1}" == "1" || "${1}" == "true" || "${1}" == "TRUE" ]]
}

# 执行动作前检查能力开关
require_capability() {
  if ! is_enabled "$1"; then
    echo "❌ 能力已关闭: $2"
    exit 1
  fi
}

function_in_allowlist() {
  local function_name="$1"
  if [[ -z "$FUNCTION_ALLOWLIST" ]]; then
    return 0
  fi

  local normalized_list=",${FUNCTION_ALLOWLIST// /},"
  local needle=",${function_name},"
  [[ "$normalized_list" == *"$needle"* ]]
}

require_function_allowed() {
  local function_name="$1"
  if ! function_in_allowlist "$function_name"; then
    echo "❌ function 不在白名单中: $function_name"
    echo "当前 FUNCTION_ALLOWLIST=$FUNCTION_ALLOWLIST"
    exit 1
  fi
}

require_function_name() {
  local function_name="$1"
  if [[ -z "$function_name" ]]; then
    echo "❌ 缺少 function_name"
    echo "示例: ./build.sh <project_ref> deploy-function auth-api"
    exit 1
  fi
}

deploy_one_function() {
  local function_name="$1"
  require_function_name "$function_name"
  require_function_allowed "$function_name"
  require_capability "$ENABLE_DEPLOY_FUNCTION" "deploy-function"
  supabase functions deploy "$function_name" --no-verify-jwt
}

test_one_function() {
  local function_name="$1"
  require_function_name "$function_name"
  require_function_allowed "$function_name"
  require_capability "$ENABLE_TEST_FUNCTION" "test-function"
  deno test "supabase/functions/${function_name}"
}

list_all_functions() {
  local has_any=0
  for function_dir in supabase/functions/*; do
    if [[ -d "$function_dir" ]]; then
      basename "$function_dir"
      has_any=1
    fi
  done
  if [[ "$has_any" -eq 0 ]]; then
    echo "❌ 未找到函数目录: supabase/functions/*"
    exit 1
  fi
}

test_multiple_functions() {
  local function_list="$1"
  shift || true
  if [[ -z "$function_list" ]]; then
    echo "❌ 缺少 function_list"
    echo "示例: ./build.sh <project_ref> test-functions auth-api,profile-api"
    echo "或使用: ./build.sh <project_ref> test-functions all|changed"
    exit 1
  fi

  require_capability "$ENABLE_TEST_FUNCTION" "test-function"

  if [[ "$function_list" == "changed" ]]; then
    local base_ref_cli=""
    local head_ref_cli=""
    local no_fallback="0"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --base-ref)
          if [[ $# -lt 2 || -z "$2" ]]; then
            echo "❌ --base-ref 缺少值"
            exit 1
          fi
          base_ref_cli="$2"
          shift 2
          ;;
        --head-ref)
          if [[ $# -lt 2 || -z "$2" ]]; then
            echo "❌ --head-ref 缺少值"
            exit 1
          fi
          head_ref_cli="$2"
          shift 2
          ;;
        --no-fallback)
          no_fallback="1"
          shift
          ;;
        *)
          echo "❌ 不支持的参数: $1"
          echo "支持参数: --base-ref <ref> --head-ref <ref> --no-fallback"
          exit 1
          ;;
      esac
    done
    local base_ref="${base_ref_cli:-${BUILD_DIFF_BASE_REF:-}}"
    local head_ref="${head_ref_cli:-${BUILD_DIFF_HEAD_REF:-${GITHUB_SHA:-HEAD}}}"
    if [[ -n "$base_ref_cli" && -z "$head_ref_cli" ]]; then
      head_ref="HEAD"
    fi
    local changed_functions=""
    local zero_sha="0000000000000000000000000000000000000000"
    git fetch origin --prune >/dev/null 2>&1 || true
    if [[ -z "$base_ref" ]]; then
      if [[ "${GITHUB_EVENT_NAME:-}" == "pull_request" && -n "${GITHUB_BASE_REF:-}" ]]; then
        base_ref="origin/${GITHUB_BASE_REF}"
        git fetch origin "${GITHUB_BASE_REF}" --depth=1 >/dev/null 2>&1 || true
      elif [[ -n "${GITHUB_EVENT_BEFORE:-}" && "${GITHUB_EVENT_BEFORE}" != "$zero_sha" ]]; then
        base_ref="${GITHUB_EVENT_BEFORE}"
      elif git rev-parse HEAD~1 >/dev/null 2>&1; then
        base_ref="HEAD~1"
        head_ref="${BUILD_DIFF_HEAD_REF:-HEAD}"
      fi
    fi
    if [[ -n "$base_ref" ]]; then
      echo "changed 模式 diff 范围: ${base_ref}..${head_ref}"
      changed_functions="$(git diff --name-only "$base_ref" "$head_ref" 2>/dev/null | awk -F/ '/^supabase\/functions\/[^/]+\//{print $3}' | sort -u)"
    fi
    if [[ -n "$changed_functions" ]]; then
      local filtered_functions=()
      while IFS= read -r function_name; do
        [[ -z "$function_name" ]] && continue
        if [[ -d "supabase/functions/${function_name}" ]]; then
          filtered_functions+=("$function_name")
        fi
      done <<< "$changed_functions"
      if [[ "${#filtered_functions[@]}" -gt 0 ]]; then
        function_list="$(IFS=,; echo "${filtered_functions[*]}")"
        echo "检测到改动函数: $function_list"
      fi
    fi
    if [[ "$function_list" == "changed" ]]; then
      if [[ "$no_fallback" == "1" ]]; then
        echo "❌ 未识别到可测试的改动函数，且已启用 --no-fallback"
        exit 1
      fi
      function_list="auth-api"
      echo "未识别到可测试的改动函数，回退最小基线: auth-api"
    fi
  fi

  if [[ $# -gt 0 ]]; then
    echo "❌ test-functions ${function_list} 不支持额外参数: $*"
    exit 1
  fi

  if [[ "$function_list" == "all" ]]; then
    while IFS= read -r function_name; do
      [[ -z "$function_name" ]] && continue
      test_one_function "$function_name"
    done < <(list_all_functions)
    return
  fi

  local normalized_list
  normalized_list="${function_list// /}"
  IFS=',' read -r -a functions <<< "$normalized_list"
  if [[ "${#functions[@]}" -eq 0 ]]; then
    echo "❌ function_list 为空"
    exit 1
  fi

  for function_name in "${functions[@]}"; do
    [[ -z "$function_name" ]] && continue
    test_one_function "$function_name"
  done
}

sync_branch() {
  require_capability "$ENABLE_SYNC_BRANCH" "sync-branch"

  local main_project_ref="$PROJECT_REF"
  if [[ -z "$main_project_ref" ]]; then
    echo "❌ 缺少主项目 Ref"
    echo "请传入: ./build.sh <main_project_ref> sync-branch"
    echo "或设置: SUPABASE_PROJECT_REF"
    exit 1
  fi

  local git_branch
  git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -z "$git_branch" || "$git_branch" == "HEAD" ]]; then
    echo "❌ 无法获取当前 Git 分支（可能处于 detached HEAD）"
    exit 1
  fi

  local preview_branch_name
  preview_branch_name="${SUPABASE_BRANCH_NAME:-${git_branch//\//-}}"

  local create_output
  set +e
  create_output="$(supabase branches create "$preview_branch_name" --project-ref "$main_project_ref" 2>&1)"
  create_status=$?
  set -e
  if [[ $create_status -ne 0 ]]; then
    if [[ "$create_output" == *"supported only on the Pro plan"* ]]; then
      echo "❌ 当前项目未开通 Supabase Branching（需 Pro 及以上）"
      echo "请升级套餐后重试: ./build.sh auto sync-branch"
      exit 1
    fi
    if [[ "$create_output" != *"already exists"* ]]; then
      echo "$create_output"
      exit $create_status
    fi
  fi

  supabase branches update "$preview_branch_name" \
    --git-branch "$git_branch" \
    --project-ref "$main_project_ref" >/dev/null

  local branch_json
  branch_json="$(supabase branches get "$preview_branch_name" --project-ref "$main_project_ref" -o json)"

  local preview_project_ref
  preview_project_ref="$(printf '%s' "$branch_json" | python3 -c 'import json,sys
d=json.load(sys.stdin)
keys=("project_ref","ref","id")
def pick(obj):
    if isinstance(obj, dict):
        for k in keys:
            v=obj.get(k)
            if isinstance(v,str) and v:
                return v
    return ""
if isinstance(d, dict):
    v=pick(d) or pick(d.get("data", {}))
    if not v and isinstance(d.get("data"), list):
        for item in d["data"]:
            v=pick(item)
            if v:
                break
    print(v)
elif isinstance(d, list):
    out=""
    for item in d:
        out=pick(item)
        if out:
            break
    print(out)
else:
    print("")')"

  if [[ -z "$preview_project_ref" ]]; then
    echo "❌ 无法从 branches get 输出中解析 preview project ref"
    echo "$branch_json"
    exit 1
  fi

  require_capability "$ENABLE_SUPABASE_LINK" "supabase link"
  supabase link --project-ref "$preview_project_ref" >/dev/null

  echo "SYNCED_GIT_BRANCH=$git_branch"
  echo "SYNCED_SUPABASE_BRANCH=$preview_branch_name"
  echo "SYNCED_PROJECT_REF=$preview_project_ref"
}

if [[ "$ARG1" == "-h" || "$ARG1" == "--help" || "$ARG1" == "help" ]]; then
  print_help
  exit 0
fi

if [[ "$ARG1" == "print-config" ]]; then
  ACTION="print-config"
else
  PROJECT_REF="${SUPABASE_PROJECT_REF:-$ARG1}"
  ACTION="$ARG2"
fi

if [[ "$ACTION" == "sync-branch" && "$ARG1" == "auto" ]]; then
  PROJECT_REF="${SUPABASE_PROJECT_REF:-}"
fi

if [[ -z "$ACTION" ]]; then
  print_usage
  exit 1
fi

# 支持 ./build.sh print-config（无需 project_ref）
if [[ "$ACTION" == "print-config" ]]; then
  echo "SUPABASE_PROJECT_REF=${SUPABASE_PROJECT_REF:-}"
  echo "ENABLE_SUPABASE_LINK=$ENABLE_SUPABASE_LINK"
  echo "ENABLE_DB_PUSH=$ENABLE_DB_PUSH"
  echo "ENABLE_DB_RESET=$ENABLE_DB_RESET"
  echo "ENABLE_DEPLOY_FUNCTION=$ENABLE_DEPLOY_FUNCTION"
  echo "ENABLE_DEPLOY_ALL_FUNCTIONS=$ENABLE_DEPLOY_ALL_FUNCTIONS"
  echo "ENABLE_TEST_FUNCTION=$ENABLE_TEST_FUNCTION"
  echo "ENABLE_SYNC_BRANCH=$ENABLE_SYNC_BRANCH"
  echo "FUNCTION_ALLOWLIST=$FUNCTION_ALLOWLIST"
  exit 0
fi

if [[ -z "$PROJECT_REF" ]]; then
  if [[ "$ACTION" == "sync-branch" ]]; then
    echo "❌ sync-branch 缺少主项目 Ref"
    echo "可使用: ./build.sh <main_project_ref> sync-branch"
    echo "或使用: SUPABASE_PROJECT_REF=<main_project_ref> ./build.sh auto sync-branch"
    exit 1
  fi
  print_usage
  exit 1
fi

if [[ "$ACTION" == "deploy-function" || "$ACTION" == "test-function" ]]; then
  require_function_name "$ARG3"
  require_function_allowed "$ARG3"
fi

# 根据开关决定是否执行 supabase link
if [[ "$ACTION" != "sync-branch" ]]; then
  require_capability "$ENABLE_SUPABASE_LINK" "supabase link"
  supabase link --project-ref "$PROJECT_REF" >/dev/null
fi

# 执行具体动作
case "$ACTION" in
  db-push)
    require_capability "$ENABLE_DB_PUSH" "db-push"
    supabase db push
    ;;
  db-reset)
    require_capability "$ENABLE_DB_RESET" "db-reset"
    supabase db reset
    ;;
  deploy-function)
    deploy_one_function "$ARG3"
    ;;
  deploy-functions-all)
    require_capability "$ENABLE_DEPLOY_ALL_FUNCTIONS" "deploy-functions-all"
    for function_dir in supabase/functions/*; do
      if [[ -d "$function_dir" ]]; then
        function_name="$(basename "$function_dir")"
        deploy_one_function "$function_name"
      fi
    done
    ;;
  test-function)
    test_one_function "$ARG3"
    ;;
  test-functions)
    test_multiple_functions "$ARG3" "${EXTRA_ARGS[@]}"
    ;;
  verify-migrations)
    supabase migration list
    ;;
  verify-functions)
    supabase functions list
    ;;
  sync-branch)
    sync_branch
    ;;
  *)
    print_usage
    exit 1
    ;;
esac
