import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_services/loans_api_service.dart';
import '../components/confirm_dialog.dart';
import '../components/loan_dialog.dart';
import '../controllers/loan_controller.dart';
import '../controllers/setting_controller.dart';
import '../models/loan_model.dart';
import '../models/setting_model.dart';
import '../utils/formatters.dart';
import '../controllers/contribution_controller.dart';
import '../models/contribution_model.dart';

class LoanItem extends ConsumerStatefulWidget {
  final LoanModel loan;

  const LoanItem({super.key, required this.loan});

  @override
  ConsumerState<LoanItem> createState() => _LoanItemState();
}

class _LoanItemState extends ConsumerState<LoanItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final SettingModel? setting = ref.watch(settingControllerProvider);
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 5,
            shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : Colors.black,
            child: InkWell(
              onTap: () async => await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext _) => LoanDialog(loan: widget.loan),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.loan.name, style: Theme.of(context).textTheme.titleLarge),
                        Text('₱ ${numberFormatter.format(widget.loan.totalAmountToPay)} (${widget.loan.numberOfGives})', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text('Due: ${dateFormatter.format(widget.loan.paymentStartDate)}', style: Theme.of(context).textTheme.titleLarge),
                        Text('Amount: ₱ ${numberFormatter.format(widget.loan.payablePerGive)}', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    Row(
                      spacing: 4,
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Pay Loan',
                          onPressed: setting != null ? () async {
                            final List<dynamic>? result = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext _) => LoanDialog(loan: widget.loan),
                            );
                            if (result != null && result.isNotEmpty) {
                              final ContributionModel newContribution = result.first;
                              ref.read(contributionControllerProvider.notifier).addContribution(newContribution);
                              if (context.mounted) {
                                final String dateTime = dateTimeFormatter.format(newContribution.paymentDateTime);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('Contribution for member "${newContribution.name}" on $dateTime was successfully added!', style: const TextStyle(color: Colors.white)),
                                  ),
                                );
                              }
                            }
                          } : null,
                          icon: Icon(Icons.payments_outlined, color: setting != null ? null : Colors.grey.shade600,),
                        ),
                        IconButton(
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
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan of "${widget.loan.name}" was successfully deleted!'), duration: const Duration(seconds: 5)));
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
  }
}
