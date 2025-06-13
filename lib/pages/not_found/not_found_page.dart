import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/custom_app_bar.dart';
import '../../components/footer.dart';
import '../../components/side_nav.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Not Found'),
      drawer: SideNav(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: Column(
        spacing: 8,
        children: <Widget>[
          Expanded(child: Center(child: Text('Not Found', style: Theme.of(context).textTheme.titleLarge))),
          const Footer(),
        ],
      ),
    );
  }
}
