# LivHome

## 环境隔离 (Flavor + Envied)

### 依赖库

| 库 | 用途 |
|---|---|
| `flutter_flavorizr: ^2.4.2` | 生成 Android/iOS 多 flavor 构建配置 |
| `envied: ^1.3.3` | 编译期注入环境变量，类型安全 |
| `envied_generator: ^1.3.3` | envied 代码生成器 |
| `build_runner: ^2.4.13` | Dart 代码生成引擎 |

### 环境

| Flavor | 包名 (Android) | Bundle ID (iOS) | 入口文件 |
|---|---|---|---|
| dev | `com.explorex.camlink.dev` | `com.explorex.camlink.dev` | `lib/main_dev.dart` |
| preview | `com.explorex.camlink.preview` | `com.explorex.camlink.preview` | `lib/main_preview.dart` |
| prod | `com.explorex.camlink` | `com.explorex.camlink` | `lib/main_prod.dart` |

### 运行 & 打包

```bash
# 运行
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor preview -t lib/main_preview.dart
flutter run --flavor prod -t lib/main_prod.dart

# 打包 APK
flutter build apk --flavor dev -t lib/main_dev.dart

# 打包 iOS
flutter build ios --flavor prod -t lib/main_prod.dart
```

### 环境变量字段

在 `.env.dev` / `.env.preview` / `.env.prod` 中定义：

| 字段 | 类型 | 说明 |
|---|---|---|
| `APP_NAME` | String | 应用显示名称 |
| `API_BASE_URL` | String | API 基础地址 |
| `ENABLE_LOG` | bool | 是否启用日志 |
| `SUPABASE_URL` | String | Supabase 项目 URL |
| `SUPABASE_ANON_KEY` | String | Supabase 匿名公钥 |

### 新增环境字段步骤

1. 在 `.env.dev` / `.env.preview` / `.env.prod` 中添加 `KEY=value`
2. 在 `lib/app/env.dart` 的 `EnvDev`、`EnvPreview`、`EnvProd` 中声明字段
3. 在 `lib/app/flavors.dart` 中添加对应 getter
4. 运行代码生成（先清缓存再生成）：
   ```bash
   dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
   ```
5. 通过 `F.xxx` 访问

---

## 设计系统 (Theme)

### 目录结构

```
lib/app/theme/
├── app_colors.dart       # 颜色 token（品牌/中性/语义/背景）
├── app_spacing.dart      # 间距 & 圆角（4dp 网格）
├── app_text_styles.dart  # 字号/字重/预设 TextStyle
├── app_theme.dart        # ThemeData 组装（light / dark）
└── theme.dart            # barrel export
```

### 引入

```dart
import 'package:livhome/app/theme/theme.dart';
```

### 颜色 (AppColors)

| 分类 | Token | 示例值 |
|---|---|---|
| 品牌 | `primary` / `primaryLight` / `primaryDark` | `#3D7BF5` |
| 中性 | `grey50` ~ `grey900` | 10 级灰度 |
| 语义 | `success` / `warning` / `error` / `info` + `*Light` | 成功/警告/错误/信息 |
| 背景 | `background` / `surface` / `divider` / `scrim` | 页面/卡片/分割线 |

### 间距 (AppSpacing)

| Token | 值 | 用途 |
|---|---|---|
| `xs` / `sm` / `smd` / `md` / `lg` / `xl` / `xxl` | 4 / 8 / 12 / 16 / 24 / 32 / 48 | 通用间距 |
| `pagePadding` | 16 | 页面水平边距 |
| `pageTopPadding` / `pageBottomPadding` | 12 / 24 | 页面顶部/底部 |
| `radiusSm` ~ `radiusFull` | 4 / 8 / 12 / 16 / 24 / 999 | 圆角 |

### 字体 (AppTextStyles / AppFontSize / AppFontWeight)

