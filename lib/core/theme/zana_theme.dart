import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zana_colors.dart';

class ZanaTheme {
  ZanaTheme._();

  static const String fontFamily = 'Vazirmatn';

  static ThemeData light(ZanaTab tab) {
    final p = ZanaColors.of(tab, isDark: false);
    return _build(p, Brightness.light);
  }

  static ThemeData dark(ZanaTab tab) {
    final p = ZanaColors.of(tab, isDark: true);
    return _build(p, Brightness.dark);
  }

  static ThemeData _build(ZanaPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: p.background,
      primaryColor: p.primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: ZanaColors.white,
        secondary: p.accent,
        onSecondary: isDark ? ZanaColors.black : ZanaColors.white,
        error: ZanaColors.danger,
        onError: ZanaColors.white,
        surface: p.surface,
        onSurface: p.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.text,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: p.text,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: ZanaColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          side: BorderSide(color: p.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.muted,
          fontSize: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: 1,
        space: 1,
      ),
      textTheme: _textTheme(p),
      iconTheme: IconThemeData(color: p.text, size: 22),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: p.muted,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ZanaPalette p) {
    return TextTheme(
      // Page title
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 23,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: p.text,
        height: 1.35,
      ),
      // Chapter title
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: p.text,
        height: 1.4,
      ),
      // Interview question
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: p.text,
        height: 1.5,
      ),
      // Section title
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: p.text,
      ),
      // Method title in list
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: p.text,
        height: 1.4,
      ),
      // Body lead
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: p.text,
        height: 1.7,
      ),
      // Normal body
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: p.text,
        height: 1.9,
      ),
      // Secondary body / description
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: p.muted,
        height: 1.7,
      ),
      // Small description
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: p.muted,
        height: 1.65,
      ),
      // Chips, labels
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: p.text,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: p.muted,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: p.muted,
      ),
    );
  }
}
