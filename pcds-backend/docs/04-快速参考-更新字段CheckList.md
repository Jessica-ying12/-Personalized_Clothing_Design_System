# 快速参考 - 更新字段 CheckList

## 元数据
- **分类**: 快速参考
- **标签**: CheckList, 更新字段, 自查清单
- **适用场景**: 更新字段前自查, 代码审查
- **相关文档**: 数据库操作-更新字段完整流程

---

## 🎯 更新字段完整检查清单

### ✅ 第 1 步: DAO 层
📁 `module_admin/dao/xxx_dao.py`

- [ ] 方法名以 `_dao` 结尾
- [ ] 添加了 `@classmethod` 装饰器
- [ ] 方法声明为 `async`
- [ ] 第一个参数是 `db: AsyncSession`
- [ ] 使用了 `update()` 而非字符串 SQL
- [ ] 同时更新了 `update_time` 字段
- [ ] 添加了完整的文档注释（`"""..."""`）

**示例**:
```python
@classmethod
async def update_user_status_dao(cls, db: AsyncSession, user_id: int, status: str):
    """
    更新用户状态
    :param db: orm对象
    :param user_id: 用户ID
    :param status: 状态值
    """
    await db.execute(
        update(SysUser)
        .where(SysUser.user_id == user_id)
        .values(status=status, update_time=datetime.now())
    )
```

---

### ✅ 第 2 步: Service 层
📁 `module_admin/service/xxx_service.py`

- [ ] 方法名以 `_service` 结尾
- [ ] 添加了 `@classmethod` 装饰器
- [ ] 方法声明为 `async`
- [ ] 使用了 `try-except` 包裹事务
- [ ] 成功后执行了 `await query_db.commit()`
- [ ] 失败后执行了 `await query_db.rollback()`
- [ ] 添加了业务校验逻辑
- [ ] 返回了 `CrudResponseModel`

**示例**:
```python
@classmethod
async def update_user_status_service(cls, query_db: AsyncSession, user_id: int, status: str):
    """更新用户状态业务逻辑"""
    # 业务校验
    if status not in ['0', '1']:
        raise ServiceException(message='状态值不合法')

    try:
        await UserDao.update_user_status_dao(query_db, user_id, status)
        await query_db.commit()  # ✅ 必须 commit
        return CrudResponseModel(is_success=True, message='更新成功')
    except Exception as e:
        await query_db.rollback()  # ✅ 必须 rollback
        raise e
```

---

### ✅ 第 3 步: Controller 层
📁 `module_admin/controller/xxx_controller.py`

- [ ] 使用了 `@router.put()` 或 `@router.post()` 装饰器
- [ ] 添加了 `dependencies=[Depends(CheckUserInterfaceAuth)]` 权限验证
- [ ] 使用了 `query_db: AsyncSession = Depends(get_db)` 获取数据库连接
- [ ] 方法声明为 `async`
- [ ] 调用了 Service 层方法
- [ ] 使用 `ResponseUtil.success()` 返回响应
- [ ] 添加了接口文档注释

**示例**:
```python
@router.put("/user/status", dependencies=[Depends(CheckUserInterfaceAuth('system:user:edit'))])
async def update_user_status(
    user_id: int,
    status: str,
    query_db: AsyncSession = Depends(get_db)
):
    """更新用户状态接口"""
    result = await UserService.update_user_status_service(query_db, user_id, status)
    return ResponseUtil.success(model_content=result)
```

---

### ✅ 第 4 步: 数据模型（可选）
📁 `module_admin/entity/do/xxx_do.py` 和 `module_admin/entity/vo/xxx_vo.py`

**如果是新增字段**:
- [ ] 在 DO (Data Object) 中添加了字段定义
- [ ] 在 VO (View Object) 中添加了字段定义
- [ ] 字段类型与数据库一致
- [ ] 添加了字段注释

**示例**:
```python
# DO 层
class SysUser(Base):
    __tablename__ = 'sys_user'
    user_id = Column(BIGINT, primary_key=True)
    status = Column(String(1))  # 新增字段

# VO 层
class UserModel(BaseModel):
    user_id: Optional[int] = None
    status: Optional[str] = None  # 新增字段
```

