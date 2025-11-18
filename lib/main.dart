import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import 'app/app.dart';
import 'controllers/contribution_controller.dart';
import 'controllers/loan_controller.dart';
import 'controllers/loan_tracker_controller.dart';
import 'controllers/member_controller.dart';
import 'controllers/setting_controller.dart';
import 'controllers/summary_controller.dart';

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
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
