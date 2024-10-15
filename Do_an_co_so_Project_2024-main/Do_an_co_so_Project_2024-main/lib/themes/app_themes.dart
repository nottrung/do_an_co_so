import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    cardColor: Colors.purple[50],
    dropdownMenuTheme: DropdownMenuThemeData(menuStyle: MenuStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white))),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.orange.withOpacity(0.5)),
    primaryColor: Colors.orange,
    canvasColor: Colors.orangeAccent,
    backgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
        backgroundColor: Colors.orange[50],
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
      headline6: TextStyle(color: Colors.white),
      subtitle1: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.white),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[800],
    iconTheme: IconThemeData(color: Colors.white),
    cardColor: Colors.black12,
    dropdownMenuTheme: DropdownMenuThemeData(menuStyle: MenuStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade800))),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.orange.withOpacity(0.5)),
    primaryColor: Colors.indigo[900],
    canvasColor: Colors.indigo,
    backgroundColor: Colors.grey,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.indigo[900],
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.white),
      bodyText2: TextStyle(color: Colors.white),
      headline6: TextStyle(color: Colors.black),
      subtitle1: TextStyle(color: Colors.white),
      subtitle2: TextStyle(color: Colors.white),
    ),
  );

  static final ThemeData blueTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.lightBlue[50],
    iconTheme: IconThemeData(color: Colors.blue),
    cardColor: Colors.lightBlue[100],
    dropdownMenuTheme: DropdownMenuThemeData(menuStyle: MenuStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white))),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.orange.withOpacity(0.5)),
    primaryColor: Colors.blue,
    canvasColor: Colors.lightBlue,
    backgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
      headline6: TextStyle(color: Colors.white),
      subtitle1: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.white),
    ),
  );
}
