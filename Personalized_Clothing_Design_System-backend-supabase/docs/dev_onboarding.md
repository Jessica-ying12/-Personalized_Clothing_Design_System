# 开发环境准备与接手指南（新手/AI 智能体）

## 1. 必装工具

- Git（版本管理与分支协作）
- Supabase CLI（本地调试、迁移、部署）
- Deno（Edge Functions 运行与测试）
- Node.js（可选，部分编辑器/工具链依赖）

## 2. 推荐版本基线

- Git: `>= 2.40`
- Supabase CLI: 最新稳定版
- Deno: `>= 2.7`
- Node.js: `>= 20`（可选）

## 3. macOS（Homebrew）安装命令

```bash
brew install git
brew install supabase/tap/supabase
brew install deno
brew install node
```

## 4. 安装后自检命令

```bash
git --version
supabase --version
deno --version
node --version
```

## 5. 首次接手项目标准流程

1. 克隆仓库并进入目录
2. 准备配置文件：`cp .env.example .env`、`cp .build.env.example .build.env`
3. 启动本地 Supabase：`supabase start`
4. 重建并应用迁移：`supabase db reset`
5. 运行改动范围测试（当前最小基线：`deno test supabase/functions/auth-api`）
6. 运行改动范围类型检查（当前最小基线：`deno check supabase/functions/auth-api/*.ts`）
7. 本地调试函数：`supabase functions serve auth-api --env-file .env.example`

## 6. AI 智能体接手强制约束

- 先阅读：`README.md`、`docs/sql_migration_playbook.md`、`.gitea/PULL_REQUEST_TEMPLATE.md`
- 必须遵循 TDD：先写失败测试，再实现，再跑全绿
- TDD 适用于所有业务模块，不限于认证逻辑
- 涉及 SQL 变更时，迁移文件仅允许新增到 `supabase/migrations/`
- 不允许修改历史迁移文件，不允许在生产使用 `db reset`
- 提交前必须执行改动范围内测试与类型检查（当前最小基线）：
  - `deno test supabase/functions/auth-api`
  - `deno check supabase/functions/auth-api/*.ts`

## 7. 常见故障与处理

- `deno: command not found`：重新执行 `brew install deno` 并重开终端
- `supabase: command not found`：确认已执行 `brew install supabase/tap/supabase`
- `Missing SUPABASE_URL or SUPABASE_ANON_KEY`：检查 `.env` 与运行环境变量
- `db reset` 风险提醒：该命令会重建数据库，仅用于本地开发环境
