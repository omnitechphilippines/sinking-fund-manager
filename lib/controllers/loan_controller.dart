import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/api_services/loans_api_service.dart';
import 'package:sinking_fund_manager/models/loan_model.dart';

enum LoanSortType { name, loanAmount, loanDateTime, numberOfGives, paymentStartDate, totalAmountToPay, payablePerGive }

enum LoanSortDirection { ascending, descending }

class LoanController extends Notifier<List<LoanModel>> {
  LoanSortType _sortType = LoanSortType.name;
  LoanSortDirection _sortDirection = LoanSortDirection.ascending;

  @override
  List<LoanModel> build() => <LoanModel>[];

  Future<void> init() async {
    final List<LoanModel> loans = await LoansApiService().getLoans();
    state = loans;
  }

  void addLoan(LoanModel newLoan) {
    state = <LoanModel>[...state, newLoan];
  }

  void deleteLoan(LoanModel loanToDelete) {
    state = state.where((LoanModel m) => m.id != loanToDelete.id).toList();
  }

  void setSort(LoanSortType type, LoanSortDirection direction) {
    _sortType = type;
    _sortDirection = direction;
    _sortLoans();
    state = <LoanModel>[...state];
  }

  void _sortLoans() {
    state.sort((LoanModel a, LoanModel b) {
      int compare;

      switch (_sortType) {
        case LoanSortType.name:
          compare = a.name.compareTo(b.name);
          break;
        case LoanSortType.loanAmount:
          compare = a.loanAmount.compareTo(b.loanAmount);
          break;
        case LoanSortType.loanDateTime:
          compare = a.loanDateTime.compareTo(b.loanDateTime);
          break;
        case LoanSortType.numberOfGives:
          compare = a.numberOfGives.compareTo(b.numberOfGives);
          break;
        case LoanSortType.paymentStartDate:
          compare = a.paymentStartDate.compareTo(b.paymentStartDate);
          break;
        case LoanSortType.totalAmountToPay:
          compare = a.totalAmountToPay.compareTo(b.totalAmountToPay);
          break;
        case LoanSortType.payablePerGive:
          compare = a.payablePerGive.compareTo(b.payablePerGive);
          break;
      }

      return _sortDirection == LoanSortDirection.ascending ? compare : -compare;
    });
  }
}

final NotifierProvider<LoanController, List<LoanModel>> loanControllerProvider = NotifierProvider<LoanController, List<LoanModel>>(() => LoanController());
