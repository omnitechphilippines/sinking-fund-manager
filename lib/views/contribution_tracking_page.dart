import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bars/custom_app_bar.dart';
import '../widgets/drawers/side_drawer.dart';
import '../widgets/footers/footer.dart';

class ContributionTrackingPage extends ConsumerStatefulWidget {
  const ContributionTrackingPage({super.key});

  @override
  ConsumerState<ContributionTrackingPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<ContributionTrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Contribution Tracking'),
      drawer: SideDrawer(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: Column(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: Center(child: Text('Contribution Tracking', style: Theme.of(context).textTheme.titleLarge)),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
