import 'package:flutter/material.dart';
import 'package:get/get.dart';

MaterialColor myColor = const MaterialColor(
  0xFF2A2550,
  {
    50: Color(0xFF2A2550),
    100: Color(0xFF2A2550),
    200: Color(0xFF2A2550),
    300: Color(0xFF2A2550),
    400: Color(0xFF2A2550),
    500: Color(0xFF2A2550),
    600: Color(0xFF2A2550),
    700: Color(0xFF2A2550),
    800: Color(0xFF2A2550),
    900: Color(0xFF2A2550),
  },
);

class ThemeController extends GetxController {
  CurrentTheme currentTheme = CurrentTheme(
    themeData: ThemeData.light().copyWith(
      primaryColor: myColor,
    ),
    primarySwatch: myColor,
    light: SubTheme(
      primary: const Color(0xFF2A2550),
      secondary: const Color(0xFFE04D01),
      gradient: [
        const Color(0xFF2A2550),
        const Color(0xFF57AAF7),
      ],
      textPrimary: const Color(0xFFFEFFFF),
      textSecondary: const Color(0xFF838383),
      textTheme: const Color(0xFFFAFAFA),
      background: const Color(0xFF251D3A),
      canvas: const Color(0xFFF3F3F3),
    ),
    dark: SubTheme(
      primary: const Color(0xFF2A2550),
      secondary: const Color(0xFFE04D01),
      gradient: [
        const Color(0xFF2A2550),
        const Color(0xFF57AAF7),
      ],
      textPrimary: const Color(0xFFffffff),
      textSecondary: const Color(0xFFbfc1d1),
      textTheme: const Color(0xFF101010),
      background: const Color(0xFF15162d),
      canvas: const Color(0xFF2e2d42),
    ),
  );

  changeTheme(ThemeData theme) {
    currentTheme.themeData = theme;
    update();
  }
}

class CurrentTheme {
  ThemeData themeData;
  SubTheme dark;
  SubTheme light;
  MaterialColor primarySwatch;

  CurrentTheme({
    required this.themeData,
    required this.dark,
    required this.light,
    required this.primarySwatch,
  });
}

class SubTheme {
  Color primary;
  Color secondary;
  Color textPrimary;
  Color textSecondary;
  Color textTheme;
  Color background;
  Color canvas;
  List<Color> gradient;
  SubTheme({
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTheme,
    required this.background,
    required this.canvas,
    required this.gradient,
  });
}
