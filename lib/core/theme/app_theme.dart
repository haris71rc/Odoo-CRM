import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DigiLawyer Telecaller CRM light design tokens and Material 3 theme.
class AppTheme {
  AppTheme._();

  // Brand
  static const Color navy = Color(0xFF1B3A6B);
  static const Color gold = Color(0xFFC08A21);
  static const Color goldSoft = Color(0xFFE9C87B);
  static const Color callGreen = Color(0xFF0B7A5A);

  // Surfaces
  static const Color scaffold = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color elevated = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFEAECF0);
  static const Color borderStrong = Color(0xFFE4E7EC);
  static const Color navyTint = Color(0xFFE7ECF5);

  // Accents (aliases for existing call sites)
  static const Color primary = navy;
  static const Color secondary = gold;
  static const Color error = Color(0xFFB42318);

  // Text
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF475467);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color textBody = Color(0xFF667085);
  static const Color textOnNavy = Color(0xFFA9BEDC);

  // Semantic
  static const Color wonFg = Color(0xFF05603A);
  static const Color wonBg = Color(0xFFD1FADF);
  static const Color wonBorder = Color(0xFFA6EFC5);
  static const Color lostFg = Color(0xFFB42318);
  static const Color lostBg = Color(0xFFFEE4E2);
  static const Color lostBorder = Color(0xFFFDA29B);
  static const Color followUpBg = Color(0xFFFFF8E8);
  static const Color followUpBorder = Color(0xFFF3D9A6);
  static const Color followUpFg = Color(0xFF8A5A08);

  static TextStyle mono({
    double fontSize = 12.5,
    FontWeight fontWeight = FontWeight.w500,
    Color color = textPrimary,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get light {
    final baseText = GoogleFonts.manropeTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    final colorScheme = const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textBody,
      error: error,
      onError: Colors.white,
      outline: border,
      outlineVariant: borderStrong,
      surfaceContainerHighest: elevated,
      surfaceContainerHigh: elevated,
      surfaceContainer: surface,
      surfaceContainerLow: scaffold,
      surfaceContainerLowest: scaffold,
    );

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseText.titleSmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(color: textPrimary),
      bodyMedium: baseText.bodyMedium?.copyWith(color: textPrimary),
      bodySmall: baseText.bodySmall?.copyWith(color: textMuted),
      labelLarge: baseText.labelLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: borderStrong, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: borderStrong, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.01,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: borderStrong, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: borderStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        selectedColor: navyTint,
        side: const BorderSide(color: borderStrong),
        labelStyle: textTheme.labelLarge?.copyWith(color: textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return navyTint;
            }
            return surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }
            return textSecondary;
          }),
          side: const WidgetStatePropertyAll(BorderSide(color: borderStrong)),
          visualDensity: VisualDensity.standard,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: navyTint,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? primary : textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : textMuted,
            size: 21,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.manrope(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textMuted;
        }),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textPrimary),
      ),
    );
  }

  /// Primary theme — DigiLawyer light.
  static ThemeData get dark => light;
}
