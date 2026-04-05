# Personalized_Clothing_Design_System-backend 数据库设计（生产版）

## 范围

当前后端只保留用户域核心模型：

- `public.profiles`

说明：当前仅列出已落地模型；后续新增业务表必须遵循本文件中的统一安全基线，不得仅按 `profiles` 特例处理。

## 表结构

### profiles

- `id uuid`：主键，关联 `auth.users.id`
- `full_name text`：用户昵称
- `avatar_url text`：头像地址
- `created_at timestamptz`：创建时间
- `updated_at timestamptz`：更新时间

## 自动化机制

- `on_auth_user_created`：用户注册后自动创建 profiles 记录
- `on_profiles_updated`：更新 profile 时自动刷新 `updated_at`

## RLS 策略

- 启用 RLS：`ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY`
- 查询：仅允许 `auth.uid() = id`
- 更新：仅允许 `auth.uid() = id`
- 插入：仅允许 `auth.uid() = id`

## 全业务安全基线

- 新增业务表必须同批提交 RLS 策略与必要索引，默认最小权限拒绝
- 涉及用户主数据初始化的逻辑优先放在数据库触发器或受控函数中，保证可审计
- 迁移发布仅通过新增迁移文件执行，禁止修改历史迁移；生产仅允许 CI 执行 `db-push`
- 生产环境保持 `ENABLE_DB_RESET=0`，禁止使用 `db reset`

## 迁移文件

- 迁移目录：`supabase/migrations/`
- 当前初始化迁移：`supabase/migrations/202603110001_init.sql`
- 后续版本新增 SQL 必须以新迁移文件提交，不修改历史迁移
- 详细流程与发布策略见 [sql_migration_playbook.md](sql_migration_playbook.md)
