import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bars/custom_app_bar.dart';
import '../widgets/drawers/side_drawer.dart';
import '../widgets/footers/footer.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reports'),
      drawer: SideDrawer(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: Column(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: Center(child: Text('Reports', style: Theme.of(context).textTheme.titleLarge)),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