| TextStyle | 字号 | 字重 | 用途 |
|---|---|---|---|
| `displayLg` | 34 | bold | 大标题 |
| `headingLg/Md/Sm` | 30/26/22 | bold/semiBold | 页面标题 |
| `titleLg/Md` | 18/16 | semiBold | 区块标题 |
| `bodyLg/Md/Sm` | 16/14/12 | regular | 正文 |
| `labelLg/Md` | 14/12 | medium | 按钮/标签 |
| `caption` | 11 | regular | 辅助说明 |

### 使用

```dart
// 颜色
Container(color: AppColors.primary)
Icon(Icons.check, color: AppColors.success)

// 间距
Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding))
SizedBox(height: AppSpacing.md)
BorderRadius.circular(AppSpacing.radiusLg)

// 字体
Text('标题', style: AppTextStyles.titleLg)
Text('正文', style: AppTextStyles.bodyMd)

// Theme 方式（自动适配 dark mode）
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.bodyMedium
```

### 规范

- **禁止硬编码**颜色值（`Color(0xFF...)` / `Colors.xxx`）和间距（裸数字 `16`），统一使用 `AppColors` / `AppSpacing` token
- 装饰性渐变色等非语义色可例外保留
- `MaterialApp` 已接入 `AppTheme.light` / `AppTheme.dark`，`ColorScheme` 和 `TextTheme` 自动生效

---

## 本地持久化 (Hive)

### 依赖库

| 库 | 用途 |
|---|---|
| `hive_flutter: ^1.1.0` | 轻量级 key-value 本地数据库，Flutter 路径自动解析 |

### 目录结构

```
lib/core/storage/
├── storage_service.dart    # StorageService 封装 + storageServiceProvider
├── boxes/
│   └── box_keys.dart       # Box 名称常量（BoxKeys）+ Key 常量（AppKeys）
└── storage.dart            # barrel export
```

### 初始化

在 `lib/main_common.dart` 中完成全局初始化，通过 `ProviderScope.overrides` 注入：

```dart
await Hive.initFlutter();
final appBox = await Hive.openBox(BoxKeys.app);
runApp(ProviderScope(
  overrides: [
    storageServiceProvider.overrideWithValue(StorageService(appBox)),
  ],
  child: const App(),
));
```

### 使用

```dart
import 'package:livhome/core/storage/storage.dart';

// 读取（有默认值）
final isDone = ref.read(storageServiceProvider).getOrDefault(AppKeys.onboardingDone, false);

// 写入
await ref.read(storageServiceProvider).put(AppKeys.themeMode, 'dark');

// 删除
await ref.read(storageServiceProvider).delete(AppKeys.locale);

// 检查是否存在
final exists = ref.read(storageServiceProvider).containsKey(AppKeys.locale);
```

### Box / Key 常量规范

新增业务数据时，在 `box_keys.dart` 中声明常量，**禁止硬编码字符串**：

```dart
// 新增业务域 box（大量数据）
abstract final class BoxKeys {
  static const String app = 'app';
  static const String user = 'user'; // 新增
}

// 对应 key 常量类
abstract final class UserKeys {
  static const String profile = 'profile';
}
```

新增 box 时，在 `main_common.dart` 对应打开并注入新的 `Provider`。

---

## 认证 (Supabase Auth)

### 依赖库

| 库 | 用途 |
|---|---|
| `supabase_flutter: ^2.12.0` | Supabase 官方 Flutter SDK（Auth + Database + Storage + Realtime） |

### 目录结构

```
lib/core/supabase/
├── supabase_client.dart            # supabaseProvider (Provider<SupabaseClient>)
├── auth/
│   ├── auth_repository.dart        # 封装 auth 操作 + authRepositoryProvider
│   └── auth_state_provider.dart    # 响应式状态 authStateProvider / currentUserProvider
└── supabase.dart                   # barrel export
```

### 初始化

在 `lib/main_common.dart` 中完成全局初始化（PKCE 流程，适合移动端）：

```dart
await Supabase.initialize(
  url: F.supabaseUrl,
  anonKey: F.supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
);
```

### 使用

