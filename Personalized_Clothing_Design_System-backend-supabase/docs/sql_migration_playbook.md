# SQL 迁移与版本迭代手册（生产级）

## 1. SQL 放置位置

- 所有版本增量 SQL 统一放在 `supabase/migrations/`
- 每次迭代新增一个迁移文件，不修改历史迁移文件
- 文件命名使用时间戳前缀：`YYYYMMDDHHmmss_<feature>.sql`
- 示例：`20260312153000_add_devices_table.sql`

## 2. 迁移文件编写原则

- 仅做增量变更，不覆盖式重建已有对象
- 语句必须可重复执行安全（优先使用 `if exists` / `if not exists`）
- DDL 与权限策略同迁移提交（表结构 + RLS + 索引 + 必要触发器）
- 高风险变更分阶段发布：先“兼容变更”，后“清理变更”
- 禁止在生产流程使用 `db reset`

## 3. 新增表的标准流程

1. 设计阶段
   - 明确主键、外键、唯一约束、索引策略
   - 明确 RLS 访问模型（谁可读/可写）
2. 实现阶段
   - 在 `supabase/migrations/` 新增 SQL 迁移文件
   - 同步更新 `types/supabase/database.ts` 类型定义
   - 新增或更新相关测试用例，遵循先测后实现（TDD，适用于所有业务模块）
3. 本地验证
   - `supabase db reset`
   - 运行改动范围测试（当前最小基线：`deno test supabase/functions/auth-api`）
   - 运行改动范围类型检查（当前最小基线：`deno check supabase/functions/auth-api/*.ts`）
4. Preview 验证
   - 通过 `.gitea/workflows/supabase-preview.yml` 自动执行：
   - 测试 -> `sync-branch` -> `db-push` -> `deploy-functions-all`
5. Production 发布
   - 通过 `.gitea/workflows/supabase-production.yml` 执行：
   - 测试 -> `db-push` -> `deploy-functions-all`
   - `release/**` tag 发布必须通过“提交属于 main”校验

## 4. 回滚与应急策略

- 优先采用前滚修复（新增迁移修正），避免直接修改已执行迁移
- 对破坏性变更先做数据备份，再执行变更
- 删除列/重命名列采用两阶段策略：
  - 阶段 A：新增兼容列/视图与双写
  - 阶段 B：确认应用完全切换后再删除旧结构

## 5. 每次发布前检查清单

- 已新增迁移文件且命名符合规范
- 已补齐 RLS 策略与必要索引
- 已更新 `types/supabase/database.ts`
- 已更新相关文档（`docs/db_schema.md`、`docs/api_endpoints.md`）
- 本地测试与类型检查通过
- 仅通过 CI 执行生产迁移，生产禁用 `db reset`
