import 'package:flutter/material.dart';

class AppColors {
  static const Color gradientStart = Color(0xFF6A85FF); // blue
  static const Color gradientEnd = Color(0xFFFF6A88);   // pink
  static const Color button = Color(0xFF4B32E3);         // deep blue/purple
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF7B7B7B);  // gray
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.button,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    displayMedium: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 16,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.button),
    ),
    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 18),
    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      minimumSize: const Size.fromHeight(60),
    ),
  ),
); 