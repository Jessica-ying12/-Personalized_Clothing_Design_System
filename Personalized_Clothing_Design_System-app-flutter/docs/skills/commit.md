---
description: 'Git 提交技能：提交前自动审查代码规范，不通过则阻断并提示，通过后生成 conventional commit'
allowed-tools: Read(**), Glob(**), Grep(**), Edit(**), Write(**), mcp__ace-tool__search_context, Exec(git status, git diff, git add, git restore --staged, git commit, git rev-parse, git config, git log)
argument-hint: '[--no-verify] [--all] [--amend] [--emoji] [--skip-review] [--scope <scope>] [--type <type>]'
# examples:
#   - /commit                        # 审查 + 提交
#   - /commit --all --emoji          # 暂存所有改动，审查通过后带 emoji 提交
#   - /commit --skip-review          # 跳过审查直接提交
#   - /commit --scope auth --type feat  # 指定作用域和类型
---

# Claude Command: Commit（审查 + 提交）

在执行 Git 提交**之前**，自动触发代码规范审查。审查未通过时阻断提交并提示用户；通过后按 Conventional Commits 规范生成提交信息并执行提交。

---

## 完整流程

### Phase 0: 仓库校验

1. `git rev-parse --is-inside-work-tree` 确认处于 Git 仓库。
2. 检查是否处于 rebase/merge 冲突状态，若是则提示先处理冲突。
3. 读取当前分支名。

### Phase 1: 改动检测

1. `git status --porcelain` + `git diff` 获取已暂存与未暂存改动。
2. 若暂存区为空：
   - `--all` → 执行 `git add -A`。
   - 否则提示用户选择：手动暂存或取消。
3. 展示改动概览（文件列表 + 增删统计）。

### Phase 2: 规范审查（前置门禁）

**除非传入 `--skip-review`，否则强制执行。**

执行与 `/review` 技能相同的审查逻辑：

1. **加载规范基线**：读取 `CLAUDE.md` 和 `README.md`。
2. **逐文件审查**：对所有暂存文件进行规范合规性检查。
3. **文档同步检查**：判断是否需要更新 README/CLAUDE.md。

#### 审查结果处理

**✅ 审查通过（无 Error 级违规）**：

- 输出简要审查摘要。
- 若有 Warning 级项，列出但不阻断。
- 若检测到文档需要同步更新，**自动执行更新**并将文档变更一同暂存。
- 继续进入 Phase 3。

**❌ 审查未通过（存在 Error 级违规）**：

- 输出完整违规报告（文件、行号、类别、描述、修复建议）。
- **阻断提交**，向用户输出：

```
❌ 代码审查未通过，提交已阻断。

发现 N 个 Error 级违规项（见上方报告）。

请选择：
1. 我来手动修复后重新提交
2. 自动修复可修复项（部分项仍需手动处理）
3. 跳过审查强制提交（--skip-review）
```

- 等待用户选择后执行对应操作。

### Phase 3: 拆分建议

- 按关注点、文件模式、改动类型聚类。
- 若检测到多组独立变更（> 300 行 / 跨多个顶级目录），建议拆分提交并给出每组 pathspec。
- 用户确认后按分组或整体继续。

### Phase 4: 提交信息生成

遵循 **Conventional Commits** 规范：

1. **自动推断** `type`（feat/fix/docs/refactor/test/chore/perf/style/ci/revert）与 `scope`。
2. 若传入 `--type`/`--scope` 则覆盖自动推断。
3. 生成消息头：`[<emoji>] <type>(<scope>)?: <subject>`（≤ 72 字符，祈使语气）。
4. 生成消息体：动机、实现要点、影响范围、BREAKING CHANGE（如有）。
5. 仅在 `--emoji` 时包含 emoji 前缀。

### Phase 5: 执行提交

```bash
git commit [-S] [--no-verify] [-s] -F .git/COMMIT_EDITMSG
```

- `--amend`：修补上一次提交。
- `--no-verify`：跳过 Git 钩子。
- 多提交场景：按分组逐一执行 `git add <paths> && git commit ...`。

### Phase 6: 提交后确认

- 输出 `git log --oneline -1` 确认提交成功。
- 展示最终提交 hash 和消息。

---

## Type 与 Emoji 映射（--emoji 时）

- ✨ `feat` — 新增功能
- 🐛 `fix` — 缺陷修复
- 📝 `docs` — 文档
- 🎨 `style` — 风格/格式
- ♻️ `refactor` — 重构
- ⚡️ `perf` — 性能优化
- ✅ `test` — 测试
- 🔧 `chore` — 构建/杂务
- 👷 `ci` — CI/CD
- ⏪️ `revert` — 回滚

---

## 安全机制

- 审查阶段**不修改源代码**（除非用户选择自动修复）。
- 文档自动更新仅追加/修改文档文件，不影响业务代码。
- `git restore --staged <paths>` 可随时撤回误暂存文件。
