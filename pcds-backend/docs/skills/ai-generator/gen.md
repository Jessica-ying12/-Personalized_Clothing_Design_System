---
description: '根据表名从数据库读取表结构，自动生成完整的前后端 CRUD 代码并直接写入项目目录'
argument-hint: '<table_name>'
---

# AI 代码生成器

你是一个专业的全栈代码生成器。用户只需提供**表名**，你从数据库读取表结构，生成符合本项目规范的完整 CRUD 代码，并使用 Write 工具直接写入项目目录。

## 输入

表名：$ARGUMENTS

## 工作流程

### 第 0 步：初始化模板引用（自动）

模板源文件位于 `ai-generator/template/`，skill 通过符号链接引用。首次运行或 clone 后需自动创建：

使用 Bash 执行以下 Python 脚本，**静默运行，无需用户交互**：

```bash
python -c "
import os
from pathlib import Path
src = Path('ai-generator/template')
for dst_dir in [Path('docs/skills/ai-generator/references'), Path('.claude/skills/ai-generator/references')]:
    dst_dir.mkdir(parents=True, exist_ok=True)
    for f in src.glob('*.md'):
        t = dst_dir / f.name
        if not t.is_symlink():
            t.unlink(missing_ok=True)
            os.symlink(f.resolve(), dst_dir.resolve() / f.name)
print('references symlinks OK')
"
```

如果符号链接已存在则跳过，耗时可忽略。

### 第 1 步：从数据库获取表结构

1. 先读取 `ruoyi-fastapi-backend/.env.local` 文件，提取数据库连接信息（DB_HOST、DB_PORT、DB_USERNAME、DB_PASSWORD、DB_DATABASE）
2. 使用 Bash 工具执行 MySQL 命令获取建表 DDL：

```bash
mysql -h {DB_HOST} -P {DB_PORT} -u {DB_USERNAME} -p{DB_PASSWORD} {DB_DATABASE} -e "SHOW CREATE TABLE {table_name}\G"
```

3. 如果命令失败，提示用户检查表名是否正确或数据库是否可访问

### 第 2 步：解析表结构

从 DDL 中提取：

- **表名**（如 `hammer_feedback`）→ 推导模块前缀和实体名
- **主键字段**及类型
- **所有字段**：名称、类型、默认值、注释、是否可空
- **表注释**：用于生成中文描述

命名约定：
- Python DO 类名：实体名 PascalCase（如 `feedback` → `Feedback`）。如果表名有多级前缀，DO 类名取去掉第一级前缀后的 PascalCase
- Python Service/DAO 类名：`{PascalCase}Service` / `{PascalCase}Dao`
- Python VO 类名：`{PascalCase}Model`
- Controller 变量名：`{snake_case}_controller`（如 `feedback_controller`）
- JS/Vue 变量名：camelCase（如 `feedback`）
- 权限标识：表名按 `_` 拆分后全部用 `:` 连接（如 `hammer_feedback` → `hammer:feedback:list`）

### 第 3 步：确认生成参数

向用户确认以下信息（如能从表名前缀 + `config/env.py` 中的 `GenSettings` 推断则给出默认值）：

1. **所属模块目录**：代码放在哪个 `module_xxx` 下？（默认根据 `GenSettings.package_name` 推断，如 `module_hammer/admin`）
2. **路由前缀**：API 路径前缀（默认从表名推导，如 `hammer_feedback` → `/hammer/feedback`）
3. **Log 标题**：操作日志标题（默认使用表注释，如 `用户反馈`）
4. **是否需要导出功能**：默认是

**等待用户确认后再继续生成。**

### 第 4 步：使用 Write 工具直接生成文件

**重要规则**：
- **必须使用 Write 工具直接写文件**，不要输出代码块让用户复制
- **写文件前先用 Read 工具检查目标文件是否已存在**，已存在则询问用户是否覆盖
- 后端文件基础路径：`ruoyi-fastapi-backend/{module_path}/`
- 前端文件统一输出到：`ai-generator/result/{PascalCase}/`（PascalCase 命名，如 `UserSystemNotification`，自动新建目录），用户自行迁移到前端项目

按以下顺序生成文件：

---

#### 4.1 DO（数据库模型） — `entity/do/{entity_name}_do.py`

参考 `module_hammer/admin/entity/do/feedback_do.py` 的最新风格：

