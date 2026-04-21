# 05-代码质量-静态检查与Pre-commit配置

## 一、概述

本项目配置了严格的代码质量检查工具，类似 Java 的编译检查，在代码提交前自动检测低级错误（如字段拼写错误、类型不匹配等），防止问题进入代码库。

### 核心工具

#### 代码质量检查
- **Mypy**: 静态类型检查（类似 Java 编译检查）
- **Ruff**: 快速代码检查和格式化
- **Pre-commit**: Git hook 管理，提交前自动运行检查

#### 安全检查工具
- **Bandit**: Python 安全漏洞静态分析
- **Safety**: 依赖包已知漏洞检查
- **detect-secrets**: 敏感信息泄露检测

---

## 二、开发环境快速设置

```bash
# 1. 安装开发依赖
cd ruoyi-fastapi-backend
pip install -r requirements-dev.txt

# 2. 配置 pre-commit hooks
cd ..
pre-commit install
```

---

## 三、配置文件说明

### 1. `pyproject.toml` - Mypy 和 Ruff 配置

**位置**: `ruoyi-fastapi-backend/pyproject.toml`

**关键配置**:

```toml
[tool.mypy]
python_version = "3.10"
ignore_missing_imports = true
plugins = ["pydantic.mypy"]

[tool.pydantic-mypy]
# 关键配置：禁止传入未定义的字段
init_forbid_extra = true
init_typed = true

[tool.ruff]
line-length = 120

[tool.ruff]
line-length = 120
target-version = "py310"

# 排除非代码目录
exclude = [".venv", "logs", "vf_admin", "assets", "migrations", "sql"]

[tool.ruff.lint]
select = [
    "E", "W", "F",      # pycodestyle + pyflakes
    "I", "N", "UP",     # import排序 + 命名规范 + 版本升级
    "B", "C4", "PIE", "RET", "SIM",  # 代码简化
    "TCH", "ARG", "PTH", "ERA",      # 类型检查 + 未使用参数 + pathlib + 注释代码
    "PL", "PERF", "RUF",             # Pylint + 性能优化 + Ruff特有规则
]

ignore = [
    "PLR0913",  # 参数过多（FastAPI常见）
    "PLR2004",  # 魔法值（业务代码常见）
    "ARG002",   # 未使用的方法参数（FastAPI依赖注入）
]

[tool.ruff.lint.isort]
known-first-party = ["module_admin", "module_hammer", "module_wechat_mp", "module_dify"]

[tool.ruff.lint.mccabe]
max-complexity = 10  # 圈复杂度限制
```

### 2. `.pre-commit-config.yaml` - Pre-commit 配置

**位置**: 项目根目录

**检查项**:
- Ruff Linter（自动修复）+ Formatter（代码格式化）
- Mypy 静态类型检查（覆盖5个核心业务模块）
- Bandit 安全漏洞扫描
- Safety 依赖包安全检查
- detect-secrets 敏感信息检测
- 通用检查（YAML、JSON、TOML、大文件、私钥检测等）

---

## 四、常见错误示例

### ❌ 错误：传入未定义的字段

```python
# UserFirebaseRegisterModel 只有 user_id 和 registration_id 字段
UserFirebaseRegisterModel(
    user_id=user_id,
    registration_id=registration_id,
    user_device_id=user_device_id,  # ❌ 该字段不存在
    project_id=project_id              # ❌ 该字段不存在
)
```

**Mypy 检测结果**:
```
error: Unexpected keyword argument "user_device_id" for "UserFirebaseRegisterModel"
error: Unexpected keyword argument "project_id" for "UserFirebaseRegisterModel"
```

### ✅ 正确：只传入已定义的字段

```python
UserFirebaseRegisterModel(
    user_id=user_id,
    registration_id=registration_id
)
```

### 字典构造规范

**注意**: 当键为合法标识符时，推荐使用 `dict()` 构造函数。

#### ❌ 不推荐 - 会触发 Ruff C408 警告
```python
device_list = [
    {'device_no': user_device.device_no, 'device_name': user_device.device_name}
    for user_device in user_device_list
]
```

#### ✅ 推荐 - 符合 Ruff 规范
```python
device_list = [
    dict(device_no=user_device.device_no, device_name=user_device.device_name)
    for user_device in user_device_list
]
```

---

## 五、日常使用

### 1. 提交代码（自动检查）

