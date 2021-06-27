part of postcovid_ai;

class AppTheme {
  static const Color DARK_COLOR = Color.fromRGBO(9, 108, 121, 1.0);
  static const Color MEDIUM_COLOR = Color.fromRGBO(95, 134, 143, 1.0);
  static const Color LIGHT_COLOR = Color.fromRGBO(169, 219, 223, 1.0);
  static const Color LIGHT_COLOR_2 = Color.fromRGBO(172, 215, 220, 1.0);
  static const Color LIGHT_COLOR_3 = Color.fromRGBO(122, 200, 206, 1.0);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: DARK_COLOR,
      accentColor: DARK_COLOR,
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: Colors.white,
      fontFamily: 'Poppins'
    );
  }
}