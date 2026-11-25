import 'package:material_ui/material_ui.dart';

/// Colours from the design canvas.
abstract final class FoxColors {
  static const ground = Color(0xFFF2F6EC);
  static const ink = Color(0xFF1B2A20);
  static const muted = Color(0xFF55665A);
  static const line = Color(0xFFDCE6D5);
  static const jungle = Color(0xFF1E8A52);
  static const jungleDark = Color(0xFF146B3E);
  static const sun = Color(0xFFFFC12E);
  static const sunDark = Color(0xFFD99A00);
  static const sky = Color(0xFF1F7DB0);
  static const coral = Color(0xFFF2643D);
  static const fox = Color(0xFFF28C38);
  static const foxDark = Color(0xFFE8772E);
  static const night = Color(0xFF14241A);

  /// Sticker backgrounds, picked per target.
  static const stickers = [
    Color(0xFFF2643D),
    Color(0xFF1F7DB0),
    Color(0xFF1E8A52),
    Color(0xFF8E5BD6),
    Color(0xFFE0A100),
    Color(0xFFD9468F),
    Color(0xFF2FA39A),
  ];
}

/// Fonts bundled in assets/fonts (never fetched at runtime: the app sends
/// nothing anywhere). Baloo 2 replaces Fredoka from the design because
/// Fredoka has no Polish letters (ą, ę, ś, ź, ż...).
abstract final class FoxFonts {
  static const display = 'Baloo2';
  static const body = 'Nunito';
}

TextStyle display(double size, {Color color = FoxColors.ink}) => TextStyle(
      fontFamily: FoxFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: size,
      height: 1.1,
      color: color,
    );

TextStyle body(
  double size, {
  Color color = FoxColors.ink,
  FontWeight weight = FontWeight.w700,
}) =>
    TextStyle(
      fontFamily: FoxFonts.body,
      fontWeight: weight,
      fontSize: size,
      color: color,
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: FoxColors.jungle,
    primary: FoxColors.jungle,
    secondary: FoxColors.sun,
    surface: FoxColors.ground,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: FoxColors.ground,
    fontFamily: FoxFonts.body,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: FoxFonts.display,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
