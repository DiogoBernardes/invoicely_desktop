import 'package:flutter/material.dart';

class AppTheme {
  // Cores baseadas no design do login
  static const Color primaryColor =
      Color(0xFF03345C); // Azul escuro do botão Login
  static const Color backgroundColor = Color.fromARGB(255, 26, 38, 51);
  static const Color textPrimaryColor =
      Color(0xFFFFFFFF); // Branco para textos principais
  static const Color textSecondaryColor =
      Color(0xFFB0B0B0); // Cinza claro para textos secundários
  static const Color borderColor = Color(0xFF404040); // Cinza para bordas
  static const Color errorColor = Color(0xFFDC2626); // Vermelho para erros
  static const Color whiteWithOpacity =
      Color.fromARGB(221, 255, 255, 255); // Branco com opacidade

  // Tema claro (baseado no seu design de login)
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: primaryColor.withOpacity(0.8),
      background: backgroundColor,
      surface: backgroundColor,
      onPrimary: Colors.white,
      onBackground: textPrimaryColor,
      onSurface: textPrimaryColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: textSecondaryColor,
        fontSize: 16,
      ),
      labelStyle: const TextStyle(
        color: textPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      // Título principal "Login"
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: whiteWithOpacity,
      ),
      // "Welcome back"
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: whiteWithOpacity,
      ),
      // "Sign in to continue"
      titleMedium: TextStyle(
        fontSize: 16,
        color: textSecondaryColor,
      ),
      // Labels dos campos "Email", "Password"
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: whiteWithOpacity,
      ),
      // Texto normal
      bodyMedium: TextStyle(
        fontSize: 16,
        color: textPrimaryColor,
      ),
      // "Forgot Password?"
      bodySmall: TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.w100,
      ),
    ),
  );

  // Tema escuro (atualizado com as cores do seu formulário)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF03345C), // Azul escuro do seu botão
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF03345C),
      primary: const Color(0xFF03345C),
      secondary: const Color(0xFF03345C).withOpacity(0.8),
      background: const Color.fromARGB(255, 26, 38, 51),
      surface: const Color.fromARGB(255, 7, 43, 143),
      onPrimary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: errorColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 26, 38, 51),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF03345C), // Azul escuro do seu botão
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF404040)),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF404040)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF03345C), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: const Color.fromARGB(205, 51, 77, 102),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: Color.fromARGB(255, 145, 173, 201),
        fontSize: 16,
      ),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      // Título principal "Login" - branco com opacidade
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(221, 255, 255, 255),
      ),
      // "Welcome back" - branco com opacidade
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(221, 255, 255, 255),
      ),
      // Texto secundário
      titleMedium: TextStyle(
        fontSize: 16,
        color: Color(0xFF9CA3AF),
      ),
      // Labels dos campos - branco com opacidade
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(221, 255, 255, 255),
      ),
      // Texto normal
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      // "Forgot Password?" - branco, fonte pequena e fina
      bodySmall: TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.w100,
      ),
    ),
  );
}
