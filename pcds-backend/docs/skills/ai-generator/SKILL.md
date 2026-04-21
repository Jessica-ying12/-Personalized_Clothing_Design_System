---
name: ai-generator
description: >-
  根据数据库表名自动生成完整的前后端 CRUD 代码（DO/VO/DAO/Service/Controller + Vue 页面 + API + 菜单 SQL），
  并直接写入项目目录。当用户需要快速创建新的增删改查模块时使用此技能。
license: Apache-2.0
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
metadata:
  category: code-generation
  complexity: advanced
compatibility: Claude Code 1.0+, Python 3.10+, MySQL 5.7+
---

# AI 代码生成器

根据表名从数据库读取表结构，自动生成符合本项目规范的完整 CRUD 代码。

## 触发条件

- 用户提供数据库表名并请求生成 CRUD 代码
- 用户使用 `/ai-generator:gen <table_name>` 命令

## 技能结构

```
ai-generator/
├── SKILL.md              # 技能元数据与说明（本文件）
├── gen.md                # 主命令，完整生成工作流
├── scripts/              # 构建与测试脚本
│   ├── __init__.py
│   ├── build.py          # 符号链接构建器
│   └── build_test.py     # TDD 测试（21 cases）
├── references/           # 各层代码模板参考（gen.md 按需读取）
│   ├── index.md          # 模板索引
│   ├── do.md             # DO 层模板
│   ├── vo.md             # VO 层模板
│   ├── dao.md            # DAO 层模板
│   ├── service.md        # Service 层模板
│   ├── controller.md     # Controller 层模板
│   ├── api.md            # 前端 API 模板
│   ├── vue.md            # Vue 列表页模板
│   └── vue-form.md       # Vue 表单弹窗模板
├── assets/               # 输出资源文件
└── evals/                # 评估用例
    └── evals.json        # 测试提示词与断言
```

## 入口命令

- `gen.md` — 主命令文件，包含完整的生成工作流

## 参考文件

`references/` 目录包含各层代码的参考模板，gen.md 在生成对应层代码时按需读取。
详见 `references/index.md` 了解每个模板的用途和读取时机。

## 生成的文件

| 层级 | 文件 | 说明 |
|------|------|------|
| DO | `entity/do/{name}_do.py` | SQLAlchemy 数据库模型 |
| VO | `entity/vo/{name}_vo.py` | Pydantic 请求/响应模型 |
| DAO | `dao/{name}_dao.py` | 数据访问层 |
| Service | `service/{name}_service.py` | 业务逻辑层 |
| Controller | `controller/{name}_controller.py` | 路由控制器 |
| API (TS) | `api/{camelCase}.ts` | 前端 API 调用 |
| Vue 列表页 | `index.vue` | Naive UI 列表页面 |
| Vue 表单页 | `form.vue` | 新增/编辑弹窗 |
| 菜单 SQL | `menu.sql` | 动态菜单插入脚本 |

## 依赖

- MySQL 数据库连接（读取 `.env.dev` 配置）
- 项目现有代码风格参考（feedback 模块）

## 构建与分发

通过 `scripts/build.py` 在项目根目录创建符号链接，分发到各 AI 工具：

```bash
# 构建所有目标（.claude/.trae/.cursor 符号链接）
python docs/skills/ai-generator/scripts/build.py

# 清理后重建
python docs/skills/ai-generator/scripts/build.py --clean
python docs/skills/ai-generator/scripts/build.py

# 运行测试
cd docs/skills/ai-generator/scripts && python -m pytest build_test.py -v
```

符号链接指向源文件，修改 `gen.md` 后无需重新构建即可生效。
首次使用或换机器时运行一次 build 即可。

支持的 AI 工具：Claude Code、Trae、Cursor