```dart
import 'package:livhome/core/supabase/supabase.dart';

// 监听登录状态（响应式）
final authAsync = ref.watch(authStateProvider);

// 获取当前用户
final user = ref.watch(currentUserProvider);

// 登录
await ref.read(authRepositoryProvider).signInWithPassword(
  email: 'user@example.com',
  password: 'password',
);

// 登出
await ref.read(authRepositoryProvider).signOut();
```

### Token 与 Dio 集成

`AuthInterceptor` 已接入 Supabase，自动从 `currentSession` 注入 Bearer token，401 时触发 `refreshSession()` 重试，无需手动管理 token。

### 凭证配置

三个 `.env.*` 文件中填写相同的值（三 Flavor 共用同一 Supabase Project）：

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

修改后执行代码生成：
```bash
dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
```

---

## 网络请求 (Retrofit + Dio)

### 依赖库

| 库 | 用途 |
|---|---|
| `dio: ^5.7.0` | HTTP 客户端 |
| `retrofit: ^4.9.2` | 类型安全的 REST 客户端（代码生成） |
| `json_annotation: ^4.11.0` | JSON 序列化注解 |
| `retrofit_generator: ^10.2.3` | Retrofit 代码生成器 (dev) |
| `json_serializable: ^6.8.0` | JSON 序列化代码生成器 (dev) |

### 目录结构

```
lib/core/network/
├── client/
│   ├── dio_client.dart            # Dio 实例 + 拦截器注册
│   ├── api_exception.dart         # 统一异常类
│   ├── base_response.dart         # 通用响应包装 BaseResponse<T>
│   └── result.dart                # Result<T> sealed class + apiCall 助手
├── interceptors/
│   ├── retry_interceptor.dart     # 幂等请求重试（超时/5xx）
│   ├── auth_interceptor.dart      # token 注入 + 过期刷新（QueuedInterceptor）
│   ├── log_interceptor.dart       # 日志（非 prod）
│   └── error_interceptor.dart     # DioException → ApiException
├── api/
│   └── <domain>/
│       ├── <domain>_api.dart      # @RestApi 接口定义
│       └── model/                 # 该域的 Request/Response 模型
└── network.dart                   # barrel export
```

### 拦截器链

`Retry → Auth → Log → [请求发出] → Error`

### 使用

```dart
// 1. 定义 API（api/<domain>/<domain>_api.dart）
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  @GET('/user/profile')
  Future<UserInfo> getProfile();
}

// 2. 定义 Model（api/<domain>/model/）
@JsonSerializable()
class UserInfo {
  const UserInfo({required this.id, required this.name});
  final int id;
  final String name;
  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

// 3. 注册 Provider
final userApiProvider = Provider<UserApi>((ref) => UserApi(ref.watch(dioProvider)));

// 4. ViewModel 中调用
final result = await apiCall(() => ref.read(userApiProvider).getProfile());
switch (result) {
  case Success(:final data): // 处理数据
  case Failure(:final exception): // 处理异常
}
```

### 新增业务域步骤

1. `lib/core/network/api/` 下新建 `<domain>/` 目录
2. 创建 `<domain>_api.dart`（`@RestApi()` 注解）
3. 创建 `model/` 放 Request/Response 类（`@JsonSerializable()`）
4. 运行 `dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs`
5. 在 `network.dart` 中 export 新 API
6. 更新 README

---

## 日志 (Logger)

### 依赖库

| 库 | 用途 |
|---|---|
| `logger: ^2.6.2` | 控制台格式化日志输出 |

### 目录结构

```
lib/logger/
├── log.dart    # 统一日志门面 Log.d/i/w/e
└── logger.dart # barrel 导出
```

### 使用

```dart
import 'package:livhome/logger/logger.dart';

Log.d('调试信息');
Log.i('普通信息');
Log.w('警告信息');
Log.e('错误信息', error, stackTrace);
```

### 环境差异

| 配置项 | dev / preview | prod |
|---|---|---|
| 控制台日志 | 开启 | 关闭 |

---

## 多语言 (flutter_i18n)

### 依赖库

| 库 | 用途 |
|---|---|
| `flutter_i18n: ^0.37.1` | JSON 文件驱动的多语言方案 |
| `flutter_localizations` (SDK) | Material/Cupertino 本地化代理 |

