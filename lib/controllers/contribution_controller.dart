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

  List<ContributionModel> getContributionsByMemberId(String memberId) {
    return state.where((ContributionModel c) => c.memberId == memberId).toList()..sort((ContributionModel a, ContributionModel b) => a.contributionDate.compareTo(b.contributionDate));
  }
}

final NotifierProvider<ContributionController, List<ContributionModel>> contributionControllerProvider = NotifierProvider<ContributionController, List<ContributionModel>>(() => ContributionController());

final contributionsByMemberIdProvider = Provider.family<List<ContributionModel>, String>((ref, memberId) {
  final contributions = ref.watch(contributionControllerProvider);
  return contributions
      .where((c) => c.memberId == memberId)
      .toList()
    ..sort((a, b) => a.contributionDate.compareTo(b.contributionDate));
});
