---
name: pcds-dev-onboarding
description: Personalized_Clothing_Design_System-backend 新手与 AI 接手教程技能。只要用户提到“从零开始”“怎么搭环境”“新手接手”“AI 接手项目”“安装 Supabase/Deno/Git”，必须启用本技能，提供一步一步可执行的上手流程和排障指南。
---

# Personalized_Clothing_Design_System-backend 开发教程技能

用于帮助新人或 AI 智能体快速接手项目，避免环境不完整导致后续开发失败。

## 教程目标

- 在最短路径内完成可运行开发环境
- 明确必装工具、版本基线、自检命令
- 完成一次标准“拉起-测试-调试”闭环

## 教程来源

优先以以下文档为准：

- `docs/dev_onboarding.md`
- `README.md`
- `docs/sql_migration_playbook.md`

## 教学流程

1. 前置说明
   - 说明本项目技术栈：Supabase + Deno Edge Functions + SQL Migrations
2. 安装步骤
   - Git、Supabase CLI、Deno（可选 Node.js）
   - 给出平台对应安装命令
3. 安装验证
   - 执行版本检查命令并解释合格条件
4. 项目初始化
   - 复制 `.env`、`.build.env`
   - 启动 Supabase、本地迁移、运行测试、类型检查
5. 首次调试
   - 启动 `auth-api` 本地服务并说明最小验证方式
6. 常见问题
   - command not found
   - 环境变量缺失
   - `db reset` 误用风险

## 输出要求

- 输出必须按“步骤编号 + 命令 + 预期结果”格式
- 每一步都要给“失败时怎么办”
- 明确区分“本地开发可执行”与“生产禁止执行”

## 教程结尾检查

完成后必须再次提醒：

- 后续开发全业务遵循 TDD（先测后实现）
- SQL 改动仅新增迁移文件
- 提 PR 前使用 `.gitea/PULL_REQUEST_TEMPLATE.md` 检查
