# 开发环境准备与接手指南（新手/AI 智能体）

## 1. 必装工具

- Git（版本管理）
- Python 3.10+（后端运行环境）
- MySQL 8.0+（数据库）
- pip（Python 包管理）

## 2. 推荐版本基线

- Git: `>= 2.40`
- Python: `>= 3.10`
- MySQL: `>= 8.0`
- pip: 最新稳定版

## 3. 安装后自检命令

```bash
git --version
python --version
mysql --version
pip --version
```

## 4. 首次接手项目标准流程

1. 进入后端目录
   ```bash
   cd Hammer-Admin-master/ruoyi-fastapi-backend
   ```

2. 安装依赖
   ```bash
   pip install -r requirements_pcds.txt
   ```

3. 创建数据库
   ```sql
   CREATE DATABASE pcds_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

4. 配置环境变量
   ```bash
   # 编辑 .env.local，修改数据库密码
   DB_PASSWORD=你的MySQL密码
   GEMINI_API_KEY=你的Gemini Key（可选）
   ```

5. 启动服务
   ```bash
   python server_pcds.py
   ```
   首次启动自动建表并初始化设计选项数据。

6. 验证服务
   - 健康检查：`GET http://localhost:9099/dev-api/health`
   - API 文档：`http://localhost:9099/dev-api/docs`

## 5. Flutter APP 连接配置

Android 模拟器访问宿主机 localhost：
```
API_BASE_URL=http://10.0.2.2:9099/dev-api
```

真机调试（使用局域网 IP）：
```
API_BASE_URL=http://192.168.x.x:9099/dev-api
```

修改 `Personalized_Clothing_Design_System-app-flutter/lib/app/env.g.dart` 中的 `apiBaseUrl`。

## 6. AI 智能体接手强制约束

- 先阅读：`README_PCDS.md`、`docs/db_schema.md`、`docs/api_endpoints.md`
- 业务代码全部在 `module_pcds/` 目录下
- 入口文件：`server_pcds.py`（不是 `server.py`）
- 数据库模型变更：修改 `module_pcds/entity/do/` 下对应文件，重启服务自动建表
- 不允许修改 `module_admin/` 等原有模块（保留备用）

## 7. 项目结构说明

```
ruoyi-fastapi-backend/
├── server_pcds.py          # 项目入口（启动这个）
├── .env.local              # 本地环境配置
├── requirements_pcds.txt   # 项目依赖
├── module_pcds/            # 业务模块（核心）
│   ├── controller/         # 路由控制器
│   ├── service/            # 业务逻辑
│   ├── entity/
│   │   ├── do/             # 数据库模型（SQLAlchemy）
│   │   └── vo/             # 请求/响应模型（Pydantic）
│   └── dao/                # 数据访问层（预留）
├── config/                 # 框架配置（数据库、JWT等）
├── docs/                   # 项目文档
└── module_admin/           # 原有系统模块（保留，不使用）
```

## 8. 常见故障与处理

- `ModuleNotFoundError`：确认已执行 `pip install -r requirements_pcds.txt`
- `Can't connect to MySQL`：检查 `.env.local` 中的数据库配置，确认 MySQL 服务已启动
- `Table doesn't exist`：重启服务，`init_create_table()` 会自动建表
- `GEMINI_API_KEY not set`：不影响运行，图片生成降级为 Pollinations AI（免费）
- OTP 验证码收不到：开发模式下验证码打印在后端日志，不发送邮件