### 目录结构

```
assets/flutter_i18n/
├── zh_CN.json   # 中文（默认回退语言）
└── en.json      # 英文

lib/i18n/
├── s.dart       # S 快捷访问类
└── i18n.dart    # barrel 导出
```

### 配置

`FlutterI18nDelegate` 已集成在 `lib/app/app.dart` 的 `MaterialApp.router` 中：
- `fallbackFile`: `zh_CN`
- `supportedLocales`: `zh_CN`, `en`
- `builder`: `FlutterI18n.rootAppBuilder()` 确保翻译加载完成后再渲染

### 使用

```dart
import 'package:livhome/i18n/i18n.dart';

// 基础翻译
S.of(context, 'home.input_hint')

// 带参数
S.of(context, 'greeting', args: {'name': 'LivHome'})

// 复数
S.plural(context, 'message.count', 5)

// 切换语言
S.switchLocale(context, const Locale('en'))
```

### 新增语言步骤

1. 在 `assets/flutter_i18n/` 下新建 `<locale>.json`（如 `ja.json`）
2. 在 `lib/app/app.dart` 的 `supportedLocales` 中添加 `Locale('ja')`
3. 热重启生效

---

## 路由管理 (go_router)

### 依赖库

| 库 | 用途 |
|---|---|
| `go_router: ^17.1.0` | 声明式路由，基于 Router API |

### 路由表

定义在 `lib/app/router/app_router.dart`，路由常量在 `route_names.dart`：

| 路径 | 页面 | 说明 |
|---|---|---|
| `/` | `HomePage` | 首页 |
| `/test` | `TestPage` | 测试页面（计数器） |
| `/unimp-demo` | `UniMPDemoPage` | UniMP 小程序测试 |

### 使用

```dart
import 'package:go_router/go_router.dart';
import 'package:livhome/app/router/route_names.dart';

// 跳转（可返回）
context.push(RouteName.test);

// 跳转（替换当前页）
context.go(RouteName.test);
```

### 新增路由步骤

1. 在 `lib/pages/` 下按 MVVM 三文件模式创建页面
2. 在 `lib/app/router/route_names.dart` 中添加路由常量
3. 在 `lib/app/router/app_router.dart` 中添加 `GoRoute`
4. 更新国际化 JSON 文件

---

## 状态管理 (Riverpod)

### 依赖库

| 库 | 用途 |
|---|---|
| `flutter_riverpod: ^2.6.1` | 响应式状态管理 |

### 架构

采用 MVVM 模式，每个页面由三个文件组成：

```
lib/pages/<feature>/
├── <feature>_page.dart         # View 层 (ConsumerStatefulWidget)
├── <feature>_state.dart        # State 数据类 (immutable + copyWith)
└── <feature>_view_model.dart   # ViewModel (Notifier)
```

### 使用

```dart
// 定义 State
class HomeState {
  const HomeState({this.isSidebarOpen = false});
  final bool isSidebarOpen;
  HomeState copyWith({bool? isSidebarOpen}) =>
      HomeState(isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen);
}

// 定义 ViewModel
class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();
  void toggleSidebar() =>
      state = state.copyWith(isSidebarOpen: !state.isSidebarOpen);
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

// 在 View 中使用
class HomePage extends ConsumerStatefulWidget { ... }
// 读取状态
ref.watch(homeViewModelProvider)
// 调用方法
ref.read(homeViewModelProvider.notifier).toggleSidebar()
```

---

## 新建页面

### 步骤

1. 在 `lib/pages/` 下新建 `<feature>/` 目录
2. 创建三个文件：

```
lib/pages/<feature>/
├── <feature>_page.dart
├── <feature>_state.dart
└── <feature>_view_model.dart
```

3. `_state.dart` — 定义 immutable 数据类 + `copyWith`
4. `_view_model.dart` — 继承 `Notifier<XxxState>`，声明 `NotifierProvider`
5. `_page.dart` — 继承 `ConsumerStatefulWidget`，通过 `ref.watch/read` 接入状态
6. 在 `lib/app/router/app_router.dart` 中注册路由

