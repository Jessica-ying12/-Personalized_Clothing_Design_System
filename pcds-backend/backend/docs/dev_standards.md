# 个性化服装设计系统 开发规范

## 1. 项目约束

- 业务代码全部在 `module_pcds/` 目录，不修改 `module_admin/` 等原有模块
- 入口文件是 `server_pcds.py`，不是 `server.py`
- 数据库模型变更通过修改 `entity/do/` 文件 + 重启服务自动建表实现

## 2. 数据库变更规范

- 新增字段：在对应 `entity/do/*.py` 中添加 Column，重启服务自动 `CREATE TABLE IF NOT EXISTS`
- 注意：SQLAlchemy `create_all` 只建表不改列，已有表的列变更需手动执行 ALTER SQL
- 禁止直接修改生产数据库结构，必须先在本地验证

## 3. 代码结构规范

```
controller/  → 只做路由、参数校验、调用 service、返回响应
service/     → 业务逻辑、数据库操作、调用 AI 服务
entity/do/   → SQLAlchemy ORM 模型（对应数据库表）
entity/vo/   → Pydantic 请求/响应模型
```

## 4. 认证规范

- 所有需要登录的接口必须使用 `Depends(get_current_user)` 注入当前用户
- 所有数据库查询必须带 `user_id` 边界条件
- JWT Token 有效期 24 小时（`JWT_EXPIRE_MINUTES=1440`）

## 5. AI 服务规范

- Gemini API Key 配置在 `.env.local` 的 `GEMINI_API_KEY`
- 未配置 Key 时自动降级为 Pollinations AI（免费，无需 Key）
- IDM-VTON 虚拟试穿失败时自动降级为 Pollinations AI
- 所有 AI 调用失败必须有降级方案，不允许因 AI 服务不可用导致接口报错

## 6. 错误处理规范

- 业务错误抛出 `ValueError`，controller 层捕获转为 `HTTPException`
- 不允许在 service 层直接抛出 `HTTPException`
- 所有异常必须记录日志（`logger.error` 或 `logger.warning`）

## 7. 发布规范

- 本地验证：启动服务，访问 `/dev-api/docs` 手动测试关键接口
- 修改 `.env.local` 配置后必须重启服务
- 生产部署修改 `.env.prod` 或对应环境变量

## 8. 禁止行为

- 不允许在代码中硬编码密码、API Key 等敏感信息
- 不允许跳过 `user_id` 边界校验
- 不允许修改 `module_admin/` 等原有模块（避免破坏原有功能）
- 不允许在 service 层直接返回 HTTP 响应对象
