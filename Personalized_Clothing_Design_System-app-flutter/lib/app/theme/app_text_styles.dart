import 'package:flutter/material.dart';

abstract final class AppFontSize {
  static const double xs      = 11;
  static const double sm      = 12;
  static const double md      = 14;
  static const double lg      = 16;
  static const double xl      = 18;
  static const double xxl     = 20;
  static const double h3      = 22;
  static const double h2      = 26;
  static const double h1      = 30;
  static const double display = 34;
}

abstract final class AppFontWeight {
  static const FontWeight regular  = FontWeight.w400;
  static const FontWeight medium   = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold     = FontWeight.w700;
}

abstract final class AppTextStyles {
  static const TextStyle displayLg = TextStyle(
    fontSize: AppFontSize.display, fontWeight: AppFontWeight.bold, height: 1.2,
  );

  static const TextStyle headingLg = TextStyle(
    fontSize: AppFontSize.h1, fontWeight: AppFontWeight.bold, height: 1.3,
  );
  static const TextStyle headingMd = TextStyle(
    fontSize: AppFontSize.h2, fontWeight: AppFontWeight.semiBold, height: 1.3,
  );
  static const TextStyle headingSm = TextStyle(
    fontSize: AppFontSize.h3, fontWeight: AppFontWeight.semiBold, height: 1.35,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: AppFontSize.xl, fontWeight: AppFontWeight.semiBold, height: 1.4,
  );
  static const TextStyle titleMd = TextStyle(
    fontSize: AppFontSize.lg, fontWeight: AppFontWeight.semiBold, height: 1.4,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: AppFontSize.lg, fontWeight: AppFontWeight.regular, height: 1.6,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: AppFontSize.md, fontWeight: AppFontWeight.regular, height: 1.6,
  );
  static const TextStyle bodySm = TextStyle(
    fontSize: AppFontSize.sm, fontWeight: AppFontWeight.regular, height: 1.5,
  );

  static const TextStyle labelLg = TextStyle(
    fontSize: AppFontSize.md, fontWeight: AppFontWeight.medium, height: 1.4,
  );
  static const TextStyle labelMd = TextStyle(
    fontSize: AppFontSize.sm, fontWeight: AppFontWeight.medium, height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppFontSize.xs, fontWeight: AppFontWeight.regular, height: 1.4,
  );
}
