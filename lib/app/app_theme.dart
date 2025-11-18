import 'package:flutter/material.dart';

class AppTheme {
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF603BB5));
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF05637D), brightness: Brightness.dark);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: lightColorScheme,
    appBarTheme: AppBarTheme(foregroundColor: lightColorScheme.primaryContainer, backgroundColor: lightColorScheme.primaryContainer),
    cardTheme: CardThemeData(color: lightColorScheme.secondaryContainer, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: lightColorScheme.primaryContainer)),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: lightColorScheme.onSecondaryContainer, fontSize: 16),
      titleMedium: TextStyle(color: lightColorScheme.onSecondaryContainer, fontSize: 14),
      titleSmall: TextStyle(color: lightColorScheme.onSecondaryContainer),
    ),
    datePickerTheme: DatePickerThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    timePickerTheme: TimePickerThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      helpTextStyle: TextStyle(color: lightColorScheme.onSecondaryContainer),
      hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: darkColorScheme,
    cardTheme: CardThemeData(color: darkColorScheme.secondaryContainer, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(foregroundColor: darkColorScheme.onPrimaryContainer, backgroundColor: darkColorScheme.primaryContainer),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: darkColorScheme.onSecondaryContainer, fontSize: 16),
      titleMedium: TextStyle(color: darkColorScheme.onSecondaryContainer, fontSize: 14),
      titleSmall: TextStyle(color: darkColorScheme.onSecondaryContainer),
    ),
    datePickerTheme: DatePickerThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    timePickerTheme: TimePickerThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      helpTextStyle: TextStyle(color: darkColorScheme.onSecondaryContainer),
      hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