---

### ✅ 第 5 步: SQL 脚本（如果是新增字段）
📁 `sql/update/xxx.sql`

- [ ] 创建了增量 SQL 文件
- [ ] 文件命名规范（`功能名-日期.sql`）
- [ ] 使用了 `ALTER TABLE` 添加字段
- [ ] 添加了日期和功能注释
- [ ] 字段包含 `COMMENT` 说明

**示例**:
```sql
-- 文件名: sql/update/add-user-status.sql

-- 2024-12-15 新增用户状态字段
ALTER TABLE sys_user
ADD COLUMN status VARCHAR(1) DEFAULT '0' COMMENT '用户状态（0正常 1停用）';
```

---

## 🔍 常见错误自查

### ❌ 错误 1: 忘记提交事务
```python
# ❌ 错误
await UserDao.update_user_dao(query_db, user)
# 缺少 await query_db.commit()

# ✅ 正确
await UserDao.update_user_dao(query_db, user)
await query_db.commit()
```

### ❌ 错误 2: 没有异常处理
```python
# ❌ 错误
await UserDao.update_user_dao(query_db, user)
await query_db.commit()

# ✅ 正确
try:
    await UserDao.update_user_dao(query_db, user)
    await query_db.commit()
except Exception as e:
    await query_db.rollback()
    raise e
```

### ❌ 错误 3: 在 DAO 层写业务逻辑
```python
# ❌ 错误（DAO 层不应该有业务判断）
@classmethod
async def update_user_dao(cls, db: AsyncSession, user: dict):
    if user.get('admin'):
        raise ServiceException(message='不允许操作管理员')
    await db.execute(update(SysUser), [user])

# ✅ 正确（业务判断在 Service 层）
@classmethod
async def update_user_service(cls, query_db: AsyncSession, user: dict):
    if user.get('admin'):
        raise ServiceException(message='不允许操作管理员')
    await UserDao.update_user_dao(query_db, user)
```

### ❌ 错误 4: 忘记更新 update_time
```python
# ❌ 错误
await db.execute(
    update(SysUser)
    .where(SysUser.user_id == user_id)
    .values(status=status)  # 缺少 update_time
)

# ✅ 正确
await db.execute(
    update(SysUser)
    .where(SysUser.user_id == user_id)
    .values(status=status, update_time=datetime.now())
)
```

---

## 📝 完整示例模板

### DAO 层模板
```python
@classmethod
async def update_xxx_dao(cls, db: AsyncSession, id: int, value: str):
    """
    更新XXX
    :param db: orm对象
    :param id: 记录ID
    :param value: 更新值
    """
    await db.execute(
        update(TableName)
        .where(TableName.id == id)
        .values(field=value, update_time=datetime.now())
    )
```

### Service 层模板
```python
@classmethod
async def update_xxx_service(cls, query_db: AsyncSession, id: int, value: str):
    """更新XXX业务逻辑"""
    # 业务校验
    if not value:
        raise ServiceException(message='参数不能为空')

    try:
        await XxxDao.update_xxx_dao(query_db, id, value)
        await query_db.commit()
        return CrudResponseModel(is_success=True, message='更新成功')
    except Exception as e:
        await query_db.rollback()
        raise e
```

### Controller 层模板
```python
@router.put("/xxx", dependencies=[Depends(CheckUserInterfaceAuth('system:xxx:edit'))])
async def update_xxx(
    id: int,
    value: str,
    query_db: AsyncSession = Depends(get_db)
):
    """更新XXX接口"""
    result = await XxxService.update_xxx_service(query_db, id, value)
    return ResponseUtil.success(model_content=result)
```

---

## 🚀 快速开始

1. 复制上面的模板代码
2. 替换 `xxx` 为你的业务名称
3. 替换 `TableName` 为你的表模型
4. 按 CheckList 逐项检查
5. 运行测试验证

---

## 🔗 相关文档

- [数据库操作 - 更新字段完整流程](./02-数据库操作-更新字段完整流程.md)
- [SQL 管理 - SQL 文件存放位置](./03-SQL管理-SQL文件存放位置.md)
- [事务处理 - 最佳实践](./06-代码示例-事务处理最佳实践.md)