```bash
git add .
git commit -m "修复bug"
# 会自动运行所有检查，有错误则提交失败
```

### 2. 手动检查所有文件

```bash
cd /path/to/Hammer-Admin
pre-commit run --all-files
```

### 3. 检查单个文件

```bash
pre-commit run --files ruoyi-fastapi-backend/module_hammer/admin/dao/user_dao.py
```

### 4. 只运行特定检查

```bash
# Mypy 类型检查
pre-commit run mypy --all-files

# Ruff 代码检查
pre-commit run ruff --all-files

# 安全检查
pre-commit run bandit --all-files
pre-commit run detect-secrets --all-files
pre-commit run python-safety-dependencies-check --all-files
```

### 5. 跳过检查（紧急情况）

```bash
git commit -m "紧急修复" --no-verify
```

**⚠️ 注意**: 仅在紧急情况使用，之后需补充修复检查问题

---

## 六、Pydantic 模型严格模式

### 配置方法

在 Pydantic 模型中添加 `extra='forbid'` 配置：

```python
from pydantic import BaseModel, ConfigDict

class UserModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        from_attributes=True,
        populate_by_name=True,
        extra='forbid'  # 禁止传入未定义字段，运行时报错
    )

    user_id: int
    username: str
```

### 效果对比

| extra 配置 | 行为 | 适用场景 |
|-----------|------|---------|
| `'allow'` | 保存额外字段 | 动态字段场景 |
| `'ignore'`（默认） | 忽略额外字段 | ⚠️ 容易隐藏错误 |
| `'forbid'` | 运行时报错 | ✅ 推荐，严格模式 |

**配合 Mypy 的 `init_forbid_extra = true`**，可在编写代码时就发现错误！

---

## 七、PyCharm 集成（可选）

### 1. 安装 Mypy 插件

1. **Settings** → **Plugins** → 搜索 "Mypy"
2. 安装 **Mypy** 插件
3. **Settings** → **Mypy** → 配置:
   - Mypy executable: 选择虚拟环境中的 mypy
   - 勾选 **Run Mypy on file save**

**效果**: 保存文件时自动检查，实时发现错误！

### 2. 配置 External Tool

**Settings** → **Tools** → **External Tools** → **+**

**Mypy Check**:
- Program: `mypy`
- Arguments: `$FilePath$`
- Working directory: `$ProjectFileDir$/ruoyi-fastapi-backend`

**Ruff Check**:
- Program: `ruff`
- Arguments: `check $FilePath$`
- Working directory: `$ProjectFileDir$/ruoyi-fastapi-backend`

---

## 八、故障排查

### 1. Pre-commit 未生效

```bash
# 重新安装 hooks
cd /path/to/Hammer-Admin
pre-commit uninstall
pre-commit install
```

### 2. Mypy 找不到配置文件

检查 `.pre-commit-config.yaml` 中的路径:
```yaml
args: [--config-file=ruoyi-fastapi-backend/pyproject.toml]
```

### 3. Mypy 报太多错误

调整 `pyproject.toml` 中的严格度:
```toml
[tool.mypy]
ignore_missing_imports = true  # 忽略第三方库
disallow_untyped_defs = false  # 暂时关闭严格模式
```

### 4. 更新 pre-commit hooks

```bash
pre-commit autoupdate
```

---

## 九、最佳实践

### ✅ 推荐做法

1. **开发前先拉取最新代码并运行检查**
   ```bash
   git pull
   pre-commit run --all-files
   ```

2. **修复代码后再次检查**
   ```bash
   pre-commit run --files <修改的文件>
   ```

3. **小步提交，频繁检查**
   - 每完成一个小功能就提交
   - 避免一次性修改大量文件

4. **Pydantic 模型统一使用 `extra='forbid'`**

### ❌ 避免做法

1. **不要频繁使用 `--no-verify` 跳过检查**
2. **不要在 Mypy 报错时使用 `# type: ignore` 敷衍**
3. **不要修改配置文件降低检查标准**

---

## 十、检查工具对比

| 工具 | 检测时机 | 是否阻止提交 | 类似度 |
|-----|---------|-------------|--------|
| **Pre-commit + Mypy** | Git 提交前 | ✅ 是 | ⭐⭐⭐⭐⭐ Java 编译 |
| Pydantic `extra='forbid'` | 运行时 | ❌ 否 | ⭐⭐⭐ Java 运行时异常 |
| PyCharm 警告 | 编写时 | ❌ 否 | ⭐⭐ 提示级别 |

