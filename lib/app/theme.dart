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
}

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
    // TODO(design): bundle Fredoka (headings) and Nunito (body) as assets.
    // Never load fonts from the network at runtime: the app must stay offline
    // and send nothing anywhere.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
