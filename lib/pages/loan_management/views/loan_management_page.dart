import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../components/footer.dart';
import '../../../../components/side_nav.dart';
import '../../../../components/custom_app_bar.dart';

class LoanManagementPage extends ConsumerStatefulWidget {
  const LoanManagementPage({super.key});

  @override
  ConsumerState<LoanManagementPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<LoanManagementPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Loan Management'),
      drawer: SideNav(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: Column(
        spacing: 8,
        children: <Widget>[
          Expanded(child: Center(child: Text('Loan Management', style: Theme.of(context).textTheme.titleLarge))),
          const Footer(),
        ],
      ),
    );
  }
}
