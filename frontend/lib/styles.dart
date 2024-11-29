import 'package:flutter/material.dart';

class GlobalThemeData {
  static const ColorScheme defaultColorScheme = ColorScheme(
    primary: Color.fromARGB(255, 55, 65, 81),
    secondary: Color.fromARGB(255, 107, 114, 128),
    surface: Color.fromARGB(255, 17, 24, 39),
    error: Colors.redAccent,
    onError: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color.fromARGB(255, 107, 114, 128),
    brightness: Brightness.dark,
  );

  static final Color _focusColor = Colors.white.withOpacity(0.12);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
        colorScheme: colorScheme,
        canvasColor: colorScheme.surface,
        scaffoldBackgroundColor: colorScheme.surface,
        highlightColor: Colors.transparent,
        textSelectionTheme:
            const TextSelectionThemeData(selectionColor: Colors.blue),
        focusColor: focusColor);
  }

  static ThemeData defaultTheme = themeData(defaultColorScheme, _focusColor);
}

class PaddingSize {
  static const unit = 5.0;
  static const small = unit;
  static const medium = unit * 2;
  static const large = unit * 4;
}

class FontSize {
  static const small = 12.0;
  static const medium = 16.0;
  static const large = 20.0;
}

class ElevationSize {
  static const unit = 2.5;
  static const small = unit;
  static const medium = unit * 2;
  static const large = unit * 3;
  static const max = 9999.0;
}

class BorderRadiusSize {
  static const max = 9999.0;
  static const rounded = 30.0;
}
