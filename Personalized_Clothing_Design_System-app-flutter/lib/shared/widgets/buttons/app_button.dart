import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8,
    this.isLoading = false,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor ?? theme.colorScheme.onPrimary,
                ),
              )
            : child,
      ),
    );
  }
}