---

## 资源命名规范 (Assets Naming Convention)

### 目录结构

```
assets/
├── flutter_i18n/          # 国际化翻译文件（已有）
├── images/                # 图片资源（png/jpg/webp/svg）
│   ├── common/            # 全局通用（logo、占位图、空状态等）
│   ├── <feature>/         # 按功能模块划分（home/login/settings…）
│   └── icons/             # 图标资源
├── animations/            # Lottie/Rive 动画文件
├── fonts/                 # 自定义字体
└── raw/                   # 其他原始资源（json/txt/pdf…）
```

### 命名规则（强制）

| 规则 | 说明 | 正确示例 | 错误示例 |
|---|---|---|---|
| **snake_case** | 全小写 + 下划线分隔 | `user_avatar.png` | `userAvatar.png`、`User-Avatar.png` |
| **禁止中文/空格/特殊字符** | 仅允许 `a-z`、`0-9`、`_` | `home_banner.jpg` | `首页横幅.jpg`、`home banner.jpg` |
| **语义化命名** | 名称体现用途而非外观 | `btn_submit.svg` | `blue_round_button.svg` |
| **模块前缀（可选）** | 跨模块易混淆时加前缀 | `login_bg.png` | `bg.png`（多模块都有时歧义） |
| **尺寸/变体后缀** | 多尺寸用后缀区分 | `logo_small.png`、`logo_large.png` | `logo2.png`、`logo_copy.png` |
| **状态变体后缀** | 不同状态用后缀区分 | `ic_star_filled.svg`、`ic_star_outline.svg` | `ic_star2.svg` |

### 完整命名模板

```
<用途>_<变体/状态>.<扩展名>

图片：  bg_home.png / ic_arrow_right.svg / img_empty_state.webp
动画：  anim_loading.json / anim_success.json
字体：  roboto_regular.ttf / roboto_bold.ttf
图标：  ic_home.svg / ic_settings_filled.svg
```

### 常用前缀约定

| 前缀 | 含义 | 示例 |
|---|---|---|
| `ic_` | 图标 (icon) | `ic_close.svg` |
| `img_` | 图片 (image) | `img_onboarding_step1.png` |
| `bg_` | 背景 (background) | `bg_login.png` |
| `btn_` | 按钮图片资源 | `btn_google_sign_in.png` |
| `anim_` | 动画文件 | `anim_splash.json` |
| `logo_` | Logo 标识 | `logo_app.svg` |
| `avatar_` | 头像/占位头像 | `avatar_default.png` |
| `placeholder_` | 占位图 | `placeholder_image.webp` |

---

## 共享模块 (shared)

### 依赖库

| 库 | 用途 |
|---|---|
| `cached_network_image: ^3.4.1` | 网络图片加载与缓存 |

### 目录结构

```
lib/shared/
├── widgets/
│   ├── buttons/
│   │   └── app_button.dart        # 通用按钮（loading 状态、自定义样式）
│   ├── inputs/
│   │   └── app_text_field.dart    # 通用输入框（FormField 集成）
│   ├── images/
│   │   └── app_image.dart         # 网络图片（CachedNetworkImage 封装）
│   ├── navigation/
│   │   └── app_navigation_bar.dart # 顶部导航栏（PreferredSizeWidget）
│   └── shared_widgets.dart        # barrel export
├── utils/
│   ├── validators.dart            # 通用校验（邮箱/手机号/URL/长度）
│   ├── formatters.dart            # 格式化（日期/数字/文件大小）
│   └── utils.dart                 # barrel export
└── shared.dart                    # 顶层 barrel export
```

### 使用

