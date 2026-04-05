import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/theme.dart';
import '../../i18n/i18n.dart';
import '../device/device_page.dart';
import '../profile/profile_page.dart';
import 'home_view_model.dart';

// 常量配置 - 根据 Figma 设计稿 node-id=4758-1988
class _NavConst {
  // 装饰性渐变色
  static const List<Color> selectedGradient = [
    Color(0xFF6A9BFA),
    Color(0xFFCB8DEA),
  ];
  static const Color unselectedColor = Color(0xFF7B7C7E);

  // 尺寸配置
  static const double navBarHeight = 83.0;
  static const double curveHeight = 18.0;
  static const double curveWidth = 120.0;
  static const double centerButtonSize = 44.0;
  static const double horizontalPadding = 43.0;
  static const double iconSize = 28.0;
  static const double touchAreaSize = 48.0;
}

// 导航栏凸起背景绘制器
class _NavBarNotchPainter extends CustomPainter {
  final Color color;
  const _NavBarNotchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    const halfW = _NavConst.curveWidth / 2;

    path.moveTo(0, size.height);
    path.lineTo(0, _NavConst.curveHeight);
    path.lineTo(cx - halfW, _NavConst.curveHeight);

    path.cubicTo(
      cx - halfW * 0.5, _NavConst.curveHeight,
      cx - halfW * 0.3, 0,
      cx, 0,
    );
    path.cubicTo(
      cx + halfW * 0.3, 0,
      cx + halfW * 0.5, _NavConst.curveHeight,
      cx + halfW, _NavConst.curveHeight,
    );

    path.lineTo(size.width, _NavConst.curveHeight);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 导航项数据模型
class _NavItem {
  final String selectedAsset;
  final String unselectedAsset;
  final String labelKey;
  final int index;

  const _NavItem({
    required this.selectedAsset,
    required this.unselectedAsset,
    required this.labelKey,
    required this.index,
  });
}

const _navItems = [
  _NavItem(
    selectedAsset: 'assets/images/navigation/home_selected.svg',
    unselectedAsset: 'assets/images/navigation/home_unselected.svg',
    labelKey: 'nav.device',
    index: 0,
  ),
  _NavItem(
    selectedAsset: 'assets/images/navigation/me_selected.svg',
    unselectedAsset: 'assets/images/navigation/me_unselected.svg',
    labelKey: 'nav.profile',
    index: 2,
  ),
];

// ---------- HomePage ----------

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chatBtnAnimCtrl;
  late final Animation<double> _chatBtnScaleAnim;

