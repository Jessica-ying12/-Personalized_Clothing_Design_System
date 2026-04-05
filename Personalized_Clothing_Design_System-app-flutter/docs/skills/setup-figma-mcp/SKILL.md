---
name: setup-figma-mcp
description: '配置 Figma MCP 服务器。当用户提到"配置 Figma""设置 Figma MCP""Figma 连接"或需要启用/更新/检查 Figma MCP 时触发。'
argument-hint: '[--token <new_token>]'
---

# Claude Command: Setup Figma MCP

一键配置项目的 Figma MCP 服务器，使 Claude Code 能直接读取 Figma 设计稿。

---

## 默认配置

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--stdio"],
      "env": {
        "FIGMA_API_KEY": "figd_JjiUBUb_BqyzAWzYonKXiEe87gW3rGuQjuxlqrGL"
      }
    }
  }
}
```

---

## 执行流程

### Step 1: 检查现有配置

读取项目根目录 `.mcp.json`，判断是否已存在 `figma` MCP 配置：

- **已存在且配置与默认一致** → 输出"配置已是最新"，结束。
- **已存在但 token 不同** → 提示差异，询问是否更新。
- **不存在** → 进入 Step 2。

### Step 2: 写入配置

使用上述**默认配置**写入 `.mcp.json`。若用户通过 `--token` 传入了新 token，则替换默认 token。

**注意**：若 `.mcp.json` 已有其他 MCP 配置，必须保留，仅合并 `figma` 条目。

### Step 3: 确保 .gitignore 排除

检查项目 `.gitignore` 是否包含 `.mcp.json`：

- **未包含** → 追加 `.mcp.json` 到 `.gitignore`（因含敏感 token）。
- **已包含** → 跳过。

### Step 4: 输出结果

```
Figma MCP 配置完成！

配置文件：.mcp.json
MCP 包：figma-developer-mcp (via npx)

请重启 Claude Code 会话以加载新的 MCP 服务器。
```

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| Token 格式无效（不以 `figd_` 开头） | 提示格式不正确，要求重新输入 |
| `.mcp.json` 存在但 JSON 格式损坏 | 提示用户确认是否覆盖 |
| 无写入权限 | 输出错误信息 |
