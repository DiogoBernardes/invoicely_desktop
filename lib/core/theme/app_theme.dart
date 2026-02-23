import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3A8DFF);
  static const Color accentColor = Color(0xFF1CC8A0);
  static const Color backgroundColor = Color(0xFF0A1A2B);
  static const Color textPrimaryColor = Color(0xFFEAF3FF);
  static const Color textSecondaryColor = Color(0xFFA9C0D8);
  static const Color borderColor = Color(0xFF27435F);
  static const Color errorColor = Color(0xFFE24C4B);
  static const Color whiteWithOpacity = Color.fromARGB(221, 255, 255, 255);
  static const Color panelColor = Color(0xFF122B41);
  static const Color panelColorSoft = Color(0xFF173550);

  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF081321),
      Color(0xFF0A1A2B),
      Color(0xFF0E253A),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static ThemeData get darkTheme {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Color(0xFF02251E),
      error: errorColor,
      onError: Colors.white,
      surface: panelColor,
      onSurface: textPrimaryColor,
    );
    return _buildTheme(scheme);
  }

  static ThemeData get lightTheme {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Color(0xFF02251E),
      error: errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF0A1A2B),
    );
    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme).copyWith(
      headlineMedium: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      bodyLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyMedium: const TextStyle(
        fontSize: 15,
        color: textPrimaryColor,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        color: textSecondaryColor,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      cardTheme: CardTheme(
        color: panelColor.withOpacity(0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor.withOpacity(0.75)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withOpacity(0.35),
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textSecondaryColor,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryColor,
          side: BorderSide(color: borderColor.withOpacity(0.9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panelColorSoft.withOpacity(0.82),
        hintStyle: const TextStyle(color: textSecondaryColor, fontSize: 14),
        labelStyle: const TextStyle(
          color: textSecondaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor.withOpacity(0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor.withOpacity(0.7),
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: panelColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: panelColor.withOpacity(0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor.withOpacity(0.78)),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(
          color: textPrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(
          color: textSecondaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        headingRowColor:
            WidgetStateProperty.all(panelColorSoft.withOpacity(0.92)),
        dataRowColor: WidgetStateProperty.all(panelColor.withOpacity(0.78)),
        dividerThickness: 0.6,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(panelColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor.withOpacity(0.8)),
            ),
          ),
        ),
        textStyle: const TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: panelColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return textPrimaryColor;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return panelColorSoft;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panelColor,
        contentTextStyle: const TextStyle(color: textPrimaryColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
