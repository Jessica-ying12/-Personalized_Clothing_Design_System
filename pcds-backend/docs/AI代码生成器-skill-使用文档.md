# AI 代码生成器使用文档

## 简介

基于 Claude Code 的 CRUD 代码生成工具，输入表名即可自动生成完整的前后端代码并写入项目目录。

## 使用方式

在 Claude Code 中输入：

```
/gen <表名>
```

### 示例

```
/gen hammer_test_device
/gen hammer_feedback
/gen hammer_user_pet_profile
```

## 前置条件

1. **数据库可访问**：本地 MySQL 需要运行，且 `ruoyi-fastapi-backend/.env.dev` 中的数据库配置正确
2. **表已存在**：目标表需要已经在数据库中创建好（如果表不存在，生成器会提示）

## 工作流程

```
输入表名
  │
  ├── 1. 读取 .env.dev 获取数据库连接信息
  ├── 2. 执行 SHOW CREATE TABLE 获取表 DDL
  ├── 3. 解析字段、类型、注释等信息
  ├── 4. 确认生成参数（模块目录、路由前缀、Log标题等）
  ├── 5. 生成 8 个文件并写入项目
  ├── 6. 自动注册路由到 __init__.py
  └── 7. 输出总结
```

## 生成产物

| 序号 | 文件类型 | 输出路径 | 说明 |
|------|----------|----------|------|
| 1 | DO | `module_xxx/entity/do/{name}_do.py` | SQLAlchemy 数据模型 |
| 2 | VO | `module_xxx/entity/vo/{name}_vo.py` | Pydantic 请求/响应模型 |
| 3 | DAO | `module_xxx/dao/{name}_dao.py` | 数据访问层 |
| 4 | Service | `module_xxx/service/{name}_service.py` | 业务逻辑层 |
| 5 | Controller | `module_xxx/controller/{name}_controller.py` | 路由控制器 |
| 6 | API (TS) | `ai-generator/result/{name}/api/{camelCase}.ts` | 前端 API |
| 7 | Vue 列表页 | `ai-generator/result/{name}/index.vue` | 列表 + 搜索 + 分页 |
| 8 | Vue 表单页 | `ai-generator/result/{name}/form.vue` | 新增/编辑弹窗 |

## 生成后需要手动完成

1. **前端文件迁移**：将 `ai-generator/result/{name}/` 下的文件复制到前端项目对应目录
2. **菜单配置**：在后台菜单管理中添加页面菜单和权限按钮
3. **业务调整**：检查生成的代码是否需要针对具体业务做微调

## 命名约定

以表名 `hammer_test_device` 为例：

| 项目 | 约定 | 示例 |
|------|------|------|
| DO 类名 | 去掉第一级前缀后 PascalCase | `TestDevice` |
| VO 类名 | `{PascalCase}Model` | `TestDeviceModel` |
| Service 类名 | `{PascalCase}Service` | `TestDeviceService` |
| DAO 类名 | `{PascalCase}Dao` | `TestDeviceDao` |
| Controller 变量名 | `{snake_case}_controller` | `test_device_controller` |
| 路由前缀 | `/模块/camelCase` | `/hammer/testDevice` |
| 权限标识 | 表名用 `:` 连接 | `hammer:test:device:list` |
| 前端 API 变量名 | `{camelCase}Api` | `testDeviceApi` |

## 技术栈

- **后端**：FastAPI + SQLAlchemy + Pydantic (async/await)
- **前端**：Vue 3 + TypeScript + Naive UI + `<script setup lang="tsx">`