```dart
import 'package:livhome/shared/shared.dart';

// 按钮
AppButton(onPressed: () {}, child: Text('提交'))

// 输入框
AppTextField(hintText: '请输入', validator: (v) => Validators.isEmail(v ?? '') ? null : '格式错误')

// 网络图片
AppImage(url: 'https://example.com/img.jpg', width: 100, height: 100)

// 顶部导航栏（强制使用，严禁直接使用原生 AppBar）
Scaffold(
  appBar: AppNavigationBar(title: '页面标题'),               // 基础用法
)
Scaffold(
  appBar: AppNavigationBar(
    title: '设置',
    actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
  ),
)
Scaffold(
  appBar: AppNavigationBar(
    title: '渐变页',
    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
    foregroundColor: AppColors.surface,
  ),
)

// 校验
Validators.isPhone('13800138000') // true

// 格式化
Formatters.date(DateTime.now())       // 2026-03-11
Formatters.compact(12345)             // 1.2万
Formatters.fileSize(1048576)          // 1.0MB
```

---

## UniMPSDK (uni 小程序引擎)

### 依赖

| 平台 | 方式 | 版本 |
|---|---|---|
| Android | 本地 AAR（`android/app/libs/`） | SDK 4.85 |
| iOS | CocoaPods（`pod 'unimp'`） | SDK 4.75 |

> **重要**：HBuilderX 打包版本须与 SDK 版本严格一致，否则小程序无法运行。

### 架构

```
Flutter (Dart)
  └─ MethodChannel("UniMP_mini_apps")
       ├─ Android: MainActivity.java → DCUniMPSDK
       └─ iOS: AppDelegate.swift → DCUniMPSDKEngine
```

### 目录结构

```
lib/core/unimp/
├── unimp_service.dart    # MethodChannel 封装 + 远程下载安装
└── unimp.dart            # barrel export

android/app/
├── libs/                 # UniMPSDK AAR 依赖
├── src/main/assets/
│   ├── data/             # SDK 配置（dcloud_control.xml 等）
│   └── apps/             # 小程序资源（__UNI__xxx/www/）
└── proguard.cfg          # SDK 混淆规则

lib/pages/unimp_demo/     # 测试页面（MVVM 三文件）
```

### 使用方式一：本地内置小程序

适用于随 App 一起发布、不需要动态更新的小程序。

**步骤**：
1. 用 HBuilderX 打包 uni-app 项目（发行 → 原生App-本地打包 → 生成本地打包App资源）
2. 将输出的 `__UNI__xxx/www/` 放入 `android/app/src/main/assets/apps/`
3. 在 `assets/data/dcloud_control.xml` 中注册 appid：
   ```xml
   <hbuilder><apps><app appid="__UNI__xxx" appver="" /></apps></hbuilder>
   ```
4. iOS：将 `.wgt` 文件拖入 Xcode 的 Runner Bundle Resources

**代码**：
```dart
import 'package:livhome/core/unimp/unimp.dart';

// 打开本地小程序
await UniMPService.open('__UNI__xxx');

// 检查是否已安装
final exists = await UniMPService.checkExists('__UNI__xxx');

// 获取版本
final version = await UniMPService.getVersion('__UNI__xxx');

// 关闭小程序
await UniMPService.close('__UNI__xxx');
```

### 使用方式二：远程下载安装小程序

适用于动态下发、热更新场景。Dart 层通过 Dio 下载 wgt 到临时目录，再调用原生 SDK 安装。

**步骤**：
1. 用 HBuilderX 打包 uni-app 项目（发行 → 原生App-制作应用wgt包）
2. 将生成的 `.wgt` 文件上传到服务器（OSS/CDN 等）
3. App 中调用 `downloadAndInstall` 即可

**代码**：
```dart
import 'package:livhome/core/unimp/unimp.dart';

// 一键下载 + 安装 + 打开（支持进度回调与取消）
await UniMPService.downloadAndInstall(
  'https://example.com/app.wgt',
  appId: '__UNI__xxx',
  onProgress: (progress) => print('${(progress * 100).toFixed(0)}%'),
  cancelToken: cancelToken,  // 可选，用于取消下载
  autoOpen: true,            // 安装后自动打开，默认 true
);

// 取消下载
cancelToken.cancel();
```

