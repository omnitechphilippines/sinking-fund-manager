import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contribution.dart';
import 'contributions_api_service.dart';

class ContributionController extends Notifier<List<Contribution>> {
  @override

  List<Contribution> build() => <Contribution>[];

  Future<void> init() async {
    final List<Contribution> contributions = await ContributionsApiService().getContributions();
    state = contributions;
  }

  void addContribution(Contribution newContribution) {
    state = <Contribution>[...state, newContribution];
  }

  void deleteContribution(Contribution contributionToDelete) {
    state = state.where((Contribution c) => c.id != contributionToDelete.id).toList();
  }

  List<Contribution> get contributions => state;
}

final NotifierProvider<ContributionController, List<Contribution>> contributionControllerProvider = NotifierProvider<ContributionController, List<Contribution>>(() => ContributionController());