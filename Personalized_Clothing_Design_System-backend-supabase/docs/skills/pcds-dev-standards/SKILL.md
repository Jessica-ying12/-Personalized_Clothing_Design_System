---
name: pcds-dev-standards
description: Personalized_Clothing_Design_System-backend Supabase 后端开发规范技能。只要用户提到“开发规范”“最佳实践”“生产级方案”“怎么做才合规”“TDD 约束”“SQL 迁移规则”“RLS 策略”，就必须使用本技能，输出可执行的项目内规范，不给泛泛建议。
---

# Personalized_Clothing_Design_System-backend 开发规范技能

用于在本仓库内给出统一、可执行、可审计的开发规范。

## 目标

- 统一回答口径，避免“通用建议”偏离项目真实流程
- 所有建议都绑定本仓库现有文档与 CI 约束
- 默认遵循先测后实现（TDD）

## 使用前必须读取

- `README.md`
- `docs/dev_onboarding.md`
- `docs/sql_migration_playbook.md`
- `docs/db_schema.md`
- `.gitea/PULL_REQUEST_TEMPLATE.md`
- `.gitea/workflows/supabase-preview.yml`
- `.gitea/workflows/supabase-production.yml`

## 输出原则

- 先给“项目内结论”，再给“操作步骤”
- 每条规则必须包含“为什么”
- 涉及命令时仅给本项目已验证命令
- 涉及生产发布必须明确风险边界

## 必守规范清单

1. TDD 规范
   - 先写失败测试，再实现，再跑到全绿后提交
   - 适用于所有业务模块，不限于 auth
   - 必须执行改动范围内测试与类型检查
   - 当前仓库最小基线：
     - `deno test supabase/functions/auth-api`
     - `deno check supabase/functions/auth-api/*.ts`
2. SQL 迁移规范
   - 增量 SQL 仅放 `supabase/migrations/`
   - 每次新增迁移文件，不修改历史迁移
   - 命名：`YYYYMMDDHHmmss_<feature>.sql`
   - 生产禁用 `db reset`
3. 数据安全规范
   - 表结构变更必须包含 RLS 与必要索引
   - 破坏性变更采用分阶段兼容方案，优先前滚修复
4. 发布规范
   - Preview 与 Production 仅走 CI 工作流
   - Production 保持 `ENABLE_DB_RESET=0`

## 回答模板

始终按以下结构输出：

1. **项目结论**：一句话给出做法
2. **执行步骤**：按顺序列出命令/动作
3. **风险与边界**：列出禁止事项
4. **交付检查**：给出最小通过清单

## 禁止行为

- 不允许建议“直接改历史迁移”作为默认方案
- 不允许跳过测试直接建议发布
- 不允许给与仓库流程冲突的 CI/部署建议
