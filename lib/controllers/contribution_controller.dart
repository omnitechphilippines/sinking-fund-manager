import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contribution_model.dart';
import '../api_services/contributions_api_service.dart';

class ContributionController extends Notifier<List<ContributionModel>> {
  @override

  List<ContributionModel> build() => <ContributionModel>[];

  Future<void> init() async {
    final List<ContributionModel> contributions = await ContributionsApiService().getContributions();
    state = contributions;
  }

  void addContribution(ContributionModel newContribution) {
    state = <ContributionModel>[...state, newContribution];
  }

  void deleteContribution(ContributionModel contributionToDelete) {
    state = state.where((ContributionModel c) => c.id != contributionToDelete.id).toList();
  }

  void sortByLatestContributionDate() {
    final List<ContributionModel> sorted = <ContributionModel>[...state];
    sorted.sort((ContributionModel a, ContributionModel b) => b.contributionDate.compareTo(a.contributionDate));
    state = sorted;
  }
}

final NotifierProvider<ContributionController, List<ContributionModel>> contributionControllerProvider = NotifierProvider<ContributionController, List<ContributionModel>>(() => ContributionController());