import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Colores Principales ---
  static const Color primary = Color(0xFF4DB6AC); // Verde teal principal
  static const Color primaryLight = Color(0xFF80CBC4); // Verde teal claro
  static const Color primaryDark = Color(0xFF00695C); // Verde teal oscuro
  static const Color accent = Color(0xFFFF9800); // Naranja brillante
  static const Color accentLight = Color(0xFFFFB74D); // Naranja claro

  // --- Colores de Branding ---
  static const Color tealGradientStart = Color(0xFF4DB6AC);
  static const Color tealGradientEnd = Color(0xFF80CBC4);
  static const Color circleAccent = Color(0xFFFF9800);

  // --- Colores de UI Neutros ---
  static const Color background = Color(0xFFFAFAFA); // Blanco muy suave
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // Blanco puro para tarjetas
  static const Color textPrimary = Color(0xFF4DB6AC); // Verde teal para títulos
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Gris para texto secundario
  static const Color textHint = Color(0xFFBDBDBD); // Gris claro para hints
  static const Color inputBorder = Color(0xFFE0E0E0); // Gris claro neutro
  static const Color inputFocused = Color(
    0xFF4DB6AC,
  ); // Verde teal para input focused

  // --- Estados ---
  static const Color error = Color(0xFFE53935); // Rojo para errores
  static const Color success = Color(0xFF43A047); // Verde para éxito
  static const Color warning = Color(0xFFFF9800); // Naranja para advertencias

  // --- Botones ---
  static const Color googleButton = Color(0xFF4285F4); // Azul de Google
  static const Color orangeButton = Color(
    0xFFFF9800,
  ); // Naranja para botón principal
}
