import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import 'controllers/contribution_controller.dart';
import 'controllers/loan_controller.dart';
import 'controllers/loan_tracker_controller.dart';
import 'controllers/member_controller.dart';
import 'controllers/setting_controller.dart';
import 'controllers/summary_controller.dart';
import 'router.dart';

ColorScheme kColorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 96, 59, 181));
ColorScheme kDarkColorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 5, 99, 125), brightness: Brightness.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');
  final ProviderContainer container = ProviderContainer();
  await container.read(settingControllerProvider.notifier).init();
  await container.read(summaryControllerProvider.notifier).init();
  await container.read(memberControllerProvider.notifier).init();
  await container.read(contributionControllerProvider.notifier).init();
  await container.read(loanControllerProvider.notifier).init();
  await container.read(loanTrackerControllerProvider.notifier).init();
  runApp(UncontrolledProviderScope(container: container, child: const SinkingFundManager()));
}

class SinkingFundManager extends StatelessWidget {
  const SinkingFundManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sinking Fund Manager',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: kColorScheme,
        appBarTheme: AppBarTheme(foregroundColor: kColorScheme.primaryContainer, backgroundColor: kColorScheme.onPrimaryContainer),
        cardTheme: CardThemeData(color: kColorScheme.secondaryContainer, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: kColorScheme.primaryContainer)),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: kColorScheme.onSecondaryContainer, fontSize: 16),
          titleMedium: TextStyle(color: kColorScheme.onSecondaryContainer, fontSize: 14),
          titleSmall: TextStyle(color: kColorScheme.onSecondaryContainer),
        ),
        datePickerTheme: DatePickerThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
        dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        timePickerTheme: TimePickerThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          helpTextStyle: TextStyle(color: kColorScheme.onSecondaryContainer),
          hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        cardTheme: CardThemeData(color: kDarkColorScheme.secondaryContainer, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: kDarkColorScheme.onPrimaryContainer, backgroundColor: kDarkColorScheme.primaryContainer),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: kDarkColorScheme.onSecondaryContainer, fontSize: 16),
          titleMedium: TextStyle(color: kDarkColorScheme.onSecondaryContainer, fontSize: 14),
          titleSmall: TextStyle(color: kDarkColorScheme.onSecondaryContainer),
        ),
        datePickerTheme: DatePickerThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
        dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        timePickerTheme: TimePickerThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          helpTextStyle: TextStyle(color: kDarkColorScheme.onSecondaryContainer),
          hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
