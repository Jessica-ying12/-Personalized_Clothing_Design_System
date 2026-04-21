# 个性化服装设计系统 - 后端

基于 FastAPI + SQLAlchemy + MySQL 的后端服务。

## 技术栈

- FastAPI + Uvicorn
- SQLAlchemy (async) + MySQL
- JWT 认证（bcrypt 密码哈希）
- Gemini AI（图片生成提示词优化，可选）
- Pollinations AI（免费图片生成）
- IDM-VTON（虚拟试穿，HuggingFace Space）

## 目录结构

```
backend/
├── main.py                 # 入口文件
├── requirements.txt        # 依赖
├── .env.local              # 本地环境配置
├── config/                 # 框架配置（数据库、JWT）
├── module_pcds/            # 业务模块
│   ├── controller/         # 路由控制器
│   ├── service/            # 业务逻辑
│   ├── entity/do/          # 数据库模型
│   └── entity/vo/          # 请求/响应模型
└── utils/                  # 工具类
```

## 快速启动

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 创建数据库

```sql
CREATE DATABASE pcds_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 配置环境变量

编辑 `backend/.env.local`，修改数据库密码：

```env
DB_PASSWORD=你的MySQL密码
GEMINI_API_KEY=你的Gemini Key（可选）
```

### 4. 启动服务

```bash
cd backend
python main.py
```

首次启动自动建表并初始化设计选项数据。

- API 文档：http://localhost:9099/dev-api/docs
- 健康检查：http://localhost:9099/dev-api/health

## Flutter APP 连接

Android 模拟器：`API_BASE_URL=http://10.0.2.2:9099/dev-api`

真机调试：`API_BASE_URL=http://局域网IP:9099/dev-api`

## Gemini API Key

访问 https://aistudio.google.com/app/apikey 获取，填入 `.env.local` 的 `GEMINI_API_KEY`。
未配置时自动降级为 Pollinations AI（免费）。
