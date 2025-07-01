import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_services/summaries_api_service.dart';
import '../models/summary_model.dart';

class SummaryController extends Notifier<SummaryModel?> {
  @override
  SummaryModel? build() => null;

  Future<void> init() async {
    final SummaryModel? summary = await SummariesApiService().getSummary();
    state = summary;
  }

  void editSummary({int? id, double? totalContribution, double? totalLoan, double? totalUnpaidLoan, double? totalPaidLoan, double? totalCashOnHand, double? totalInterestAmount, DateTime? createdAt, DateTime? updatedAt}) {
    if (state == null) return;
    state = state!.copyWith(
      id: id,
      totalContribution: totalContribution,
      totalLoan: totalLoan,
      totalUnpaidLoan: totalUnpaidLoan,
      totalPaidLoan: totalPaidLoan,
      totalCashOnHand: totalCashOnHand,
      totalInterestAmount: totalInterestAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  void deleteSummary() {
    state = null;
  }
}

final NotifierProvider<SummaryController, SummaryModel?> summaryControllerProvider = NotifierProvider<SummaryController, SummaryModel?>(() => SummaryController());
