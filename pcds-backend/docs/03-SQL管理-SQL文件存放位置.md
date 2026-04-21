# SQL 管理 - SQL 文件存放位置

## 元数据
- **分类**: SQL 管理
- **标签**: SQL, 文件位置, 建表, 增量更新, 规范
- **适用场景**: 编写 SQL 脚本, 数据库结构变更, 初始化数据
- **相关文档**: 建表SQL规范, 增量SQL规范, ORM-vs-原生SQL

## 快速回答

**问题**: SQL 语句应该写在哪里？

**答案**:
- **建表/初始化 SQL** → `sql/ruoyi-fastapi.sql` 文件
- **增量变更 SQL** → `sql/update/xxx.sql` 文件
- **查询/更新操作** → DAO 层使用 SQLAlchemy ORM

---

## SQL 文件目录结构

```
ruoyi-fastapi-backend/sql/
├── ruoyi-fastapi.sql          # MySQL 完整建表脚本
├── ruoyi-fastapi-pg.sql       # PostgreSQL 建表脚本
├── hammer-admin.sql           # Hammer 模块表结构
├── hammer-dict.sql            # 字典初始数据
├── hammer-menu.sql            # 菜单初始数据
├── wechat-mp.sql              # 微信公众号模块
└── update/                    # 增量更新 SQL
    ├── hammer-admin-cwj.sql   # 按开发者命名
    └── hammer-admin-djh.sql
```

---

## 三类 SQL 的存放位置

### 1️⃣ 建表 SQL

📁 **位置**: `sql/ruoyi-fastapi.sql`

**用途**: 完整的数据库表结构定义

**示例**:
```sql
-- ----------------------------
-- 用户信息表
-- ----------------------------
drop table if exists sys_user;
create table sys_user (
  user_id           bigint(20)      not null auto_increment    comment '用户ID',
  dept_id           bigint(20)      default null               comment '部门ID',
  user_name         varchar(30)     not null                   comment '用户账号',
  status            char(1)         default '0'                comment '帐号状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (user_id)
) engine=innodb auto_increment=100 comment = '用户信息表';

-- ----------------------------
-- 初始化数据
-- ----------------------------
insert into sys_user values(1, 103, 'admin', '0', '0', 'admin', sysdate(), '', null);
```

**规范**:
- ✅ 清晰的注释（表名、字段说明）
- ✅ 所有表都包含标准字段：`create_by`, `create_time`, `update_by`, `update_time`
- ✅ 使用 `del_flag` 字段实现软删除
- ✅ 初始化数据紧跟在建表语句后

---

### 2️⃣ 增量更新 SQL

📁 **位置**: `sql/update/xxx.sql`

**用途**: 版本迭代时的数据库变更

**命名规范**: `模块名-开发者.sql` 或 `功能名-日期.sql`

**示例**:
```sql
-- 文件名: sql/update/add-user-points-20241215.sql

-- 2024-12-15 新增用户积分字段
ALTER TABLE sys_user ADD COLUMN points INT DEFAULT 0 COMMENT '用户积分';

-- 2024-12-15 修改状态字段长度
ALTER TABLE sys_user MODIFY COLUMN status varchar(10) DEFAULT '0' COMMENT '状态';

-- 2024-12-15 添加索引
CREATE INDEX idx_user_status ON sys_user(status);

-- 2024-12-15 初始化积分数据
UPDATE sys_user SET points = 100 WHERE user_id = 1;
```

**规范**:
- ✅ 每条 SQL 前加日期注释
- ✅ 使用 `ALTER TABLE` 修改表结构
- ✅ 包含必要的索引创建
- ✅ 如需初始化数据，一并写入

---

### 3️⃣ 应用代码中的 SQL（DAO 层）

📁 **位置**: `module_admin/dao/xxx_dao.py`

**用途**: 查询、插入、更新、删除操作

**使用 ORM，不写原生 SQL**:

