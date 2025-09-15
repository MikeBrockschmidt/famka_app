import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: AppColors.famkaCyan,
    secondary: AppColors.famkaYellow,
    onSecondary: AppColors.famkaBlack,
    surface: AppColors.famkaWhite,
    onSurface: AppColors.famkaBlack,
    error: AppColors.famkaRed,
  ),
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: AppColors.famkaBlack,
    collapsedIconColor: AppColors.famkaBlack,
  ),
  switchTheme: SwitchThemeData(
    thumbColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.famkaCyan;
      }
      return AppColors.famkaWhite;
    }),
    trackColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.famkaCyan.withAlpha(127);
      }
      return AppColors.famkaGrey;
    }),
  ),
  scaffoldBackgroundColor: AppColors.famkaWhite,
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.famkaWhite,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'SFProDisplayHeavy',
      fontWeight: FontWeight.w300,
      fontSize: 40,
      color: Colors.black,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'SFProDisplayHeavy',
      fontWeight: FontWeight.w800,
      fontSize: 23,
      color: Colors.black,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 12,
      color: Colors.black,
    ),
    labelSmall: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 15,
      color: const Color.fromARGB(255, 0, 0, 0),
    ),
    labelMedium: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.black,
    ),
    labelLarge: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w900,
      fontSize: 40,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 10,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 10,
      color: Colors.black,
    ),
    displaySmall: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w100,
      fontSize: 10,
      color: Colors.black,
    ),
    displayMedium: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 12,
      color: Colors.black,
    ),
    displayLarge: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 20,
      color: Colors.black,
    ),
    titleLarge: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w800,
      fontSize: 14,
      color: Colors.black,
    ),
    titleMedium: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w400,
      fontSize: 13,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w300,
      fontSize: 13,
      color: const Color.fromARGB(255, 0, 0, 0),
    ),
  ),
);
