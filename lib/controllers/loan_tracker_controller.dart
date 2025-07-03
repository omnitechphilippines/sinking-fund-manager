import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/models/loan_tracker_model.dart';

import '../api_services/loan_trackers_api_service.dart';

class LoanTrackerController extends Notifier<List<LoanTrackerModel>> {

  @override
  List<LoanTrackerModel> build() => <LoanTrackerModel>[];

  Future<void> init() async {
    final List<LoanTrackerModel> loanTrackers = await LoanTrackersApiService().getLoanTrackers();
    state = loanTrackers;
  }

  void addLoanTracker(LoanTrackerModel newLoanTracker) {
    state = <LoanTrackerModel>[...state, newLoanTracker];
  }

  void deleteLoanTracker(LoanTrackerModel loanTrackerToDelete) {
    state = state.where((LoanTrackerModel m) => m.id != loanTrackerToDelete.id).toList();
  }
}

final NotifierProvider<LoanTrackerController, List<LoanTrackerModel>> loanTrackerControllerProvider = NotifierProvider<LoanTrackerController, List<LoanTrackerModel>>(() => LoanTrackerController());
