import 'package:flutter/material.dart';

class AppConstants {
  // Colors - Enhanced Neon Palette for Idle Game Vibe
  static const Color primaryColor = Color(0xFF7C4DFF);       // Deep Purple
  static const Color secondaryColor = Color(0xFFFF6B9D);    // Neon Pink
  static const Color accentColor = Color(0xFF00F5FF);       // Cyan Neon
  static const Color neonGreen = Color(0xFF39FF14);          // Electric Green
  static const Color neonOrange = Color(0xFFFF6B35);         // Neon Orange
  static const Color backgroundDark = Color(0xFF0D0D1A);     // Darker Background
  static const Color backgroundDarker = Color(0xFF080812);  // Even Darker
  static const Color surfaceColor = Color(0xFF1A1A2E);      // Card/Surface
  static const Color backgroundLight = Color(0xFFF8F9FA);
  
  // Glow colors for particle effects
  static const Color glowPurple = Color(0xFF9B6AFF);
  static const Color glowPink = Color(0xFFFF6B9D);
  static const Color glowCyan = Color(0xFF00F5FF);
  
  // Ball properties
  static const double ballRadius = 30.0;
  static const double ballSpeedMin = 150.0;
  static const double ballSpeedMax = 300.0;
  static const int initialBallsCount = 1;
  
  // Score settings
  static const int pointsPerTap = 10;
  static const double scoreMultiplierBase = 1.0;
  static const double maxScoreMultiplier = 5.0;
  
  // Physics settings
  static const double bounceDamping = 0.92;
  static const double wallBounceForce = 800.0;
  static const double gravity = 9.8;
  
  // Animation settings
  static const Duration tapAnimationDuration = Duration(milliseconds: 150);
  static const Duration ballSpawnDelay = Duration(milliseconds: 300);
  static const int particleCountPerTap = 8;
  
  // Layout
  static const double paddingStandard = 16.0;
  static const double buttonCornerRadius = 12.0;
}