  final _pages = const <Widget>[
    DevicePage(),
    _ChatTab(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _chatBtnAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _chatBtnScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 1),
    ]).animate(_chatBtnAnimCtrl);
  }

  @override
  void dispose() {
    _chatBtnAnimCtrl.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    ref.read(homeViewModelProvider.notifier).switchTab(index);
  }

  void _onCenterTapped() {
    _chatBtnAnimCtrl.forward(from: 0);
    _onItemTapped(1);
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: homeState.selectedIndex,
              children: _pages,
            ),
          ),
          _buildNavigationBar(context, homeState.selectedIndex),
        ],
      ),
    );
  }

  // 构建导航栏 - 根据 Figma 设计稿 node-id=4758-1988
  Widget _buildNavigationBar(BuildContext context, int selectedIndex) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: _NavConst.navBarHeight + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 带凸起的白色背景
          Positioned.fill(
            child: CustomPaint(
              painter: _NavBarNotchPainter(color: AppColors.surface),
            ),
          ),
          // 中心凸起的 Chat 按钮
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCenterButton(selectedIndex),
            ),
          ),
          // 左右导航项
          Positioned(
            top: _NavConst.curveHeight + 10,
            left: _NavConst.horizontalPadding,
            right: _NavConst.horizontalPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(context, _navItems[0], selectedIndex),
                const SizedBox(width: _NavConst.curveWidth),
                _buildNavItem(context, _navItems[1], selectedIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 中心按钮 - 凸起的圆形按钮 + 缩放动画
  Widget _buildCenterButton(int selectedIndex) {
    final bool isSelected = selectedIndex == 1;

    return GestureDetector(
      onTap: _onCenterTapped,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _chatBtnScaleAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _chatBtnScaleAnim.value,
                child: child,
              );
            },
            child: SizedBox(
              width: _NavConst.centerButtonSize,
              height: _NavConst.centerButtonSize,
              child: Opacity(
                opacity: 0.80,
                child: Image.asset(
                  'assets/images/navigation/chat_center.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildGradientLabel(
            context,
            'nav.chat',
            isSelected,
            fontSize: AppFontSize.sm,
            fontWeight: AppFontWeight.semiBold,
          ),
        ],
      ),
    );
  }

  // 构建导航项 - 根据 Figma 设计稿 node-id=4758-1988
  Widget _buildNavItem(
    BuildContext context,
    _NavItem navItem,
    int selectedIndex,
  ) {
    final bool isSelected = selectedIndex == navItem.index;
    final assetPath =
        isSelected ? navItem.selectedAsset : navItem.unselectedAsset;

    return GestureDetector(
      onTap: () => _onItemTapped(navItem.index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 触摸区域 + 图标
          SizedBox(
            width: _NavConst.touchAreaSize,
            height: _NavConst.touchAreaSize,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SvgPicture.asset(
                  assetPath,
                  width: _NavConst.iconSize,
                  height: _NavConst.iconSize,
                ),
              ),
            ),
          ),
          // 文本 - 独立于触摸区域，可以超出宽度
          Positioned(
            top: _NavConst.touchAreaSize - 16,
            child: SizedBox(
              width: 120,
              child: _buildGradientLabel(
                context,
                navItem.labelKey,
                isSelected,
                fontSize: AppFontSize.sm,
                fontWeight: AppFontWeight.medium,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientLabel(
    BuildContext context,
    String labelKey,
    bool isSelected, {
    required double fontSize,
    required FontWeight fontWeight,
    int maxLines = 1,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        if (isSelected) {
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _NavConst.selectedGradient,
          ).createShader(bounds);
        }
        return const LinearGradient(
          colors: [_NavConst.unselectedColor, _NavConst.unselectedColor],
        ).createShader(bounds);
      },
      child: Text(
        S.of(context, labelKey),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: 'Inter',
          color: AppColors.surface,
          height: isSelected ? 1.0 : 1.2,
        ),
        textAlign: TextAlign.center,
        maxLines: maxLines,
      ),
    );
  }
}

// ---------- 聊天 Tab（原 HomePage 内容） ----------

class _ChatTab extends ConsumerStatefulWidget {
  const _ChatTab();

  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            Positioned.fill(child: _buildGradientBackground()),
            Positioned.fill(
              child: SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(child: _buildMessageList()),
                    _buildInputArea(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(
        top: 15,
        bottom: 15,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAppBarButton(
            icon: Icons.menu_rounded,
            onTap: () => context.push(RouteName.test),
          ),
          const Spacer(),
          Row(
            children: [
              _buildAppBarButton(
                icon: Icons.widgets_rounded,
                onTap: () => context.push(RouteName.unimpDemo),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildAppBarButton(
                icon: Icons.add_comment_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(icon, size: 22, color: AppColors.grey700),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -190,
          left: -240,
          child: _buildRadialGlow(400, const Color(0xFFB8E8E8), 1.0),
        ),
        Positioned(
          top: 0,
          left: -180,
          child: _buildRadialGlow(450, const Color(0xFFC5D8F0), 1.0),
        ),
        Positioned(
          top: -390,
          left: 100,
          child: _buildRadialGlow(720, const Color(0xFFE8E0F8), 1.0),
        ),
        Positioned(
          top: 150,
          right: -150,
          child: _buildRadialGlow(320, const Color(0xFFF8F5E8), 0.45),
        ),
        Positioned(
          top: 200,
          left: -60,
          child: _buildRadialGlow(320, const Color(0xFFD0E5F8), 0.75),
        ),
      ],
    );
  }

  Widget _buildRadialGlow(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
    );
  }

  Widget _buildInputArea() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.smd,
        AppSpacing.pagePadding,
        bottomPadding + AppSpacing.smd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXxl),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: S.of(context, 'home.input_hint'),
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.grey400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.smd,
                  ),
                ),
                style: AppTextStyles.bodyMd,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
