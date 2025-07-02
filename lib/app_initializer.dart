import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/contribution_controller.dart';
import 'controllers/loan_controller.dart';
import 'controllers/loan_tracker_controller.dart';
import 'controllers/member_controller.dart';
import 'controllers/setting_controller.dart';
import 'controllers/summary_controller.dart';

Future<void> loadAllData(WidgetRef ref) async {
  await ref.read(settingControllerProvider.notifier).init();
  await ref.read(summaryControllerProvider.notifier).init();
  await ref.read(memberControllerProvider.notifier).init();
  await ref.read(contributionControllerProvider.notifier).init();
  await ref.read(loanControllerProvider.notifier).init();
  await ref.read(loanTrackerControllerProvider.notifier).init();
}
