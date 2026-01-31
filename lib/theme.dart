import 'package:flutter/material.dart';

ThemeData getAppTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.orangeAccent,
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 12,
        color: Colors.orangeAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: EdgeInsets.only(top: 2),
      isCollapsed: true,
      fillColor: Colors.white,
      filled: true,
      hintStyle: TextStyle(
        fontSize: 12,
        color: Colors.orangeAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