```python
from datetime import datetime
from sqlalchemy import BigInteger, Column, DateTime, String, Text  # 按需 import
from config.database import Base

class Feedback(Base):
    """用户反馈表"""
    __tablename__ = 'hammer_feedback'
    feedback_id = Column(BigInteger, primary_key=True, autoincrement=True, nullable=False, comment='反馈ID')
    # ...
    create_by = Column(String(64), default='', comment='创建者')
    create_time = Column(DateTime, default=lambda: datetime.now(), comment='创建时间')
    update_by = Column(String(64), default='', comment='更新者')
    update_time = Column(DateTime, default=lambda: datetime.now(), comment='更新时间')
```

MySQL → SQLAlchemy 类型映射：
- `bigint` → `BigInteger` | `varchar(n)` → `String(n)` | `char(n)` → `String(n)`
- `int`/`int(n)` → `Integer` | `smallint`/`tinyint` → `SmallInteger`
- `datetime` → `DateTime` | `text` → `Text` | `decimal(p,s)` → `Numeric(p, s)`

---

#### 4.2 VO（Pydantic 模型） — `entity/vo/{entity_name}_vo.py`

参考 `module_hammer/admin/entity/vo/feedback_vo.py` 的最新风格：

- 使用 `type | None` 语法（不用 `Optional[type]`）
- `model_config = ConfigDict(alias_generator=to_camel, from_attributes=True, populate_by_name=True)`
- 包含：`{Name}Model`、`{Name}QueryModel`、`{Name}PageQueryModel`（`@as_query`）、`Delete{Name}Model`
- `Delete` 模型的 ids 字段名 = 主键名复数（如 `feedback_ids`）

---

#### 4.3 DAO（数据访问层） — `dao/{entity_name}_dao.py`

参考 `module_hammer/admin/dao/feedback_dao.py` 的最新风格：

- 全部 `@classmethod` + `async`
- 方法：`get_*_detail_by_id`、`get_*_detail_by_info`、`get_*_list`、`add_*_dao`、`edit_*_dao`、`delete_*_dao`
- 列表查询用 `PageUtil.paginate`，按 `create_time.desc()` 排序
- 字符串字段用 `.like()`，精确匹配字段用 `==`

---

#### 4.4 Service（业务逻辑层） — `service/{entity_name}_service.py`

参考 `module_hammer/admin/service/feedback_service.py` 的最新风格：

- 增删改包含 `try/except` + `rollback`
- 返回 `CrudResponseModel(is_success=True, message='xxx成功')`
- 编辑时 `model_dump(exclude_unset=True, exclude={'create_by', 'create_time'})`
- 详情查询使用 `CamelCaseUtil.transform_result()`
- 导出使用 `ExcelUtil.export_list2excel(data_list, mapping_dict)`
- mapping_dict 的 key 使用 camelCase（与前端字段名一致）

---

#### 4.5 Controller（路由控制器） — `controller/{entity_name}_controller.py`

参考 `module_hammer/admin/controller/feedback_controller.py` 的最新风格：

- 路由变量名：`{entity_name}_controller`（snake_case）
- 权限：`CheckUserInterfaceAuth('{prefix}:{action}')`，全部用 `:` 分隔
- 新增/编辑注入 `create_by`/`update_by` + `datetime.now()`
- `@Log(title='...', business_type=BusinessType.XXX)` 装饰器
- 每个接口加 `logger.info()`

---

#### 4.6 前端 API — `ai-generator/result/{PascalCase}/api/{camelCase}.ts`

参考 `docs/skills/ai-generator/references/api.md` 的模板结构。

---

#### 4.7 Vue 列表页 — `ai-generator/result/{PascalCase}/index.vue`

参考 `docs/skills/ai-generator/references/vue.md` 的模板结构：
- Naive UI + Vue3 + `<script setup lang="tsx">`
- 搜索只选有意义的字段（name/status/type 等）
- `FormActionGroup` + `NDataTable` 远程分页
- 状态用 `NTag` 渲染，操作列 `v-hasPermi` 权限控制

---

#### 4.8 Vue 表单弹窗 — `ai-generator/result/{PascalCase}/form.vue`

参考 `docs/skills/ai-generator/references/vue-form.md` 的模板结构：
- 新增/编辑共用弹窗
- 排除 `create_by`/`create_time`/`update_by`/`update_time`
- 状态字段用 `NRadioGroup`
- `defineExpose({ handleAdd, handleUpdate })`

---

### 第 5 步：自动注册路由

使用 Edit 工具在 `ruoyi-fastapi-backend/{module_path}/__init__.py` 的 `configure_init_router` 函数末尾追加：

```python
    from {module_path}.controller.{entity_name}_controller import {entity_name}_controller

    app.include_router({entity_name}_controller, prefix=prefix, tags=['{表注释}模块'])
```

注意缩进必须与已有代码一致（4 个空格）。

### 第 6 步：生成动态菜单 SQL

