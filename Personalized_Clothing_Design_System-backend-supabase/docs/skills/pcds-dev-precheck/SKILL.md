---
name: pcds-dev-precheck
description: Personalized_Clothing_Design_System-backend 开发后预检查技能。用户一旦提到“自检”“发布前检查”“提测前检查”“PR 检查清单”“帮我验证改动”，必须调用本技能，按项目命令与清单做完整预检查并输出结论。
---

# Personalized_Clothing_Design_System-backend 开发后预检查技能

用于在开发完成后执行统一的预检查流程，确保改动可提交、可发布、可审计。

## 触发场景

- 用户要求“检查我这次改动”
- 用户准备提 PR 或准备发布
- 用户要求“按项目规范做一遍验证”

## 检查输入

- 改动范围（函数、SQL、文档、类型）
- 是否包含数据库迁移
- 目标环境（本地验证 / Preview / Production）

## 标准检查流程

1. 代码与测试
   - 执行改动范围内测试（当前最小基线：`deno test supabase/functions/auth-api`）
   - 执行改动范围内类型检查（当前最小基线：`deno check supabase/functions/auth-api/*.ts`）
2. SQL 变更检查（如涉及）
   - 确认迁移位于 `supabase/migrations/`
   - 确认未修改历史迁移
   - 确认命名符合时间戳规范
   - 确认同步更新 `types/supabase/database.ts`
3. 文档与流程检查
   - 核对 `README.md` 与 `docs/*.md` 是否同步
   - 核对 `.gitea/PULL_REQUEST_TEMPLATE.md` 清单项是否满足
4. 发布安全检查
   - 明确生产禁用 `db reset`
   - 明确生产走 CI，不手工直推

## 输出格式

必须输出以下四段：

1. **检查摘要**（通过/阻塞）
2. **执行记录**（命令与结果）
3. **问题列表**（阻塞项与修复建议）
4. **准入结论**（可提 PR / 不可提 PR）

## 判定规则

- 任一必检命令失败 => 结论为“不可提 PR”
- SQL 迁移不合规 => 结论为“不可发布”
- 生产出现 `db reset` 风险 => 结论为“阻塞”

## 关联依据

- `docs/sql_migration_playbook.md`
- `docs/dev_onboarding.md`
- `README.md`
- `.gitea/PULL_REQUEST_TEMPLATE.md`
