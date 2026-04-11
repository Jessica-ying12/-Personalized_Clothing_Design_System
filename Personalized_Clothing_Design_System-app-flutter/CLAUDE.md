# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# 运行（三�?flavor，必须指�?--flavor �?-t�?flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor preview -t lib/main_preview.dart
flutter run --flavor prod -t lib/main_prod.dart

# 打包
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build ios --flavor prod -t lib/main_prod.dart

# 测试
flutter test

# 代码生成（修改注解或环境变量后必须执行，先清缓存再生成）
dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs

# 静态分�?flutter analyze
```

## Architecture

**MVVM + Riverpod** 单模�?Flutter 应用，三环境隔离（dev/preview/prod）�?
### 启动流程

`main_<flavor>.dart` �?`mainCommon(Flavor)` �?初始�?Flavor/Logger �?Hive/Supabase 初始�?�?`ProviderScope(overrides)` �?`App`

### 核心分层

| �?| 路径 | 职责 |
|---|---|---|
| 入口 | `lib/main_*.dart` + `main_common.dart` | Flavor 路由与公共初始化 |
| App | `lib/app/` | MaterialApp.router 根组件、GoRouter 路由配置、Flavor 枚举(`F.xxx`)、Envied 环境变量、设计系统（`theme/`�?|
| 页面 | `lib/pages/<feature>/` | MVVM 三文件：`_page.dart` / `_state.dart` / `_view_model.dart` |
| 基础设施 | `lib/logger/`、`lib/i18n/`、`lib/core/network/`、`lib/core/unimp/`、`lib/core/supabase/`、`lib/core/storage/` | 日志、国际化、网络层、uni 小程序引擎、Supabase 认证、本地持久化 |
| 共享�?| `lib/shared/` | 通用 UI 组件（`widgets/`）、工具函数（`utils/`�?|

### 关键约定

- **设计系统（Theme，强制）**：`lib/app/theme/` 统一管理颜色（`AppColors`）、间距（`AppSpacing`）、字体（`AppFontSize`/`AppFontWeight`/`AppTextStyles`）、主题组装（`AppTheme.light/dark`）；**严禁在任何文件中硬编码颜色值（`Color(0xFF...)`/`Colors.xxx`）、间距裸数字和字号裸数字，必须使�?`AppColors`/`AppSpacing`/`AppFontSize`/`AppTextStyles` token**（装饰性渐变色等非语义色可例外）；通过 `import 'package:personalized_clothing_design_system/app/theme/theme.dart'` 引入；`AppTheme.light/dark` 已接�?`MaterialApp`，也可通过 `Theme.of(context).colorScheme/textTheme` 访问
- **路由**：`go_router` 管理，路由表�?`lib/app/router/app_router.dart`，路由常量在 `route_names.dart`，使�?`context.push/go(RouteName.xxx)` 导航
- **MVVM 三文件模�?*：每�?feature 目录下固�?`_page.dart`（ConsumerStatefulWidget）、`_state.dart`（不可变 + copyWith）、`_view_model.dart`（Notifier�?- **Barrel exports**：模块目录下统一 export 文件（如 `logger.dart`、`i18n.dart`、`shared.dart`�?- **环境变量**：通过 `F.xxx` 静�?getter 访问，底层由 `envied` 编译期注入，源文件为 `.env.dev/.env.preview/.env.prod`
- **文本都要进行国际�?*：`flutter_i18n` JSON 驱动，翻译文件在 `assets/flutter_i18n/`，回退语言 zh_CN
- **日志**：统一 `Log.d/i/w/e`，prod 环境自动关闭
- **网络�?*：`lib/core/network/`，Dio + Retrofit；API 按业务域拆分（`api/<domain>/`），每域�?`_api.dart` + `model/`；拦截器链：Retry �?Auth �?Log �?Error；ViewModel 通过 `apiCall()` + `Result<T>` 处理响应
- **代码生成**：修�?`@RestApi`/`@JsonSerializable`/`@Envied` 注解�?`.env.*` 文件后必须执�?`dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs`
- **README 跟踪**：当有新功能或模块接入时，请同步更新 README �?CLAUDE.md
- **共享组件**：`lib/shared/widgets/` 提供 `AppButton`、`AppTextField`、`AppImage`、`AppNavigationBar`、`AppDialog` 等通用组件；`lib/shared/utils/` 提供 `Validators`、`Formatters` 工具类；统一通过 `import 'package:personalized_clothing_design_system/shared/shared.dart'` 引入
- **顶部导航栏（强制�?*：所有页面的顶部导航栏必须使�?`AppNavigationBar`（`lib/shared/widgets/navigation/app_navigation_bar.dart`），严禁直接使用原生 `AppBar`；支�?`title`/`titleWidget`/`leading`/`actions`/`backgroundColor`/`gradient`/`foregroundColor` 等参�?- **资源命名（强制）**：`assets/` 下所有文件必须遵循命名规范，详见 README「资源命名规范」章节。格式：`snake_case`，结构：`<类型>/<功能模块>/<用�?_<变体>.<扩展�?`，严禁中文、空格、大写字母、特殊字�?- **Supabase**：`lib/core/supabase/` 封装认证层，通过 `supabaseProvider`（`Provider<SupabaseClient>`）、`authRepositoryProvider`、`authStateProvider`（StreamProvider）、`currentUserProvider` 提供响应�?auth 状态；统一通过 `import 'package:personalized_clothing_design_system/core/supabase/supabase.dart'` 引入；`AuthInterceptor` 已自动从 `currentSession` 注入 Bearer token 并处�?401 刷新
- **UniMPSDK（uni 小程序）**：`lib/core/unimp/` 封装 MethodChannel 桥接，通过 `UniMPService.open/close/install/checkExists/getVersion/downloadAndInstall` 操作小程序；Android �?AAR �?`android/app/libs/`（SDK 4.85），iOS 端通过 CocoaPods 集成（SDK 4.75）；`AndroidManifest.xml` 必须设置 `extractNativeLibs="true"`；新增小程序需�?`dcloud_control.xml` 中注�?appid；远程安装通过 Dart �?Dio 下载 wgt 后调用原�?install
- **本地持久化（Hive�?*：`lib/core/storage/` 封装 Hive 存储层，通过 `storageServiceProvider`（`Provider<StorageService>`）访问；Box 名称�?Key 常量统一�?`box_keys.dart` 中声明（`BoxKeys`/`AppKeys`），禁止硬编码字符串；`StorageService` 提供 `get/getOrDefault/put/delete/containsKey/clear`；新增业�?box 需�?`main_common.dart` 初始化并注入�?Provider；统一通过 `import 'package:personalized_clothing_design_system/core/storage/storage.dart'` 引入
- **TDD 开发流程（强制�?*：所有新功能�?Bug 修复必须遵循 Red �?Green �?Refactor 循环：先�?`test/` 中编写失败测试（Red），再编写最小实现使测试通过（Green），最后重构优化（Refactor）；`flutter test` 必须在提交前全部通过
- **测试框架**：`flutter_test` + `mocktail`（无代码生成�?Mock 框架）；测试目录镜像 `lib/` 结构（`test/pages/home/home_view_model_test.dart` 对应 `lib/pages/home/home_view_model.dart`）；通用工具�?`test/helpers/`（`test_helpers.dart` 提供 `initTestEnv()`/`createContainer()`，`mocks.dart` 集中定义 Mock 类）
- **测试约定**：State 类测�?`copyWith` 和默认值；ViewModel 测试所有公开方法的状态变更（含正�?异常分支）；Core 层（StorageService/AuthRepository/ApiException/Result）各有独立测试；ViewModel 测试通过 `createContainer(overrides: [...])` 注入 Mock 依赖，`setUp` 中调�?`initTestEnv()` 初始�?Flavor �?Logger；测试命名使用中文描述（`test('成功时应更新状�?, ...)`�?