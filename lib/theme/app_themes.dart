import 'package:flutter/material.dart';

class AppThemes {
  // Thème Deku (Vert forêt et blanc)
  static ThemeData dekuTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF15803D),
      secondary: Color(0xFF22C55E),
      tertiary: Color(0xFFFAFAF9),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF5F5F4),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1C1917),
      onBackground: Color(0xFF1C1917),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF15803D),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF15803D),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème Bakugo (Orange explosif et noir)
  static ThemeData bakugoTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFF6B35),
      secondary: Color(0xFFF59E0B),
      tertiary: Color(0xFF1C1917),
      surface: Color(0xFF292524),
      background: Color(0xFF1C1917),
      error: Color(0xFFEF4444),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Color(0xFFFAFAF9),
      onBackground: Color(0xFFFAFAF9),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFFF6B35),
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Color(0xFF292524),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF6B35),
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème All Might (Bleu royal et jaune or)
  static ThemeData allMightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFFFCD34D),
      tertiary: Color(0xFFDCEEFD),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFEFF6FF),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF1C1917),
      onSurface: Color(0xFF1C1917),
      onBackground: Color(0xFF1C1917),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème Todoroki (Dualité rouge feu et bleu glace)
  static ThemeData todorokiTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFFDC2626),
      tertiary: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF8FAFC),
      error: Color(0xFFB91C1C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E293B),
      onBackground: Color(0xFF1E293B),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF3B82F6),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème Uraraka (Rose doux et blanc)
  static ThemeData urarakaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF472B6),
      tertiary: Color(0xFFFDF2F8),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFFCE7F3),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1C1917),
      onBackground: Color(0xFF1C1917),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFEC4899),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEC4899),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème Kirishima (Rouge rubis et gris métallique)
  static ThemeData kirishimaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFB91C1C),
      secondary: Color(0xFF71717A),
      tertiary: Color(0xFFE7E5E4),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF5F5F4),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1C1917),
      onBackground: Color(0xFF1C1917),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFB91C1C),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFB91C1C),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème Villain/Shigaraki (Gris sombre et rouge sang)
  static ThemeData villainTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF7F1D1D),
      secondary: Color(0xFF991B1B),
      tertiary: Color(0xFF1C1917),
      surface: Color(0xFF18181B),
      background: Color(0xFF0A0A0A),
      error: Color(0xFFEF4444),
      onPrimary: Color(0xFFD1D5DB),
      onSecondary: Color(0xFFD1D5DB),
      onSurface: Color(0xFFD1D5DB),
      onBackground: Color(0xFFD1D5DB),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF7F1D1D),
      foregroundColor: Color(0xFFD1D5DB),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Color(0xFF18181B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF7F1D1D),
        foregroundColor: Color(0xFFD1D5DB),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Thème UA (Bleu marine école et blanc)
  static ThemeData uaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1E3A8A),
      secondary: Color(0xFF3B82F6),
      tertiary: Color(0xFFE0E7FF),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFEFF6FF),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E293B),
      onBackground: Color(0xFF1E293B),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E3A8A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Map pour faciliter l'accès aux thèmes
  static Map<String, ThemeData> themes = {
    'Deku': dekuTheme,
    'Bakugo': bakugoTheme,
    'All Might': allMightTheme,
    'Todoroki': todorokiTheme,
    'Uraraka': urarakaTheme,
    'Kirishima': kirishimaTheme,
    'Villain': villainTheme,
    'UA': uaTheme,
  };

  // Liste des noms de thèmes
  static List<String> themeNames = [
    'Deku',
    'Bakugo',
    'All Might',
    'Todoroki',
    'Uraraka',
    'Kirishima',
    'Villain',
    'UA',
  ];
}
