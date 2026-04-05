---
name: new-page
description: '根据 Figma 设计稿创建新页面，遵循 MVVM 三文件模式，自动生成页面骨架并集成路由。当用户提供 Figma 链接（figma.com/design/）、想要创建新页面、需要从设计稿生成 Flutter 页面代码、或提到"新页面""创建页面""设计稿转代码"时，务必触发本技能。即使用户只是粘贴了一个 Figma URL 而没有明确说"创建页面"，也应触发。'
argument-hint: '<figma-url> [--name <page_name>] [--route <route_path>]'
# examples:
#   - /new-page https://figma.com/design/xxx/file?node-id=22-1331
#   - /new-page https://figma.com/design/xxx/file?node-id=22-1331 --name profile --route /profile
---

# New Page：Figma → MVVM 页面生成

根据 Figma 设计稿自动创建符合项目 MVVM 规范的完整页面，包括路由注册、国际化文本和设计系统 token 映射。

---

## 前置检查

### 1. Figma MCP 可用性验证

**强制检查**：调用技能时必须先验证 Figma MCP 工具可用：

- 尝试调用 `mcp__mcp_router__get_screenshot` 或 `mcp__mcp_router__get_metadata` 进行连通性测试。
- **若不可用**，立即终止并输出：

```
❌ Figma MCP 不可用，无法创建页面。

请确认：
1. Figma 桌面端已打开并登录
2. MCP Server 配置正确（检查 .claude/settings.json 或 mcp 配置）
3. 网络连接正常
```

### 2. Figma URL 解析

从用户输入中提取：

- `fileKey`：文件标识
- `nodeId`：节点 ID（`node-id=22-1331` → `22:1331`）

支持的 URL 格式：
- `https://figma.com/design/:fileKey/:fileName?node-id=:nodeId`
- `https://www.figma.com/design/:fileKey/:fileName?node-id=:nodeId`
- 含 branch 的格式：`https://figma.com/design/:fileKey/branch/:branchKey/:fileName`

---

## 页面生成流程

### Phase 1: 设计稿获取与分析

1. **获取设计上下文**：调用 `get_design_context` 获取节点的参考代码、截图和元数据。
2. **获取变量定义**：调用 `get_variable_defs` 获取设计变量（颜色、间距等）。
3. **获取结构元数据**：调用 `get_metadata` 获取节点层级结构。

分析提取：
- 页面整体布局结构（Column/Row/Stack/ListView 等）
- 所有 UI 组件及其属性
- 颜色值 → 映射到 `AppColors` token
- 间距值 → 映射到 `AppSpacing` token
- 字号/字重 → 映射到 `AppFontSize`/`AppFontWeight`/`AppTextStyles` token
- 用户可见文本 → 提取待国际化文本列表
- 图片/图标资源 → 记录需要的 assets

### Phase 2: 页面命名与路由规划

1. 若未传入 `--name`，根据设计稿内容自动推断页面名称（snake_case）。
2. 若未传入 `--route`，根据页面名称生成路由路径。
3. 确认页面目录：`lib/pages/<page_name>/`。
4. 确认路由常量名：`RouteName.pageName`。

**向用户确认**：

```
📄 即将创建页面：

- 目录：lib/pages/<page_name>/
- 路由：/<route_path>
- 路由常量：RouteName.<pageName>
- 文件列表：
  - <page_name>_page.dart
  - <page_name>_state.dart
  - <page_name>_view_model.dart

确认创建？(Y/N)
```

### Phase 3: 生成 MVVM 三文件

#### A. State 文件（`<name>_state.dart`）

```dart
// 不可变状态类 + copyWith
class <Name>State {
  const <Name>State({...});
  // 根据设计稿提取的状态字段
  <Name>State copyWith({...});
}
```

#### B. ViewModel 文件（`<name>_view_model.dart`）

```dart
// Riverpod Notifier
class <Name>ViewModel extends Notifier<<Name>State> {
  @override
  <Name>State build() => const <Name>State();
  // 根据设计稿交互提取的方法
}

final <name>ViewModelProvider =
    NotifierProvider<<Name>ViewModel, <Name>State>(<Name>ViewModel.new);
```

#### C. Page 文件（`<name>_page.dart`）

```dart
// ConsumerStatefulWidget
// 根据设计稿还原 UI，严格使用设计系统 token
// 所有文本使用 flutter_i18n
```

**强制约束**：
- 颜色：仅使用 `AppColors.xxx`，禁止 `Color(0xFF...)` 或 `Colors.xxx`
- 间距：仅使用 `AppSpacing.xxx`，禁止裸数字
- 字体：仅使用 `AppTextStyles.xxx` 或 `AppFontSize.xxx` + `AppFontWeight.xxx`
- 文本：所有用户可见文本使用 `FlutterI18n.translate(context, "key")`
- 组件：优先使用 `lib/shared/widgets/` 中的共享组件（`AppButton`、`AppTextField`、`AppImage` 等）
- 导入：通过 barrel export 引入（`shared.dart`、`theme.dart` 等）

### Phase 4: 路由注册

1. 在 `lib/app/router/route_names.dart` 中添加路由常量。
2. 在 `lib/app/router/app_router.dart` 中注册 `GoRoute`。

### Phase 5: 国际化文本

1. 提取所有用户可见文本。
2. 在 `assets/flutter_i18n/zh_CN.json` 中添加中文翻译。
3. 在 `assets/flutter_i18n/en.json`（如有）中添加英文翻译。
4. 页面代码中使用 i18n key 引用。

### Phase 6: 资源处理

1. 设计稿中的图片/图标，提示用户手动导出并放置到 `assets/` 对应目录。
2. 资源命名必须遵循 `snake_case` 规范：`<类型>/<功能模块>/<用途>_<变体>.<扩展名>`。

### Phase 7: 验证

1. 执行 `flutter analyze` 确认无静态分析错误。
2. 检查生成的代码是否符合所有规范（等同于 `/review` 检查）。

---

## Figma 链接自动触发

当用户消息中包含 Figma 设计链接时（匹配 `figma.com/design/`），自动触发本技能：

- 解析 URL 提取 fileKey 和 nodeId
- 无需用户显式调用 `/new-page`
- 按上述完整流程执行

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| Figma MCP 不可用 | 终止并提示配置检查 |
| nodeId 无效/节点不存在 | 提示用户确认链接正确性 |
| 设计稿颜色无法映射到 token | 列出未映射的颜色值，建议先扩展 AppColors |
| 页面目录已存在 | 询问用户是覆盖还是取消 |
| flutter analyze 报错 | 自动尝试修复，无法修复则输出错误详情 |
