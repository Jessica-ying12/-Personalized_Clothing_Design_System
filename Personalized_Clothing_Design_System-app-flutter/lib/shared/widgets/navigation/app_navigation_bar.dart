import 'package:flutter/material.dart';

class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavigationBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.useSafeArea = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final bool useSafeArea;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final hasGradient = gradient != null;

    final effectiveLeading = leading ?? _buildDefaultLeading(context);

    final appBar = AppBar(
      leading: effectiveLeading,
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      backgroundColor: hasGradient ? Colors.transparent : backgroundColor,
      foregroundColor: foregroundColor,
      elevation: hasGradient ? 0 : null,
    );

    if (!hasGradient) return appBar;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: useSafeArea,
        child: appBar,
      ),
    );
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBackButton) return null;

    final route = ModalRoute.of(context);
    final canPop = route?.canPop ?? false;
    if (!canPop) return null;

    return IconButton(
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
    );
  }
}
