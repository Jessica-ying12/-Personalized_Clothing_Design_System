---
description: '审查代码是否符合 README 和 CLAUDE.md 规范，需要时自动更新文档'
allowed-tools: Read(**), Glob(**), Grep(**), Edit(**), Write(**), mcp__ace-tool__search_context
argument-hint: '[--fix] [--path <path>]'
# examples:
#   - /review                    # 审查当前所有未提交改动
#   - /review --fix              # 审查并自动修复不合规项
#   - /review --path lib/pages/  # 仅审查指定路径
---

# Claude Command: Code Review（规范审查）

对当前改动进行规范合规性审查，依据项目 `README.md` 和 `CLAUDE.md` 中定义的约定。

---

## 审查流程

### 1. 改动范围收集

- 执行 `git diff --name-only` 和 `git diff --cached --name-only` 获取所有变更文件列表。
- 若传入 `--path`，仅保留该路径下的文件。
- 若无任何改动，提示用户并终止。

### 2. 加载规范基线

读取以下两份文件作为审查基准：

- `CLAUDE.md`（项目根目录）
- `README.md`（项目根目录）

提取所有**强制约定**，包括但不限于：

| 规范类别 | 关键检查点 |
|---------|-----------|
| **设计系统** | 禁止硬编码颜色 `Color(0xFF...)`/`Colors.xxx`、间距裸数字、字号裸数字；必须使用 `AppColors`/`AppSpacing`/`AppFontSize`/`AppTextStyles` token |
| **路由** | 使用 `context.push/go(RouteName.xxx)` 导航，路由常量在 `route_names.dart` |
| **MVVM 三文件** | feature 目录下必须有 `_page.dart`/`_state.dart`/`_view_model.dart` |
| **Barrel exports** | 模块目录下应有统一 export 文件 |
| **国际化** | 所有用户可见文本必须使用 `flutter_i18n`，禁止硬编码中英文字符串 |
| **日志** | 统一使用 `Log.d/i/w/e` |
| **网络层** | API 按业务域拆分，ViewModel 通过 `apiCall()` + `Result<T>` 处理 |
| **代码生成** | 修改注解后是否需要执行 `build_runner` |
| **资源命名** | `assets/` 下文件必须 `snake_case`，禁止中文/空格/大写/特殊字符 |
| **存储层** | Box 名称和 Key 必须在 `box_keys.dart` 中声明，禁止硬编码字符串 |
| **TDD** | 新功能/Bug 修复必须有对应测试 |
| **导入规范** | 各模块通过 barrel export 引入（`shared.dart`/`storage.dart`/`supabase.dart` 等） |

### 3. 逐文件审查

对每个变更文件：

1. **读取文件完整内容**。
2. **逐条规范匹配**：检查是否存在违规项。
3. **记录违规**：生成结构化报告（文件路径、行号、违规类别、具体描述、修复建议）。

### 4. 文档同步检查

判断本次改动是否需要同步更新 `README.md` 或 `CLAUDE.md`：

- **新增模块/目录**：需在文档中补充说明。
- **新增共享组件**：需在 README 共享组件章节补充。
- **路由变更**：需更新路由相关说明。
- **新增环境变量**：需更新环境配置章节。
- **新增存储 Box/Key**：需更新存储层章节。
- **架构层级变更**：需更新分层表格。

若检测到需要更新，自动生成文档补丁并应用（或在非 `--fix` 模式下仅提示）。

### 5. 输出审查报告

```
## 审查报告

### 合规状态：✅ 通过 / ❌ 未通过

### 违规项（如有）
| # | 文件 | 行号 | 类别 | 描述 | 修复建议 |
|---|------|------|------|------|---------|
| 1 | ... | ... | ... | ... | ... |

### 文档同步
- [ ] README.md 需要更新：<原因>
- [ ] CLAUDE.md 需要更新：<原因>

### 总结
<简要总结改动质量与合规情况>
```

### 6. 自动修复（--fix 模式）

当传入 `--fix` 时：

- 对可自动修复的违规项（如硬编码颜色替换为 token、缺失的 barrel export）直接应用修复。
- 对需要人工判断的项（如缺失测试、架构设计问题）仅给出建议。
- 自动更新需要同步的文档。

---

## 审查严重级别

- **🔴 Error**：必须修复才能提交（硬编码颜色/间距/字号、缺失国际化、资源命名违规）
- **🟡 Warning**：建议修复（缺失测试、文档未同步、导入未使用 barrel export）
- **🔵 Info**：参考信息（代码风格建议、可选优化）

---

## 返回值

审查结果以退出状态返回：

- **PASS**：无 Error 级违规 → 可继续提交
- **FAIL**：存在 Error 级违规 → 建议阻断提交