**特性**：
- 下载进度实时回调（0.0 ~ 1.0）
- 支持 `CancelToken` 中途取消
- 下载完成自动清理临时文件
- 安装后默认自动打开小程序
- 异常统一抛出 `UniMPException`

### 手动分步安装（高级）

如需自行控制下载流程，可单独调用 `install`：

```dart
// 手动下载 wgt 到本地路径后
await UniMPService.install('__UNI__xxx', '/path/to/downloaded.wgt');
await UniMPService.open('__UNI__xxx');
```

### SDK 升级步骤

1. 从 [DCloud 官网](https://nativesupport.dcloud.net.cn/UniMPDocs/SDKDownload/android) 下载对应版本 SDK
2. 替换 `android/app/libs/` 中的 AAR 文件
3. 替换 `android/app/src/main/assets/data/` 中的配置文件
4. 更新 `android/app/proguard.cfg`
5. 对照 DEMO 的 `build.gradle` 检查依赖版本是否有变化
6. 同步升级 HBuilderX 到相同版本，重新打包小程序

---

## 测试 (Testing & TDD)

### 依赖库

| 库 | 用途 |
|---|---|
| `flutter_test` (SDK) | Flutter 官方测试框架 |
| `mocktail: ^1.0.4` | 无代码生成的 Mock 框架（`Mock`、`Fake`、`when`、`verify`） |

### 目录结构

```
test/
├── helpers/
│   ├── mocks.dart           # 集中声明所有 Mock/Fake 类
│   └── test_helpers.dart    # initTestEnv() + createContainer()
├── core/
│   ├── network/
│   │   ├── api_exception_test.dart
│   │   └── result_test.dart
│   ├── storage/
│   │   └── storage_service_test.dart
│   └── supabase/auth/
│       └── auth_repository_test.dart
└── pages/
    ├── home/
    │   ├── home_state_test.dart
    │   └── home_view_model_test.dart
    └── test/
        ├── test_state_test.dart
        └── test_view_model_test.dart
```

`test/` 目录结构**镜像** `lib/`，每个被测文件对应 `_test.dart` 后缀。

### 测试辅助

**`test/helpers/mocks.dart`** — 集中管理所有 Mock 和 Fake：

```dart
class MockAuthRepository extends Mock implements AuthRepository {}
class MockWebsiteApi extends Mock implements WebsiteApi {}
class MockBox extends Mock implements Box {}
class FakeAuthResponse extends Fake implements AuthResponse {}
class FakeUser extends Fake implements User {
  @override String get id => 'test-uid-123';
  @override String get email => 'test@example.com';
}
```

**`test/helpers/test_helpers.dart`** — 环境初始化与容器工厂：

```dart
void initTestEnv() {
  // 幂等：设置 Flavor + 初始化 Logger，避免 LateInitializationError
  F.appFlavor = Flavor.dev;
  Log.init();
}

ProviderContainer createContainer({List<Override> overrides = const []}) {
  return ProviderContainer(overrides: overrides);
}
```

### TDD 工作流（强制）

所有新功能开发遵循 **Red → Green → Refactor** 循环：

1. **Red** — 先写失败测试，明确期望行为
2. **Green** — 写最少代码让测试通过
3. **Refactor** — 优化实现，保持测试绿色

### 运行测试

```bash
# 运行全部测试
flutter test

# 运行单个测试文件
flutter test test/pages/home/home_view_model_test.dart

# 运行匹配名称的测试
flutter test --name "switchTab"
```

### 编写规范

- **命名**：测试文件以 `_test.dart` 结尾；`group()` 按类/方法分组；`test()` 描述期望行为
- **环境**：ViewModel 测试的 `setUp()` 中调用 `initTestEnv()`（含 Logger 初始化）
- **容器**：通过 `createContainer(overrides: [...])` 注入 Mock 依赖，`tearDown()` 中 `dispose()`
- **Mock 模式**：`when(() => mock.method()).thenAnswer/thenReturn/thenThrow`；调用后 `verify().called(1)`
- **新增 Mock**：统一在 `test/helpers/mocks.dart` 中声明，禁止在测试文件中散落定义
