import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund_manager/controllers/loan_tracker_controller.dart';
import 'package:sinking_fund_manager/models/loan_tracker_model.dart';

import '../../components/footer.dart';
import '../../components/side_nav.dart';
import '../../components/custom_app_bar.dart';
import '../api_services/loans_api_service.dart';
import '../components/confirm_dialog.dart';
import '../components/loan_dialog.dart';
import '../controllers/loan_controller.dart';
import '../controllers/setting_controller.dart';
import '../controllers/summary_controller.dart';
import '../models/loan_model.dart';
import '../models/setting_model.dart';
import '../models/summary_model.dart';
import '../utils/formatters.dart';
import 'loan_item.dart';

class LoanManagementPage extends ConsumerStatefulWidget {
  const LoanManagementPage({super.key});

  @override
  ConsumerState<LoanManagementPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<LoanManagementPage> {
  bool _isLoading = true;
  LoanSortType _selectedSortType = LoanSortType.name;
  LoanSortDirection _selectedSortDirection = LoanSortDirection.ascending;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) async {
      try {
        ref.read(loanControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
        if (ref.read(settingControllerProvider) == null && mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Need to setup settings first!', style: TextStyle(color: Colors.white)),
            ),
          );
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLoan() async {
    final List<dynamic>? result = await showDialog(barrierDismissible: false, context: context, builder: (BuildContext _) => const LoanDialog(loan: null));
    if (result != null && result.isNotEmpty) {
      final LoanModel newLoan = result.first;
      ref.read(loanControllerProvider.notifier).addLoan(newLoan);
      ref.read(loanControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Loan of "${newLoan.name}" was successfully added!', style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  Widget _buildLargeScreenHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Loans List', style: Theme.of(context).textTheme.titleLarge),
        Row(
          children: <Widget>[
            Text('Sort by: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<LoanSortType>(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              value: _selectedSortType,
              onChanged: (LoanSortType? sortType) {
                if (sortType != null) {
                  setState(() => _selectedSortType = sortType);
                  ref.read(loanControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: LoanSortType.values.map((LoanSortType type) {
                final String label = switch (type) {
                  LoanSortType.name => 'Name',
                  LoanSortType.loanAmount => 'Loan Amount',
                  LoanSortType.loanDateTime => 'Loan Date Time',
                  LoanSortType.numberOfGives => 'Number Of Gives',
                  LoanSortType.paymentStartDate => 'Payment Start Date',
                  LoanSortType.totalAmountToPay => 'Total Amount',
                  LoanSortType.payablePerGive => 'Payable Per Give',
                };
                return DropdownMenuItem<LoanSortType>(value: type, child: Text(label));
              }).toList(),
            ),
            const SizedBox(width: 16),
            Text('Direction: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<LoanSortDirection>(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              value: _selectedSortDirection,
              onChanged: (LoanSortDirection? value) {
                if (value != null) {
                  setState(() => _selectedSortDirection = value);
                  ref.read(loanControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: LoanSortDirection.values.map((LoanSortDirection dir) {
                final String label = switch (dir) {
                  LoanSortDirection.ascending => 'Ascending',
                  LoanSortDirection.descending => 'Descending',
                };
                return DropdownMenuItem<LoanSortDirection>(value: dir, child: Text(label));
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Sort by: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<LoanSortType>(
              value: _selectedSortType,
              onChanged: (LoanSortType? sortType) {
                if (sortType != null) {
                  setState(() => _selectedSortType = sortType);
                  ref.read(loanControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: LoanSortType.values.map((LoanSortType type) {
                final String label = switch (type) {
                  LoanSortType.name => 'Name',
                  LoanSortType.loanAmount => 'Loan Amount',
                  LoanSortType.loanDateTime => 'Loan Date Time',
                  LoanSortType.numberOfGives => 'Number Of Gives',
                  LoanSortType.paymentStartDate => 'Payment Start Date',
                  LoanSortType.totalAmountToPay => 'Total Amount To Pay',
                  LoanSortType.payablePerGive => 'Payable Per Give',
                };
                return DropdownMenuItem<LoanSortType>(
                  value: type,
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(label)),
                );
              }).toList(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Direction: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<LoanSortDirection>(
              value: _selectedSortDirection,
              onChanged: (LoanSortDirection? value) {
                if (value != null) {
                  setState(() => _selectedSortDirection = value);
                  ref.read(loanControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: LoanSortDirection.values.map((LoanSortDirection dir) {
                final String label = switch (dir) {
                  LoanSortDirection.ascending => 'Ascending',
                  LoanSortDirection.descending => 'Descending',
                };
                return DropdownMenuItem<LoanSortDirection>(
                  value: dir,
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(label)),
                );
              }).toList(),
            ),
          ],
        ),
        Text('Loans List', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LoanModel> loans = ref.watch(loanControllerProvider);
    final SummaryModel? summary = ref.watch(summaryControllerProvider);
    final SettingModel? setting = ref.watch(settingControllerProvider);
    final List<LoanTrackerModel> loanTrackers = ref.watch(loanTrackerControllerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Loan',
        onPressed: setting != null ? _addLoan : null,
        backgroundColor: setting != null ? null : Colors.grey.shade700,
        child: Icon(Icons.add, color: setting != null ? null : Colors.white),
      ),
      appBar: const CustomAppBar(title: 'Loan Management'),
      drawer: SideNav(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : loans.isEmpty
          ? Center(child: Text('No loans found.', style: Theme.of(context).textTheme.titleLarge))
          : LayoutBuilder(
              builder: (BuildContext _, BoxConstraints constraints) {
                final bool isSmallScreen = constraints.maxWidth < 600;
                return Column(
                  spacing: 8,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: isSmallScreen ? _buildSmallScreenHeader() : _buildLargeScreenHeader()),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        interactive: true,
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: Column(
                                spacing: 8,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                      spacing: 32,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total paid loan: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(summary?.totalPaidLoan)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total unpaid loan: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(summary?.totalUnpaidLoan)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total loan: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(summary?.totalLoan)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total interest: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(summary?.totalInterestAmount)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: loans.length,
                                    itemBuilder: (BuildContext ctx, int idx) => Dismissible(
                                      key: ValueKey<String>(loans[idx].id),
                                      confirmDismiss: (DismissDirection direction) async {
                                        if (loanTrackers.where(( LoanTrackerModel lt) => lt.loanId == loans[idx].id).isNotEmpty) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Only loans haven't paid can be deleted.", style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return false;
                                        }
                                        return await showConfirmDialog(context: context, title: 'Confirm Deletion', message: 'Are you sure you want to delete loan of "${loans[idx].name}"?', confirmText: 'Delete', cancelText: 'Cancel');
                                      },
                                      onDismissed: (DismissDirection direction) async {
                                        setState(() => _isLoading = true);
                                        try {
                                          await LoansApiService().deleteLoanById(loans[idx].id);
                                          if (context.mounted) {
                                            ref.read(loanControllerProvider.notifier).deleteLoan(loans[idx]);
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan of "${loans[idx].name}" was successfully deleted!')));
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
                                      background: Container(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75), margin: Theme.of(context).cardTheme.margin),
                                      child: LoanItem(loan: loans[idx]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Footer(),
                  ],
                );
              },
            ),
    );
  }
}
