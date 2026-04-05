# Personalized_Clothing_Design_System-backend

Personalized_Clothing_Design_System-backend App 生产后端仓库，采用 Supabase 最佳实践：Auth + RLS + Edge Functions + SQL Migration。

## 项目结构

```text
Personalized_Clothing_Design_System-backend-supabase-backend-supabase/
├── .gitea/
│   ├── workflows/
│   │   ├── supabase-preview.yml
│   │   └── supabase-production.yml
│   └── PULL_REQUEST_TEMPLATE.md
├── supabase/
│   ├── config.toml
│   ├── functions/
│   │   └── auth-api/
│   │       ├── handler.ts
│   │       ├── handler.test.ts
│   │       └── index.ts
│   ├── migrations/
│   │   └── 202603110001_init.sql
├── types/
│   └── supabase/
│       ├── database.ts
│       ├── index.ts
│       └── json.ts
├── docs/
│   ├── db_schema.md
│   ├── api_endpoints.md
│   ├── dev_onboarding.md
│   ├── sql_migration_playbook.md
│   └── skills/ (IDE skill 元数据，非业务后端代码)
├── .build.env.example
├── .env.example
├── build.sh
├── config.toml
└── README.md
```

## 本地开发

开始开发前请先完成环境准备与接手检查：

- [docs/dev_onboarding.md](docs/dev_onboarding.md)

1. 安装 Git、Supabase CLI、Deno（可选 Node.js）
2. 启动本地 Supabase：

```bash
supabase start
```

3. 应用迁移：

```bash
supabase db reset
```

4. 本地调试函数：

```bash
supabase functions serve auth-api --env-file .env.example
```

说明：`serve` 当前使用 Supabase 原生命令，`build.sh` 主要封装迁移、部署与测试流程。

5. 运行改动范围测试（当前最小基线）：

```bash
deno test supabase/functions/auth-api
```

## 生产部署

推荐使用脚本（统一能力开关与发布流程）：

```bash
./build.sh <project_ref> db-push
```

部署认证函数（推荐）：

```bash
./build.sh <project_ref> deploy-function auth-api
```

等价原生命令（用于理解底层动作）：

```bash
supabase link --project-ref <project_ref>
supabase db push
supabase functions deploy auth-api --no-verify-jwt
```

## SQL 迁移最佳实践

- 新增 SQL 一律放在 `supabase/migrations/`，禁止散落在其它目录
- 每个版本通过新增迁移文件迭代，禁止修改已执行历史迁移
- 新表上线必须同批提交：表结构、索引、RLS 策略、必要触发器、类型定义更新
- 本地先验证：`supabase db reset` + 改动范围内测试 + 类型检查（当前最小基线：`deno test supabase/functions/auth-api` 与 `deno check supabase/functions/auth-api/*.ts`）
- 生产只允许通过 CI 执行 `db-push`，并保持 `ENABLE_DB_RESET=0`
- 提 PR 时使用 `.gitea/PULL_REQUEST_TEMPLATE.md` 勾选 SQL/TDD/发布清单
- 详细流程见 [docs/sql_migration_playbook.md](docs/sql_migration_playbook.md)

## Gitea CI（Preview Branch）

工作流文件：

- `.gitea/workflows/supabase-preview.yml`

需要在 Gitea 仓库配置以下 Secrets：

- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`（主项目 Ref）
- `SUPABASE_DB_PASSWORD`

工作流执行顺序：

1. 运行改动函数测试（TDD；若未识别到函数改动则回退到 `auth-api` 最小基线）
2. `./build.sh auto sync-branch`
3. 对 Preview 分支执行 `db-push`
4. 对 Preview 分支执行 `deploy-functions-all`

## Gitea CI（Production）

工作流文件：

- `.gitea/workflows/supabase-production.yml`

触发条件：

- 手动触发 `workflow_dispatch`（默认发布 `main`）
- push tag：`release/**`

需要在 Gitea 仓库配置以下 Secrets：

- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF_PROD`
- `SUPABASE_DB_PASSWORD_PROD`

工作流执行顺序：

1. 运行全量函数测试（TDD，覆盖 `supabase/functions/*`）
2. 对生产项目执行 `db-push`
3. 对生产项目执行 `deploy-functions-all`

手动触发时可指定 `release_ref`（分支名、tag 或 commit sha）。

安全约束：

- `ENABLE_DB_RESET=0`
- `ENABLE_SYNC_BRANCH=0`
- `release/**` tag 发布时，CI 会校验 tag 对应提交必须属于 `main`

## 构建脚本

主脚本：`build.sh`

```bash
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
./build.sh <project_ref> print-config
```

`sync-branch` 依赖 Supabase Branching 能力（Pro 及以上）。

脚本支持能力开关，读取 `.build.env`（若存在）：

```bash
cp .build.env.example .build.env
```

可开关能力：

- `ENABLE_SUPABASE_LINK`
- `ENABLE_DB_PUSH`
- `ENABLE_DB_RESET`
- `ENABLE_DEPLOY_FUNCTION`
- `ENABLE_DEPLOY_ALL_FUNCTIONS`
- `ENABLE_TEST_FUNCTION`
- `ENABLE_SYNC_BRANCH`
- `FUNCTION_ALLOWLIST`
- `SUPABASE_PROJECT_REF`

开关说明：

- `ENABLE_SUPABASE_LINK`：是否执行 `supabase link`，关闭后不会自动切换目标项目
- `ENABLE_DB_PUSH`：是否允许 `db-push`，开启后可推送迁移到远程数据库
- `ENABLE_DB_RESET`：是否允许 `db-reset`，有清空数据风险，生产建议设为 `0`
- `ENABLE_DEPLOY_FUNCTION`：是否允许部署单个函数
- `ENABLE_DEPLOY_ALL_FUNCTIONS`：是否允许批量部署所有函数
- `ENABLE_TEST_FUNCTION`：是否允许运行单个函数测试，建议保持开启以符合 TDD
- `ENABLE_SYNC_BRANCH`：是否允许 `sync-branch` 动作
- `FUNCTION_ALLOWLIST`：函数白名单（逗号分隔），限制可部署/可测试函数
- `SUPABASE_PROJECT_REF`：默认目标项目 Ref，`./build.sh auto sync-branch` 会使用它作为主项目 Ref

建议生产脚本默认关闭 `ENABLE_DB_RESET`，避免误执行重置。

可复制脚本生成生产版：

```bash
cp build.sh build-prod.sh
chmod +x build-prod.sh
```

然后在生产脚本使用的 `.build.env` 中设置：

```bash
ENABLE_DB_RESET=0
```

## Pro 升级后操作

```bash
export SUPABASE_PROJECT_REF=<main_project_ref>
./build.sh auto sync-branch
./build.sh <project_ref> db-push
./build.sh <project_ref> deploy-functions-all
```

## 安全策略

- 当前 `profiles` 已启用 RLS（`auth.uid() = id`），后续所有新增业务表必须同批交付 RLS 策略，默认最小权限拒绝
- 注册后通过数据库触发器自动创建 `profiles` 记录，后续涉及用户主数据初始化的逻辑需继续采用数据库侧可审计机制
- 不仅 `auth-api`：所有 Edge Functions 都必须执行身份校验、租户/用户权限校验与统一错误返回，禁止绕过鉴权直接访问业务数据
- 所有数据库变更必须通过迁移文件发布，禁止修改历史迁移；生产仅允许 CI 执行 `db-push`，并保持 `ENABLE_DB_RESET=0`
- 生产密钥仅存放于 CI/平台 Secrets，不写入仓库；本地仅使用 `.env.example`/`.build.env` 模板，不提交真实凭据

## TDD 规范

- 必须遵循“先测试后实现”：先写失败测试，再实现，再跑到全绿后提交
- 本规范适用于所有业务模块，不限于认证逻辑
- 所有新增或变更的接口、函数、SQL 逻辑都必须补充对应测试用例
- 每次改动必须至少执行“改动范围内”的测试与类型检查，确保全绿后再提交
- 当前仓库提交前最小基线为：`deno test supabase/functions/auth-api`
- 建议提交前追加执行：`deno check supabase/functions/auth-api/*.ts`