```python
from sqlalchemy import select, update, delete, and_

# ✅ 推荐：使用 ORM
await db.execute(
    update(SysUser)
    .where(SysUser.user_id == user_id)
    .values(status='1', update_time=datetime.now())
)

# ❌ 不推荐：原生 SQL（除非必要）
sql = "UPDATE sys_user SET status = '1' WHERE user_id = %s"
await db.execute(sql, user_id)
```

---

## 决策树：SQL 写在哪里？

```
你的需求是什么？
│
├─ 创建新表？
│  └─ 写入 sql/ruoyi-fastapi.sql
│
├─ 修改表结构（添加字段、索引等）？
│  └─ 写入 sql/update/xxx.sql
│
├─ 初始化基础数据（字典、菜单等）？
│  └─ 写入 sql/hammer-dict.sql 或 sql/hammer-menu.sql
│
└─ 查询、更新、删除数据？
   └─ DAO 层使用 SQLAlchemy ORM
```

---

## 特殊场景：需要原生 SQL

当 ORM 无法满足复杂查询时，使用 `text()`:

```python
from sqlalchemy import text

# 复杂统计查询
sql = text("""
    SELECT
        u.dept_id,
        d.dept_name,
        COUNT(*) as user_count
    FROM sys_user u
    LEFT JOIN sys_dept d ON u.dept_id = d.dept_id
    WHERE u.status = :status
    GROUP BY u.dept_id
    HAVING user_count > :min_count
""")

result = await db.execute(
    sql,
    {"status": "0", "min_count": 5}
)
```

**何时使用原生 SQL**:
- 复杂的统计分析
- 需要数据库特定功能（如窗口函数）
- ORM 生成的 SQL 性能不佳

---

## 实际案例：新增用户昵称字段

### 步骤 1: 增量 SQL
📁 `sql/update/add-user-nickname.sql`:
```sql
-- 2024-12-15 新增用户昵称字段
ALTER TABLE sys_user ADD COLUMN nickname VARCHAR(50) DEFAULT '' COMMENT '用户昵称';
```

### 步骤 2: 更新模型
📁 `module_admin/entity/do/user_do.py`:
```python
class SysUser(Base):
    __tablename__ = 'sys_user'

    user_id = Column(BIGINT, primary_key=True)
    nickname = Column(String(50))  # 新增
```

### 步骤 3: DAO 层操作
📁 `module_admin/dao/user_dao.py`:
```python
@classmethod
async def update_user_nickname_dao(cls, db: AsyncSession, user_id: int, nickname: str):
    """更新用户昵称"""
    await db.execute(
        update(SysUser)
        .where(SysUser.user_id == user_id)
        .values(nickname=nickname)
    )
```

---

## 对照表

| SQL 类型 | 存放位置 | 文件示例 | 说明 |
|---------|---------|---------|------|
| 建表语句 | `sql/*.sql` | `ruoyi-fastapi.sql` | 完整表结构 |
| 增量变更 | `sql/update/*.sql` | `add-user-points.sql` | ALTER TABLE 等 |
| 初始数据 | `sql/*.sql` | `hammer-dict.sql` | INSERT 语句 |
| 查询操作 | DAO 层 | `user_dao.py` | 使用 ORM |
| 更新操作 | DAO 层 | `user_dao.py` | 使用 ORM |
| 删除操作 | DAO 层 | `user_dao.py` | 软删除（ORM） |

---

## 常见问题

**Q: 能在 Service 层写 SQL 吗？**
A: 不能！所有数据库操作必须在 DAO 层。

**Q: 增量 SQL 文件如何命名？**
A: `功能名-开发者.sql` 或 `功能名-日期.sql`，如 `add-user-points-cwj.sql`。

**Q: 什么时候用原生 SQL？**
A: 只有在 ORM 无法实现或性能不佳时才用，优先使用 ORM。

**Q: 软删除的 SQL 怎么写？**
A: 不写 `DELETE FROM`，而是 `UPDATE ... SET del_flag = '2'`。

---

## 相关文档

- 建表 SQL 规范
- 增量 SQL 规范
- ORM vs 原生 SQL
- 数据库操作 - 更新字段完整流程
