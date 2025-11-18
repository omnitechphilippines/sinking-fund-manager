import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Sinking Fund Manager', debugShowCheckedModeBanner: false, routerConfig: AppRouter.router, theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme);
  }
}
