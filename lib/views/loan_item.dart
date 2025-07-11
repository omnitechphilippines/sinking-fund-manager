import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/utils/formatters.dart';

import '../api_services/loans_api_service.dart';
import '../components/confirm_dialog.dart';
import '../components/loan_dialog.dart';
import '../components/loan_tracker_dialog.dart';
import '../controllers/loan_controller.dart';
import '../controllers/loan_tracker_controller.dart';
import '../controllers/setting_controller.dart';
import '../controllers/summary_controller.dart';
import '../models/loan_model.dart';
import '../models/loan_tracker_model.dart';
import '../models/setting_model.dart';

class LoanItem extends ConsumerStatefulWidget {
  final LoanModel loan;

  const LoanItem({super.key, required this.loan});

  @override
  ConsumerState<LoanItem> createState() => _LoanItemState();
}

class _LoanItemState extends ConsumerState<LoanItem> {
  bool _isLoading = true;
  int _loanInterestRate = 0;
  double _currentGiveAmount = 0, _currentLoanInterestAmount = 0;
  DateTime? _currentPaymentDueDate;
  int? _currentGiveNumber;
  late LoanModel _loan;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
    _currentPaymentDueDate = _loan.currentPaymentDueDate;
    _currentGiveNumber = _loan.currentGiveNumber;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) async {
      try {
        final int overdue = DateTime.now().difference(_loan.currentPaymentDueDate).inDays;
        if (overdue > 0) {
          _loanInterestRate = (((overdue) / 7).ceil());
          _currentLoanInterestAmount = _loan.payablePerGive * (_loanInterestRate / 100);
          _currentGiveAmount = _currentLoanInterestAmount + _loan.payablePerGive;
          if (_currentGiveAmount != _loan.currentGiveAmount) {
            final bool response = await LoansApiService().updateLoan(
              _loan.copyWith(
                currentGiveInterest: _loanInterestRate,
                currentGiveAmount: _currentGiveAmount,
                currentTotalAmountToPay: _loan.currentTotalAmountToPay + _currentLoanInterestAmount,
                currentRemainingAmountToPay: _loan.currentRemainingAmountToPay + _currentLoanInterestAmount,
              ),
              _currentLoanInterestAmount,
            );
            if (response && mounted) {
              ref.read(summaryControllerProvider.notifier).editSummary(totalInterestAmount: ref.read(summaryControllerProvider)!.totalInterestAmount + _currentLoanInterestAmount);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Successfully updated interest rate of ${_loan.name}!', style: const TextStyle(color: Colors.white)),
                ),
              );
            }
          }
        } else {
          _currentGiveAmount = _loan.currentGiveAmount;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SettingModel? setting = ref.watch(settingControllerProvider);
    final List<LoanTrackerModel> loanTrackers = ref.watch(loanTrackerControllerProvider);
    final List<LoanTrackerModel> loanTrackersById = loanTrackers.where((LoanTrackerModel l) => l.loanId == widget.loan.id).toList();
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (BuildContext _, BoxConstraints constraints) {
              final bool isSmallScreen = constraints.maxWidth < 600;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                color: _loan.currentRemainingAmountToPay == 0 ? Colors.green.shade900 : null,
                elevation: 5,
                shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : Colors.black,
                child: InkWell(
                  onTap: () async => await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext _) => LoanDialog(loan: _loan),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 6, top: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(isSmallScreen ? _loan.name.split(' ')[0] : _loan.name, style: Theme.of(context).textTheme.titleLarge),
                            Text(_loan.currentRemainingAmountToPay == 0 ? 'F. paid' : '₱ ${_loan.formattedCurrentRemainingAmountToPay} (${_loan.currentGiveNumber - 1}/${_loan.numberOfGives})', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            if (_loan.currentRemainingAmountToPay != 0)
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleLarge,
                                  children: <InlineSpan>[
                                    const TextSpan(text: 'Due Date: '),
                                    TextSpan(
                                      text: dateFormatter.format(_currentPaymentDueDate!),
                                      style: TextStyle(color: DateTime.now().difference(_currentPaymentDueDate!).inDays > 0 ? Colors.red : Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            if (_loan.currentRemainingAmountToPay != 0)
                              Text('₱ ${numberFormatter.format(widget.loan.payablePerGive)}${_loanInterestRate > 0 ? ' + ${numberFormatter.format(_currentLoanInterestAmount)} ($_loanInterestRate%)' : ''} ($_currentGiveNumber)', style: Theme.of(context).textTheme.titleMedium),
                            if (_loan.currentRemainingAmountToPay == 0) const Icon(Icons.check, size: 36, color: Colors.greenAccent),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            if (_loan.currentRemainingAmountToPay != 0) IconButton(
                              tooltip: 'Pay Loan',
                              onPressed: setting != null
                                  ? () async {
                                      final List<dynamic>? result = await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext _) => LoanTrackerDialog(loan: _loan),
                                      );
                                      if (result != null && result.isNotEmpty) {
                                        final LoanTrackerModel newLoanTracker = result.first;
                                        final LoanModel updatedLoan = result[1];
                                        ref.read(loanTrackerControllerProvider.notifier).addLoanTracker(newLoanTracker);
                                        _currentGiveNumber = updatedLoan.currentGiveNumber;
                                        _currentPaymentDueDate = updatedLoan.currentPaymentDueDate;
                                        _currentGiveAmount = updatedLoan.currentGiveAmount;
                                        _loanInterestRate = updatedLoan.currentGiveInterest;
                                        _loan = updatedLoan;
                                        ref.read(loanControllerProvider.notifier).editLoan(updatedLoan);
                                        if (context.mounted) {
                                          final String dateTime = newLoanTracker.formattedPaymentDateTime;
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text('Loan payment for member "${_loan.name}" on $dateTime was successfully added!', style: const TextStyle(color: Colors.white)),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              icon: Icon(Icons.payments_outlined, color: setting != null ? null : Colors.grey.shade600),
                            ),
                            if(loanTrackersById.isEmpty) IconButton(
                              tooltip: 'Delete Loan',
                              onPressed: () async {
                                final bool shouldDelete = await showConfirmDialog(context: context, title: 'Confirm Deletion', message: 'Are you sure you want to delete loan of "${widget.loan.name}"?', confirmText: 'Delete', cancelText: 'Cancel');
                                setState(() => _isLoading = true);
                                try {
                                  if (shouldDelete) {
                                    await LoansApiService().deleteLoanById(widget.loan.id);
                                    if (context.mounted) {
                                      ref.read(loanControllerProvider.notifier).deleteLoan(widget.loan);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan of "${widget.loan.name}" was successfully deleted!')));
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