**结论**: Pre-commit + Mypy 提供了类似 Java 的编译期检查体验！

---

## 十一、团队协作建议

### 新成员入职

1. 克隆代码后立即运行:
   ```bash
   cd ruoyi-fastapi-backend
   pip install -r requirements-dev.txt
   cd ..
   pre-commit install
   ```

2. 首次检查（熟悉规范）:
   ```bash
   pre-commit run --all-files
   ```

### 代码审查要点

- ✅ 所有提交必须通过 pre-commit 检查
- ✅ Pydantic 模型必须配置 `extra='forbid'`
- ✅ 不允许使用 `# type: ignore` 除非有充分理由

---

## 十二、快速参考

### 常用命令

```bash
# 安装开发环境
pip install -r ruoyi-fastapi-backend/requirements-dev.txt
pre-commit install

# 检查所有文件
pre-commit run --all-files

# 检查单个文件
pre-commit run --files <文件路径>

# 只运行 Mypy
pre-commit run mypy --all-files

# 只运行 Ruff
pre-commit run ruff --all-files

# 只运行安全检查
pre-commit run bandit --all-files
pre-commit run detect-secrets --all-files

# 代码格式化（单独运行）
cd ruoyi-fastapi-backend
ruff format .

# 跳过检查提交（紧急）
git commit --no-verify

# 更新 hooks
pre-commit autoupdate
```

---

## 十三、安全检查工具详解

### 1. Bandit - 代码安全漏洞扫描

**检测内容**:
- SQL注入风险
- 命令注入风险
- 不安全的加密算法
- 硬编码密码
- 不安全的反序列化

**配置位置**: `ruoyi-fastapi-backend/pyproject.toml`

```toml
[tool.bandit]
exclude_dirs = ["tests", "migrations", "sql", ".venv", "logs"]
skips = [
    "B101",  # assert_used - 测试代码需要
    "B601",  # paramiko_calls - shell=True 在受控环境可用
]
confidence = "MEDIUM"
```

**常见警告处理**:
```python
# 如确认安全,可添加注释忽略
result = eval(user_input)  # nosec B307

# 或在 pyproject.toml 中全局排除
skips = ["B307"]  # eval() 使用
```

### 2. Safety - 依赖包漏洞检查

**功能**: 检查 `requirements*.txt` 中的依赖包是否有已知CVE漏洞

**使用**:
```bash
# Pre-commit 中自动运行
pre-commit run python-safety-dependencies-check --all-files

# 单独运行
safety check -r ruoyi-fastapi-backend/requirements.txt
```

**发现漏洞时**:
1. 检查是否有补丁版本: `pip list --outdated`
2. 升级到安全版本
3. 如无补丁,评估风险后可临时忽略

### 3. detect-secrets - 敏感信息泄露检测

**检测内容**:
- API密钥 (AWS, Azure, etc.)
- 数据库密码
- 私钥文件
- JWT Token
- 高熵度字符串 (Base64/Hex)

**配置文件**: `.secrets.baseline`

**误报处理**:
```bash
# 审查检测结果
detect-secrets audit .secrets.baseline

# 按 'n' 跳过误报,按 'y' 标记为真实密钥
```

**最佳实践**:
- ✅ 使用环境变量存储敏感信息
- ✅ `.env.example` 只放示例值
- ✅ `.gitignore` 中忽略 `.env*` (保留 `.env.example`)
- ❌ 不要在代码中硬编码密码/密钥

---

## 十四、排除目录说明

为避免检查非代码文件,已配置以下排除目录:

| 目录 | 说明 | 是否排除 |
|------|------|----------|
| `.venv`, `venv` | 虚拟环境 | ✅ |
| `logs` | 日志目录 | ✅ |
| `vf_admin` | 前端构建产物 | ✅ |
| `assets` | 静态资源 | ✅ |
| `migrations` | 数据库迁移 | ✅ |
| `sql` | SQL文件 | ✅ |
| `.ruff_cache` | Ruff缓存 | ✅ |
| `.mypy_cache` | Mypy缓存 | ✅ |
| `.pytest_cache` | Pytest缓存 | ✅ |

**配置位置**:
1. `pyproject.toml` - Ruff 和 Bandit
2. `.pre-commit-config.yaml` - Mypy 和 Bandit hooks
