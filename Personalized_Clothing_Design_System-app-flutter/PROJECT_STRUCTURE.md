# 个性化服装设计系统 - 项目结构

## 已创建的页面

### 1. 登录/注册页面 (LoginPage)
- 路径: `lib/pages/login/`
- 路由: `/login`
- 功能: 
  - 邮箱密码登录
  - 用户注册
  - 登录/注册模式切换

### 2. 主导航页面 (MainPage)
- 路径: `lib/pages/main/`
- 路由: `/main`
- 功能:
  - 底部导航栏，包含三个 Tab：定制、仓库、我的
  - 使用 IndexedStack 管理页面切换

### 3. 定制模块 - 平面图生成页面 (DesignFlatPage)
- 路径: `lib/pages/design_flat/`
- 路由: `/design-flat`
- 功能:
  - 左侧选项区：版型、花纹、材质、风格、受众人群、模型选择
  - 中央展示区：显示生成的平面图
  - 右侧详细选项区：根据当前步骤显示具体选项
  - 底部操作栏：重置、生成、进入立体图生成

### 4. 定制模块 - 立体图生成页面 (Design3dPage)
- 路径: `lib/pages/design_3d/`
- 路由: `/design-3d`
- 功能:
  - 左侧选项区：身体三维、肤色、性别、模型选择
  - 中央展示区：显示生成的立体图或平面图
  - 右侧控制面板：更换背景、切换视图、重新生成
  - 底部操作栏：返回上一步、生成立体图

### 5. 仓库页面 (GalleryPage)
- 路径: `lib/pages/gallery/`
- 路由: `/gallery`
- 功能:
  - Tab 切换：平面展示、立体展示
  - 网格布局展示设计作品
  - 点击查看详情：下载、重新生成、生成立体图

### 6. 我的页面 (ProfilePage)
- 路径: `lib/pages/profile/`
- 路由: `/profile`
- 功能:
  - 用户信息展示：头像、昵称、邮箱
  - 历史生成记录
  - 退出登录（带确认弹窗）
  - 注销账号（带确认弹窗）

## MVVM 架构

每个页面都遵循 MVVM 三文件模式：

1. `*_page.dart` - View 层，负责 UI 展示
2. `*_state.dart` - State 层，定义不可变状态类
3. `*_view_model.dart` - ViewModel 层，使用 Riverpod Notifier 管理状态

## 设计系统

项目使用统一的设计系统 Token：

- `AppColors` - 颜色定义
- `AppSpacing` - 间距定义
- `AppTextStyles` - 文本样式定义
- `AppFontSize` - 字体大小定义
- `AppFontWeight` - 字体粗细定义

## 国际化

支持中英文双语：
- 中文: `assets/flutter_i18n/zh_CN.json`
- 英文: `assets/flutter_i18n/en.json`

所有用户可见文本都使用 `FlutterI18n.translate(context, "key")` 进行国际化。

## 路由配置

使用 GoRouter 进行路由管理：
- 路由常量定义: `lib/app/router/route_names.dart`
- 路由配置: `lib/app/router/app_router.dart`
- 初始路由: `/login`

## 待实现功能

### 后端接口集成

所有页面的 ViewModel 中都标记了 `// TODO` 注释，需要接入后端 API：

1. **登录/注册**
   - `LoginViewModel.login()` - 登录接口
   - `LoginViewModel.register()` - 注册接口

2. **平面图生成**
   - `DesignFlatViewModel.generateFlatDesign()` - 生成平面图接口

3. **立体图生成**
   - `Design3dViewModel.generate3dDesign()` - 生成立体图接口
   - `Design3dViewModel.regenerate3d()` - 重新生成立体图接口

4. **仓库**
   - `GalleryViewModel.loadDesigns()` - 加载设计列表接口
   - `GalleryViewModel.downloadDesign()` - 下载设计接口
   - `GalleryViewModel.regenerateDesign()` - 重新生成接口
   - `GalleryViewModel.generate3dFromFlat()` - 从平面图生成立体图接口

5. **用户信息**
   - `ProfileViewModel.loadProfile()` - 加载用户信息接口
   - `ProfileViewModel.logout()` - 退出登录接口
   - `ProfileViewModel.deleteAccount()` - 注销账号接口
   - `ProfileViewModel.viewHistory()` - 查看历史记录接口

### UI 细节完善

1. **定制模块详细选项**
   - 需要根据后端数据结构完善版型、花纹、材质等的具体选项列表
   - 实现二次选项的展示和选择逻辑
   - 添加数值调整功能

2. **图片资源**
   - 添加应用图标
   - 添加占位图
   - 添加背景图资源

3. **错误处理**
   - 添加网络错误提示
   - 添加加载状态优化
   - 添加表单验证

## 后端项目路径

后端项目位于: `G:\biye\-Personalized_Clothing_Design_System\Personalized_Clothing_Design_System-backend-supabase`

需要查看后端 API 文档，了解接口定义和数据结构，然后在 Flutter 项目中实现对应的网络请求。

## 下一步工作

1. 查看后端 API 文档，了解接口定义
2. 创建 API Service 层，封装网络请求
3. 在 ViewModel 中调用 API Service
4. 完善 UI 细节和交互逻辑
5. 添加错误处理和加载状态
6. 测试完整流程
