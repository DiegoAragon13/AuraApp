import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApp {
  ThemeApp._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    splashColor: Colors.transparent,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF5C6AA), // Soft Coral
    shadowColor: const Color.fromARGB(30, 0, 0, 0),
    scaffoldBackgroundColor: const Color(0xFFFCF9F2), // Ivory White
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFF5C6AA), // Soft Coral
      secondary: Color(0xFFF5ECD5), // Light Mint//F5ECD5
      tertiary: Color(0xFFEBD4EF), // Warm Lilac
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: Color(0xFF444444), // Slate Gray
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: Color(0xFF444444),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static ThemeData darktTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    splashColor: Colors.transparent,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF5C6AA), // Soft Coral
    shadowColor: const Color.fromARGB(30, 0, 0, 0),
    scaffoldBackgroundColor: const Color(0xFFFCF9F2), // Ivory White
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFF5C6AA), // Soft Coral
      secondary: Color(0xFFF5ECD5), // Light Mint
      tertiary: Color(0xFFEBD4EF), // Warm Lilac
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: Color(0xFF444444), // Slate Gray
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: Color(0xFF444444),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
