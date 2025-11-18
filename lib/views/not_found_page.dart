import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bars/custom_app_bar.dart';
import '../widgets/drawers/side_drawer.dart';
import '../widgets/footers/footer.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Not Found'),
      drawer: SideDrawer(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: Column(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: Center(child: Text('Not Found', style: Theme.of(context).textTheme.titleLarge)),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
