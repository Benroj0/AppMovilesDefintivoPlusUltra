import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle brandName = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle textLink = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 16.0, // Aumentado de 14.0 a 16.0
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle largeBrandName = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 36.0, // Más grande que screenTitle (32.0)
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark, // Verde teal oscuro de la paleta
    letterSpacing: 0.5,
    shadows: [Shadow(color: Colors.white, offset: Offset(1, 1), blurRadius: 2)],
  );

  static const TextStyle googleButton = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'SansSerif',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
