import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color kPrimaryGreen = Color(0xFF047857); // Premium Emerald
  static const Color kPrimaryLight = Color(0xFFECFDF5); 
  static const Color kSecondaryGreen = Color(0xFF10B981); 
  static const Color kPrimaryBlue = Color(0xFF0F172A); 
  static const Color kAccentBlue = Color(0xFF3B82F6); 
  static const Color kAccentGold = Color(0xFFD97706); 
  
  // Light Theme Colors (Restored for compat, aliases to Light)
  static const Color kBackground = kBackgroundLight;
  static const Color kCardColor = kSurfaceLight; // Defaults to Light Surface
  static const Color kSurfaceColor = kSurfaceLight;
  
  static const Color kBackgroundLight = Color(0xFFF4F7F9);
  static const Color kSurfaceLight = Color(0xFFFFFFFF);
  static const Color kTextPrimaryLight = Color(0xFF1F2937);
  static const Color kTextSecondaryLight = Color(0xFF6B7280);

  // Compat Text Colors
  static const Color kTextPrimary = kTextPrimaryLight;
  static const Color kTextSecondary = kTextSecondaryLight;

  // Dark Theme Colors
  static const Color kBackgroundDark = Color(0xFF111827); // Dark Blue-Grey
  static const Color kSurfaceDark = Color(0xFF1F2937);    // Lighter Dark Blue-Grey
  static const Color kTextPrimaryDark = Color(0xFFF9FAFB); // Off-White
  static const Color kTextSecondaryDark = Color(0xFFD1D5DB); // Light Grey

  // Status
  static const Color kSuccess = Color(0xFF10B981);
  static const Color kWarning = Color(0xFFF59E0B);
  static const Color kError = Color(0xFFEF4444);
  static const Color kInfo = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [kPrimaryGreen, Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Compat Text Styles ---
  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kTextPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: kTextPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: kTextPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: kTextSecondary,
    height: 1.5,
    inherit: true,
  );

  // Helper for consistent TextStyles
  static TextStyle _style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      inherit: true,
    );
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: kPrimaryGreen,
      scaffoldBackgroundColor: kBackgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryGreen,
        primary: kPrimaryGreen,
        secondary: kSecondaryGreen,
        surface: kSurfaceLight,
        // background deprecated, mapped to surface/scaffoldBackground
        error: kError,
        brightness: Brightness.light,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: kSurfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: kTextSecondaryLight),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),

      iconTheme: const IconThemeData(
          color: kTextPrimaryLight,
          size: 24,
      ),

      textTheme: TextTheme(
        displayLarge: _style(fontSize: 28, fontWeight: FontWeight.bold, color: kTextPrimaryLight),
        titleLarge: _style(fontSize: 20, fontWeight: FontWeight.w600, color: kTextPrimaryLight),
        bodyLarge: _style(fontSize: 16, color: kTextPrimaryLight),
        bodyMedium: _style(fontSize: 14, color: kTextSecondaryLight),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: kPrimaryGreen,
      scaffoldBackgroundColor: kBackgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryGreen,
        primary: kPrimaryGreen,
        secondary: kSecondaryGreen,
        surface: kSurfaceDark,
        // background deprecated
        error: kError,
        brightness: Brightness.dark,
        onSurface: kTextPrimaryDark,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A), // Darker Header
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: kSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: kTextSecondaryDark),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),

      iconTheme: const IconThemeData(
        color: kTextPrimaryDark,
        size: 24,
      ),

      textTheme: TextTheme(
        displayLarge: _style(fontSize: 28, fontWeight: FontWeight.bold, color: kTextPrimaryDark),
        titleLarge: _style(fontSize: 20, fontWeight: FontWeight.w600, color: kTextPrimaryDark),
        bodyLarge: _style(fontSize: 16, color: kTextPrimaryDark),
        bodyMedium: _style(fontSize: 14, color: kTextSecondaryDark),
      ),
    );
  }
  
  // Helper to get correct Card color based on theme
  static Color getCardColor(bool isDark) => isDark ? kSurfaceDark : kSurfaceLight;
  static Color getTextColor(bool isDark) => isDark ? kTextPrimaryDark : kTextPrimaryLight;
  static Color getSecondaryTextColor(bool isDark) => isDark ? kTextSecondaryDark : kTextSecondaryLight;
}
