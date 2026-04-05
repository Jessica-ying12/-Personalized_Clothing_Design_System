## 变更摘要

- 本次迭代目标：
- 涉及模块：
- 风险等级（低/中/高）：

## SQL 迁移清单（如有数据库变更必须逐项勾选）

- [ ] 已在 `supabase/migrations/` 新增迁移文件（未修改历史迁移）
- [ ] 迁移文件命名符合：`YYYYMMDDHHmmss_<feature>.sql`
- [ ] 新增/变更表已包含必要索引、约束与外键
- [ ] 已补齐或确认 RLS 策略（读/写权限边界清晰）
- [ ] 若有破坏性变更，已采用分阶段兼容方案（前滚优先）
- [ ] 已同步更新类型定义：`types/supabase/database.ts`
- [ ] 已同步更新文档：`docs/db_schema.md`（如结构有变化）

## TDD 与验证清单（必须）

- [ ] 已先写失败测试，再实现功能（TDD）
- [ ] 已执行并通过改动范围内测试（当前最小基线：`deno test supabase/functions/auth-api`）
- [ ] 已执行并通过改动范围内类型检查（当前最小基线：`deno check supabase/functions/auth-api/*.ts`）
- [ ] 已验证关键接口（列出接口与结果）

## 发布与回滚清单（生产相关）

- [ ] 已确认生产禁用 `db reset`（`ENABLE_DB_RESET=0`）
- [ ] 已确认通过 CI 执行迁移与部署（不手工直推生产）
- [ ] 已准备回滚/前滚方案（写明操作步骤）

## 验证证据

- 测试输出：
- 类型检查输出：
- 关键日志或截图：

## 关联文档

- SQL 迁移手册：`docs/sql_migration_playbook.md`
- 数据库设计：`docs/db_schema.md`
- API 文档：`docs/api_endpoints.md`
