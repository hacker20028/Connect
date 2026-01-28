import 'package:flutter/material.dart';

class AppColors {
  // Modern Yellow/Orange Primary Colors
  static const Color primary = Color(0xFFFFB800);
  static const Color primaryLight = Color(0xFFFFD93D);
  static const Color primaryDark = Color(0xFFFF8C00);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8B5A);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFBF0);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkText = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB2BEB5);

  // Message Bubble Colors
  static const Color sentMessageLight = Color(0xFFFFB800);
  static const Color receivedMessageLight = Color(0xFFF1F3F4);
  static const Color sentMessageDark = Color(0xFFFF8C00);
  static const Color receivedMessageDark = Color(0xFF2A2A2A);

  // Status Colors
  static const Color online = Color(0xFF00D25B);
  static const Color offline = Color(0xFF636E72);
  static const Color typing = Color(0xFFFFD93D);

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFFD93D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8B5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}