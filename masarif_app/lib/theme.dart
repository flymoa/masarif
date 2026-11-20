import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Alwan dyal l app — design V2 (khder ghame9 + dhbi + zellige).
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.text,
    required this.muted,
    required this.navMuted,
    required this.border,
    required this.divider,
    required this.segActive,
    required this.brand,
    required this.brandFg,
    required this.link,
    required this.positive,
    required this.danger,
    required this.dangerBorder,
    required this.chipActive,
    required this.goldSoft,
    required this.goldInk,
    required this.fabBg,
    required this.fabFg,
  });

  final Color bg, surface, text, muted, navMuted, border, divider;
  final Color segActive; // onglet m5tar
  final Color brand; // cartes khdrin
  final Color brandFg; // icones / onglet actif
  final Color link;
  final Color positive, danger, dangerBorder, chipActive, goldSoft, goldInk;
  final Color fabBg, fabFg; // bouton "+" f l bar

  static const gold = Color(0xFFE8B53C);
  static const onGold = Color(0xFF1B1A12);
  static const onBrandMuted = Color(0xFFA9C4B5);
  static const deepGreen = Color(0xFF0F3B2C);

  static const light = AppColors(
    bg: Color(0xFFF2F4F1),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF13201A),
    muted: Color(0xFF6A766F),
    navMuted: Color(0xFF8A958E),
    border: Color(0xFFDCE3DE),
    divider: Color(0xFFEEF2EF),
    segActive: Color(0xFF0F3B2C),
    brand: Color(0xFF0F3B2C),
    brandFg: Color(0xFF0F3B2C),
    link: Color(0xFF2F7A55),
    positive: Color(0xFF2F7A55),
    danger: Color(0xFFA33A2B),
    dangerBorder: Color(0xFFE7C9C3),
    chipActive: Color(0xFFE3ECE6),
    goldSoft: Color(0xFFF6EDD5),
    goldInk: Color(0xFF9A6D12),
    fabBg: Color(0xFF0F3B2C),
    fabFg: Color(0xFFE8B53C),
  );

  static const dark = AppColors(
    bg: Color(0xFF0C1411),
    surface: Color(0xFF16211C),
    text: Color(0xFFEEF2EC),
    muted: Color(0xFF98A59D),
    navMuted: Color(0xFF7E8A83),
    border: Color(0xFF26332D),
    divider: Color(0xFF1E2A25),
    segActive: Color(0xFF2E6B52),
    brand: Color(0xFF0F3B2C),
    brandFg: Color(0xFF7FD3A4),
    link: Color(0xFF5FC48E),
    positive: Color(0xFF5FC48E),
    danger: Color(0xFFF28B82),
    dangerBorder: Color(0xFF5A2A26),
    chipActive: Color(0xFF1C3A2E),
    goldSoft: Color(0xFF352B12),
    goldInk: Color(0xFFE9C46A),
    fabBg: Color(0xFFE8B53C),
    fabFg: Color(0xFF1B1A12),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      (other is AppColors && t > 0.5) ? other : this;
}

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

TextStyle display(double size, {Color? color, FontWeight weight = FontWeight.w600}) =>
    GoogleFonts.lexend(fontSize: size, fontWeight: weight, color: color, letterSpacing: -0.4);

/// Label sghir b 7rouf kbar ("LI B9A LIK").
TextStyle capsLabel(Color color) =>
    GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: color);

ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.light ? AppColors.light : AppColors.dark;
  final base = ThemeData(
    brightness: b,
    useMaterial3: true,
    fontFamily: GoogleFonts.lexend().fontFamily,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepGreen,
      brightness: b,
      surface: c.surface,
      primary: c.brandFg,
      error: c.danger,
    ),
    extensions: [c],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: GoogleFonts.lexend().fontFamily, bodyColor: c.text, displayColor: c.text),
    dividerColor: c.divider,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: display(18, color: c.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.brandFg, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.danger, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.danger, width: 1.5)),
      prefixIconColor: c.muted,
      suffixIconColor: c.navMuted,
      hintStyle: TextStyle(color: c.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.onGold,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.danger,
        backgroundColor: c.surface,
        minimumSize: const Size.fromHeight(54),
        side: BorderSide(color: c.dangerBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.link,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: const Size(0, 44),
        textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    listTileTheme: const ListTileThemeData(horizontalTitleGap: 12, minLeadingWidth: 0),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.gold : null),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.segActive : null),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: b == Brightness.light ? const Color(0xFF13201A) : const Color(0xFF26332D),
      contentTextStyle: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w500),
      actionTextColor: AppColors.gold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bg,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogThemeData(backgroundColor: c.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
  );
}
