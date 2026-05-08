import 'package:flutter/material.dart';

/// 「轻燃」设计令牌：牛油果绿 + 奶油白背景。
abstract final class TinyBurnColors {
  static const Color primary = Color(0xFFA8D5BA);
  static const Color background = Color(0xFFF7F8F2);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color accentBlue = Color(0xFF7EB6FF);
  static const Color accentYellow = Color(0xFFFFD966);
}

abstract final class TinyBurnRadii {
  static const double card = 22;
  static const double chip = 14;
}

ThemeData buildTinyBurnTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: TinyBurnColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TinyBurnColors.primary,
      brightness: Brightness.light,
      primary: TinyBurnColors.primary,
      surface: TinyBurnColors.card,
    ),
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: TinyBurnColors.background,
      foregroundColor: TinyBurnColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: TinyBurnColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TinyBurnRadii.card),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.06),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TinyBurnColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TinyBurnRadii.card),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TinyBurnColors.primary,
        foregroundColor: TinyBurnColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TinyBurnRadii.card),
        ),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: TinyBurnColors.textPrimary,
      displayColor: TinyBurnColors.textPrimary,
    ),
  );
}

BoxDecoration tinyBurnCardDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? TinyBurnColors.card,
    borderRadius: BorderRadius.circular(TinyBurnRadii.card),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
