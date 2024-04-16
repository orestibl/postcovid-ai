import 'package:flutter/material.dart';

class AppTheme {
  static const Color DARK_COLOR = Color.fromRGBO(9, 108, 121, 1.0);
  static const Color MEDIUM_COLOR = Color.fromRGBO(95, 134, 143, 1.0);
  static const Color LIGHT_COLOR = Color.fromRGBO(169, 219, 223, 1.0);
  static const Color LIGHT_COLOR_2 = Color.fromRGBO(172, 215, 220, 1.0);
  static const Color LIGHT_COLOR_3 = Color.fromRGBO(122, 200, 206, 1.0);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: DARK_COLOR,
      // primaryColor: DARK_COLOR,
      // scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Poppins',
      // haciendo  grep -C1 "Theme.of(context).text" -r *.dart en la librería de research_package, veo que usan los siguientes
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20), // Este se usa en RPUiInstructionStep
        // headlineMedium: TextStyle(fontSize: 12),
        // headlineLarge: TextStyle(fontSize: 12),
        // titleMedium: TextStyle(fontSize: 12),
        titleLarge: TextStyle(fontSize: 18),
        // bodySmall: TextStyle(fontSize: 12),
        // bodyMedium: TextStyle(fontSize: 12),
        // bodyLarge: TextStyle(fontSize: 12),
        // labelLarge: TextStyle(fontSize: 12),
        // displayMedium: TextStyle(fontSize: 12),
      ),
      // sliderTheme: const SliderThemeData(activeTrackColor: DARK_COLOR, inactiveTrackColor: LIGHT_COLOR_2),
      // buttonTheme: const ButtonThemeData(buttonColor: DARK_COLOR),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //   style: ElevatedButton.styleFrom(backgroundColor: DARK_COLOR, foregroundColor: Colors.white),
      // ),
      // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: DARK_COLOR).copyWith(background: Colors.white),
    );
  }

  // NO SALE BIEN -> NO LO USES
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: DARK_COLOR,
      fontFamily: 'Poppins',
      // haciendo  grep -C1 "Theme.of(context).text" -r *.dart en la librería de research_package, veo que usan los siguientes
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20), // Este se usa en RPUiInstructionStep
        // headlineMedium: TextStyle(fontSize: 12),
        // headlineLarge: TextStyle(fontSize: 12),
        // titleMedium: TextStyle(fontSize: 12),
        titleLarge: TextStyle(fontSize: 18),
        // bodySmall: TextStyle(fontSize: 12),
        // bodyMedium: TextStyle(fontSize: 12),
        // bodyLarge: TextStyle(fontSize: 12),
        // labelLarge: TextStyle(fontSize: 12),
        // displayMedium: TextStyle(fontSize: 12),
      ),
    );
  }
}
