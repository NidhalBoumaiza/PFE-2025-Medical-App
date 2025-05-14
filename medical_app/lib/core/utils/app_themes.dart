import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Primary color for both themes
  static const primaryColor = Color(0xFF2fa7bb);
  
  // Light theme colors
  static const lightBackgroundColor = Colors.white;
  static const lightCardColor = Colors.white;
  static const lightTextColor = Color(0xFF333333);
  static const lightSecondaryTextColor = Color(0xFF757575);
  static const lightDividerColor = Color(0xFFE0E0E0);
  
  // Dark theme colors
  static const darkBackgroundColor = Color(0xFF121212);
  static const darkCardColor = Color(0xFF1E1E1E);
  static const darkTextColor = Colors.white;
  static const darkSecondaryTextColor = Color(0xFFBDBDBD);
  static const darkDividerColor = Color(0xFF424242);

  // Light Theme
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      onPrimary: Colors.white,
      background: lightBackgroundColor,
      surface: lightCardColor,
      onSurface: lightTextColor,
    ),
    cardTheme: CardTheme(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightDividerColor,
      thickness: 1,
    ),
    textTheme: GoogleFonts.ralewayTextTheme(
      ThemeData.light().textTheme.copyWith(
        displayLarge: GoogleFonts.raleway(color: lightTextColor),
        displayMedium: GoogleFonts.raleway(color: lightTextColor),
        displaySmall: GoogleFonts.raleway(color: lightTextColor),
        headlineMedium: GoogleFonts.raleway(color: lightTextColor),
        headlineSmall: GoogleFonts.raleway(color: lightTextColor),
        titleLarge: GoogleFonts.raleway(color: lightTextColor),
        titleMedium: GoogleFonts.raleway(color: lightTextColor),
        titleSmall: GoogleFonts.raleway(color: lightTextColor),
        bodyLarge: GoogleFonts.raleway(color: lightTextColor),
        bodyMedium: GoogleFonts.raleway(color: lightTextColor),
        bodySmall: GoogleFonts.raleway(color: lightSecondaryTextColor),
        labelLarge: GoogleFonts.raleway(color: lightTextColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      labelStyle: GoogleFonts.raleway(color: lightSecondaryTextColor),
      hintStyle: GoogleFonts.raleway(color: lightSecondaryTextColor),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white;
        },
      ),
      trackColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        },
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        },
      ),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        },
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.raleway(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      contentTextStyle: GoogleFonts.raleway(
        fontSize: 14,
        color: lightTextColor,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightCardColor,
      indicatorColor: primaryColor.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightTextColor,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: Colors.grey.shade700);
        },
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      onPrimary: Colors.white,
      background: darkBackgroundColor,
      surface: darkCardColor,
      onSurface: darkTextColor,
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkDividerColor,
      thickness: 1,
    ),
    textTheme: GoogleFonts.ralewayTextTheme(
      ThemeData.dark().textTheme.copyWith(
        displayLarge: GoogleFonts.raleway(color: darkTextColor),
        displayMedium: GoogleFonts.raleway(color: darkTextColor),
        displaySmall: GoogleFonts.raleway(color: darkTextColor),
        headlineMedium: GoogleFonts.raleway(color: darkTextColor),
        headlineSmall: GoogleFonts.raleway(color: darkTextColor),
        titleLarge: GoogleFonts.raleway(color: darkTextColor),
        titleMedium: GoogleFonts.raleway(color: darkTextColor),
        titleSmall: GoogleFonts.raleway(color: darkTextColor),
        bodyLarge: GoogleFonts.raleway(color: darkTextColor),
        bodyMedium: GoogleFonts.raleway(color: darkTextColor),
        bodySmall: GoogleFonts.raleway(color: darkSecondaryTextColor),
        labelLarge: GoogleFonts.raleway(color: darkTextColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      labelStyle: GoogleFonts.raleway(color: darkSecondaryTextColor),
      hintStyle: GoogleFonts.raleway(color: darkSecondaryTextColor),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        },
      ),
      trackColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.shade700;
        },
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        },
      ),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: BorderSide(color: Colors.grey.shade400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        },
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.raleway(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      contentTextStyle: GoogleFonts.raleway(
        fontSize: 14,
        color: darkTextColor,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkCardColor,
      indicatorColor: primaryColor.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextColor,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: Colors.grey.shade300);
        },
      ),
    ),
  );
} 