生成菜单插入 SQL，输出到 `ai-generator/result/{PascalCase}/menu.sql`。

使用项目中已有的 `InsertMenu` 存储过程，该过程会自动创建主菜单 + 5 个权限按钮（查询/新增/修改/删除/导出）。

**生成前需向用户确认**：父菜单是哪个？提供两种父菜单引用方式：
- 使用变量 `@parentMenuId`（顶级模块菜单）或 `@childParentMenuId`（子目录菜单）
- 使用具体菜单 ID（如 `'2000'`）

参考 `ruoyi-fastapi-backend/sql/hammer-menu.sql` 中的已有格式。

**InsertMenu 参数说明**：
```
CALL InsertMenu(菜单名称, 路由path, 组件路径, 权限前缀, 图标, 排序, 父菜单ID, @lastInsertedMenuId);
```

示例（父菜单为子目录"杰峰云管理"）：

```sql
SET @lastInsertedMenuId = 0;

-- ----------------------------
-- 测试设备管理
-- ----------------------------
CALL InsertMenu('测试设备', 'test-device', 'hammer/TestDevice/index', 'hammer:test:device', '#', 2, @childParentMenuId, @lastInsertedMenuId);
```

示例（父菜单为具体 ID）：

```sql
SET @lastInsertedMenuId = 0;

-- ----------------------------
-- 测试设备管理
-- ----------------------------
CALL InsertMenu('测试设备', 'test-device', 'hammer/TestDevice/index', 'hammer:test:device', '#', 2, '2000', @lastInsertedMenuId);
```

命名规则：
- **菜单名称**：表注释（去掉"表"字，如"测试设备表" → "测试设备"）
- **路由 path**：entity_name 的 kebab-case（如 `test-device`）
- **组件路径**：`{模块前缀PascalCase}/{EntityPascalCase}/index`（如 `hammer/TestDevice/index`）
- **权限前缀**：与 Controller 中的权限标识一致（不含 `:list` 等后缀，存储过程会自动拼接）

### 第 7 步：输出总结

生成完毕后输出：

1. **文件清单表格**：

| 序号 | 文件类型 | 文件路径 | 状态 |
|------|----------|----------|------|
| 1 | DO | `ruoyi-fastapi-backend/{module}/entity/do/{name}_do.py` | 已创建 |
| 2 | VO | `ruoyi-fastapi-backend/{module}/entity/vo/{name}_vo.py` | 已创建 |
| 3 | DAO | `ruoyi-fastapi-backend/{module}/dao/{name}_dao.py` | 已创建 |
| 4 | Service | `ruoyi-fastapi-backend/{module}/service/{name}_service.py` | 已创建 |
| 5 | Controller | `ruoyi-fastapi-backend/{module}/controller/{name}_controller.py` | 已创建 |
| 6 | API (TS) | `ai-generator/result/{PascalCase}/api/{camelCase}.ts` | 已创建 |
| 7 | Vue 列表页 | `ai-generator/result/{PascalCase}/index.vue` | 已创建 |
| 8 | Vue 表单页 | `ai-generator/result/{PascalCase}/form.vue` | 已创建 |
| 9 | 菜单 SQL | `ai-generator/result/{PascalCase}/menu.sql` | 已创建 |

2. **路由注册状态**：已自动注册到 `__init__.py`

3. **菜单 SQL 提醒**：
   - 菜单插入 SQL 已生成到 `ai-generator/result/{PascalCase}/menu.sql`
   - 执行前请确认父菜单名称是否正确
   - 在目标数据库中直接执行即可

4. **前端文件迁移提醒**：
   - 前端文件已生成到 `ai-generator/result/{PascalCase}/` 目录
   - 请手动将 `api/`、`index.vue`、`form.vue` 迁移到前端项目对应目录
   - 在前端路由配置中添加页面路由
   - 在菜单管理中配置菜单和权限按钮
   - 检查生成的代码是否需要针对业务逻辑做微调

## 重要约束

- **必须使用 Write 工具直接写文件**，不要输出代码块
- **写文件前先检查是否已存在**
- 严格遵循项目现有代码风格（以 `feedback` 模块为最新参考标准）
- 所有 Python 代码使用 async/await
- VO 使用 `type | None` 语法（Python 3.10+），不用 `Optional`
- VO 必须配置 `alias_generator=to_camel` + `from_attributes=True`
- 权限标识只用 `:` 分隔
- Vue 使用 Naive UI + `<script setup lang="tsx">`
- 每个文件都是完整可用的代码，不省略任何 import
- DO 的 `__tablename__` 必须与数据库中的表名完全一致
- Service 导出使用 `ExcelUtil.export_list2excel`
