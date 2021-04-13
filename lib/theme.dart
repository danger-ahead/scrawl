import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: kPrimaryColor,
    accentColor: kAccentColor,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      textTheme:
          TextTheme(headline6: TextStyle(fontSize: 20.0, color: Colors.white)),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

ThemeData themeDark() {
  return ThemeData(
    brightness: Brightness.dark,
    accentColor: kAccentColor,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      textTheme:
          TextTheme(headline6: TextStyle(fontSize: 20.0, color: Colors.white)),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
