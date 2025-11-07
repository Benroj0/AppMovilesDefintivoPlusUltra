import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.background, Color(0xFFF0F0F0)],
        ),
      ),
      child: Stack(
        children: [
          // Círculo grande verde en la esquina superior derecha
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.tealGradientStart.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Círculo mediano verde claro
          Positioned(
            top: 50,
            right: 80,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.tealGradientEnd.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Círculo pequeño naranja
          Positioned(
            top: 140,
            right: 50,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.circleAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Círculo en la parte inferior izquierda
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Contenido principal
          child,
        ],
      ),
    );
  }
}
