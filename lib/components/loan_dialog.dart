import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/controllers/member_controller.dart';
import 'package:sinking_fund_manager/controllers/summary_controller.dart';
import 'package:sinking_fund_manager/models/loan_model.dart';
import 'package:sinking_fund_manager/models/loan_tracker_model.dart';
import 'package:sinking_fund_manager/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';

import '../api_services/loans_api_service.dart';
import '../controllers/loan_tracker_controller.dart';
import '../models/member_model.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';

class LoanDialog extends ConsumerStatefulWidget {
  final LoanModel? loan;

  const LoanDialog({super.key, this.loan});

  @override
  ConsumerState<LoanDialog> createState() => _LoanDialogState();
}

class _LoanDialogState extends ConsumerState<LoanDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _comaker = '';
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _loanDateTimeController = TextEditingController();
  final TextEditingController _numberOfGivesController = TextEditingController();
  final TextEditingController _paymentStartDateController = TextEditingController();
  final TextEditingController _totalAmountToPayController = TextEditingController();
  final TextEditingController _payablePerGiveController = TextEditingController();
  final TextEditingController _giveNumberController = TextEditingController();
  final TextEditingController _paymentDueDateController = TextEditingController();
  final TextEditingController _giveAmountController = TextEditingController();
  final TextEditingController _loanAmountAlreadyPaidController = TextEditingController();
  final TextEditingController _remainingLoanController = TextEditingController();
  final FocusNode _nameControllerFocusNode = FocusNode();
  final FocusNode _comakerControllerFocusNode = FocusNode();
  final FocusNode _loanAmountControllerFocusNode = FocusNode();
  final FocusNode _loanDateTimeControllerFocusNode = FocusNode();
  final FocusNode _numberOfGivesControllerFocusNode = FocusNode();
  final FocusNode _escapeKeyFocusNode = FocusNode();
  bool _isLoading = false, _isError = false, _showPercent = false, _showGives = false;
  String _selectedMember = '';
  double _interestAmount = 0, _numberOfMonths = 0, _totalAmountToPay = 0;
  int _numberOfGives = 0, _weekNumber = 0;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _nameController.text = widget.loan!.name;
      _loanAmountController.text = widget.loan!.formattedLoanAmount;
      _loanDateTimeController.text = widget.loan!.formattedLoanDateTime;
      _numberOfGivesController.text = widget.loan!.numberOfGives.toString();
      _giveNumberController.text = widget.loan!.currentGiveNumber.toString();
      _paymentDueDateController.text = widget.loan!.formattedCurrentPaymentDueDate;
      _giveAmountController.text = widget.loan!.formattedCurrentGiveAmount;
      _remainingLoanController.text = widget.loan!.formattedCurrentRemainingAmountToPay;
      _loanAmountAlreadyPaidController.text = numberFormatter.format(widget.loan!.currentTotalAmountToPay - widget.loan!.currentRemainingAmountToPay);
    } else {
      final DateTime now = DateTime.now();
      _loanDateTimeController.text = dateTimeFormatter.format(now);
      _weekNumber = ((now.day - 1) ~/ 7) + 1;
      final int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      if (_weekNumber == 1) {
        _paymentStartDateController.text = dateFormatter.format(DateTime(now.year, now.month, 15));
      } else if (_weekNumber == 2 || _weekNumber == 3) {
        _paymentStartDateController.text = dateFormatter.format(DateTime(now.year, now.month, lastDayOfMonth));
      } else {
        _paymentStartDateController.text = dateFormatter.format(DateTime(now.year, now.month + 1, 15));
      }
      _nameControllerFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _loanAmountController.dispose();
    _loanDateTimeController.dispose();
    _numberOfGivesController.dispose();
    _paymentStartDateController.dispose();
    _totalAmountToPayController.dispose();
    _payablePerGiveController.dispose();
    _nameControllerFocusNode.dispose();
    _comakerControllerFocusNode.dispose();
    _loanAmountControllerFocusNode.dispose();
    _loanDateTimeControllerFocusNode.dispose();
    _numberOfGivesControllerFocusNode.dispose();
    _escapeKeyFocusNode.dispose();
    _giveNumberController.dispose();
    super.dispose();
  }

  void _addLoan() async {
    if (_nameController.text.isEmpty || _loanAmountController.text.isEmpty || _numberOfGivesController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      if (_nameController.text.isEmpty) {
        _nameControllerFocusNode.requestFocus();
      } else if (_loanAmountController.text.isEmpty) {
        _loanAmountControllerFocusNode.requestFocus();
      } else {
        _numberOfGivesControllerFocusNode.requestFocus();
      }
      appendDecimal(_loanAmountController);
      return;
    }
    _isError = false;
    setState(() => _isLoading = true);
    try {
      final String id = const Uuid().v4();
      final bool response = await LoansApiService().addLoan(
        LoanModel(
          id: id,
          name: capitalize(_nameController.text),
          comaker: capitalize(_comaker.trim()),
          loanAmount: numberFormatter.parse(_loanAmountController.text).toDouble(),
          loanDateTime: dateTimeFormatter.parse(_loanDateTimeController.text),
          numberOfGives: int.parse(_numberOfGivesController.text),
          paymentStartDate: dateFormatter.parse(_paymentStartDateController.text),
          totalAmountToPay: numberFormatter.parse(_totalAmountToPayController.text).toDouble(),
          payablePerGive: numberFormatter.parse(_payablePerGiveController.text).toDouble(),
          currentGiveNumber: 1,
          currentGiveInterest: 0,
          currentGiveAmount: numberFormatter.parse(_payablePerGiveController.text).toDouble(),
          currentTotalAmountToPay: numberFormatter.parse(_totalAmountToPayController.text).toDouble(),
          currentRemainingAmountToPay: numberFormatter.parse(_totalAmountToPayController.text).toDouble(),
          currentPaymentDueDate: dateFormatter.parse(_paymentStartDateController.text),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (response) {
        final LoanModel newLoan = await LoansApiService().getLoanById(id);
        if (mounted) Navigator.of(context).pop(<LoanModel>[newLoan]);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Adding new loan failed!', style: TextStyle(color: Colors.white)),
            ),
          );
          return;
        }
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
  }

  void _dateTimePicker() async {
    final DateTime now = DateTime.now();
    final DateTime selectedDateTime = dateTimeFormatter.parse(_loanDateTimeController.text);
    final DateTime firstDate = DateTime(now.year - 3, now.month, now.day);
    final DateTime lastDate = DateTime(now.year + 3, now.month, now.day);
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: selectedDateTime, firstDate: firstDate, lastDate: lastDate);
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDateTime));
      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        _loanDateTimeController.text = dateTimeFormatter.format(fullDateTime);
      }
    }
    appendDecimal(_loanAmountController);
    final DateTime date = pickedDate!;
    _weekNumber = ((date.day - 1) ~/ 7) + 1;
    final int lastDayOfMonth = DateTime(date.year, date.month + 1, 0).day;
    if (_weekNumber == 1) {
      _paymentStartDateController.text = dateFormatter.format(DateTime(date.year, date.month, 15));
    } else if (_weekNumber == 2 || _weekNumber == 3) {
      _paymentStartDateController.text = dateFormatter.format(DateTime(date.year, date.month, lastDayOfMonth));
    } else {
      _paymentStartDateController.text = dateFormatter.format(DateTime(date.year, date.month + 1, 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<LoanTrackerModel> loanTrackersById = <LoanTrackerModel>[];
    double totalLoanTrackerById = 0;
    if (widget.loan != null) {
      final List<LoanTrackerModel> allLoanTrackers = ref.read(loanTrackerControllerProvider);
      loanTrackersById = allLoanTrackers.where((LoanTrackerModel l) => l.loanId == widget.loan?.id).toList();
      loanTrackersById.sort((LoanTrackerModel a, LoanTrackerModel b) => a.paymentDueDate.compareTo(b.paymentDueDate));
      totalLoanTrackerById = loanTrackersById.fold<double>(0.0, (double sum, LoanTrackerModel loanTracker) => sum + loanTracker.giveAmount);
    }
    return Focus(
      focusNode: _escapeKeyFocusNode,
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          if (!_escapeKeyFocusNode.hasFocus) {
            _escapeKeyFocusNode.requestFocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Stack(
              children: <Widget>[
                widget.loan == null
                    ? SizedBox(
                        width: 500,
                        child: Column(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Add Loan', style: Theme.of(context).textTheme.titleLarge),
                                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                focusNode: _nameControllerFocusNode,
                                controller: _nameController,
                                decoration: InputDecoration(labelText: 'Name', prefix: const SizedBox(width: 4), errorText: _isError && _nameController.text.isEmpty ? 'Required' : null),
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                                onSubmitted: (String _) => _comakerControllerFocusNode.requestFocus(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonFormField<String>(
                                focusNode: _comakerControllerFocusNode,
                                style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).textTheme.titleLarge?.color),
                                value: _selectedMember.isNotEmpty ? _selectedMember : null,
                                decoration: const InputDecoration(labelText: 'Comaker (optional)'),
                                items: ref
                                    .read(memberControllerProvider)
                                    .map(
                                      (MemberModel member) => DropdownMenuItem<String>(
                                        value: member.name,
                                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(member.name)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedMember = newValue!;
                                    _comaker = _selectedMember;
                                    _loanAmountControllerFocusNode.requestFocus();
                                  });
                                },
                                onTap: () => _loanAmountControllerFocusNode.requestFocus(),
                                hint: Text(' Select Member', style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5))),
                                icon: const Padding(padding: EdgeInsets.only(right: 4.0), child: Icon(Icons.arrow_drop_down)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: <TextInputFormatter>[
                                  TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) => (double.tryParse(newValue.text) ?? 0) <= ref.read(summaryControllerProvider)!.totalCashOnHand ? newValue : oldValue),
                                  CurrencyFormatter(),
                                ],
                                controller: _loanAmountController,
                                focusNode: _loanAmountControllerFocusNode,
                                decoration: InputDecoration(
                                  prefixText: ' ₱ ',
                                  prefixStyle: TextStyle(color: _isError && _loanAmountController.text.isEmpty ? const Color(0xFFD39992) : Theme.of(context).textTheme.titleMedium?.color, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                  labelText: 'Loan Amount (remaining cash: ₱ ${ref.read(summaryControllerProvider)?.formattedTotalCashOnHand})',
                                  errorText: _isError && _loanAmountController.text.isEmpty ? 'Required' : null,
                                ),
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                                onSubmitted: (String _) {
                                  _dateTimePicker();
                                  _numberOfGivesControllerFocusNode.requestFocus();
                                },
                                onChanged: (String value) {
                                  if (value.isNotEmpty) {
                                    _showPercent = true;
                                    _interestAmount = 0.03 * numberFormatter.parse(_loanAmountController.text);
                                    _totalAmountToPay = numberFormatter.parse(_loanAmountController.text) + (_numberOfMonths * _interestAmount);
                                    if (_showGives) {
                                      _totalAmountToPayController.text = numberFormatter.format(_totalAmountToPay);
                                      _payablePerGiveController.text = numberFormatter.format(_totalAmountToPay / _numberOfGives);
                                    }
                                  } else {
                                    _showPercent = false;
                                    _interestAmount = 0;
                                    _totalAmountToPayController.text = _payablePerGiveController.text = '';
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                            if (_showPercent)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '3% of ₱${_loanAmountController.text} = ₱${numberFormatter.format(_interestAmount)}',
                                  style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _loanDateTimeController,
                                focusNode: _loanDateTimeControllerFocusNode,
                                decoration: InputDecoration(
                                  prefix: const SizedBox(width: 4),
                                  labelText: 'Loan Date Time',
                                  suffixIcon: IconButton(
                                    focusNode: _loanDateTimeControllerFocusNode,
                                    onPressed: () {
                                      _dateTimePicker();
                                      _numberOfGivesControllerFocusNode.requestFocus();
                                    },
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ),
                                readOnly: true,
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _numberOfGivesController,
                                focusNode: _numberOfGivesControllerFocusNode,
                                decoration: InputDecoration(labelText: 'No. Of Gives', prefix: const SizedBox(width: 4), errorText: _isError && _numberOfGivesController.text.isEmpty ? 'Required' : null),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                                onChanged: (String value) {
                                  setState(() => _showGives = value.isNotEmpty ? true : false);
                                  if (value.isNotEmpty) {
                                    _numberOfGives = int.parse(_numberOfGivesController.text);
                                    _numberOfMonths = int.parse(_numberOfGivesController.text) / 2;
                                    _totalAmountToPay = numberFormatter.parse(_loanAmountController.text.isNotEmpty ? _loanAmountController.text : '0') + (_numberOfMonths * _interestAmount);
                                    _totalAmountToPayController.text = numberFormatter.format(_totalAmountToPay);
                                    _payablePerGiveController.text = numberFormatter.format(_totalAmountToPay / _numberOfGives);
                                  } else {
                                    _numberOfGives = 0;
                                    _numberOfMonths = 0;
                                    _totalAmountToPayController.text = _payablePerGiveController.text = '';
                                  }
                                },
                                onSubmitted: (String _) => _addLoan(),
                              ),
                            ),
                            if (_showPercent && _showGives)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$_numberOfGives give${_numberOfGives <= 1 ? '' : 's'} => $_numberOfMonths month${_numberOfMonths <= 1 ? '' : 's'} * ₱${numberFormatter.format(_interestAmount)} = ₱${numberFormatter.format(_numberOfMonths * _interestAmount)}',
                                  style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _paymentStartDateController,
                                decoration: const InputDecoration(labelText: 'Payment Start Date', prefix: SizedBox(width: 4)),
                                readOnly: true,
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _payablePerGiveController,
                                decoration: InputDecoration(
                                  prefixText: ' ₱ ',
                                  prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5), fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                  labelText: 'Payable Per Give',
                                ),
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                readOnly: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _totalAmountToPayController,
                                decoration: InputDecoration(
                                  prefixText: ' ₱ ',
                                  prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5), fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                  labelText: 'Total Amount To Pay',
                                ),
                                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                readOnly: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CustomIconButton(
                                      onPressed: () => _addLoan(),
                                      label: 'Add Loan',
                                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                      borderRadius: 4,
                                      foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 500,
                        child: Column(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Loan', style: Theme.of(context).textTheme.titleLarge),
                                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                spacing: 8,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(labelText: 'Name', prefix: SizedBox(width: 4)),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).textTheme.titleLarge?.color),
                                      decoration: const InputDecoration(labelText: 'Comaker (optional)'),
                                      items: null,
                                      onChanged: null,
                                      hint: Text(widget.loan?.comaker == '' ? ' None' : ' ${widget.loan!.comaker!}', style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                spacing: 8,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _loanAmountController,
                                      decoration: InputDecoration(
                                        prefixText: ' ₱ ',
                                        prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5), fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                        labelText: 'Loan Amount',
                                      ),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _loanDateTimeController,
                                      decoration: const InputDecoration(prefix: SizedBox(width: 4), labelText: 'Loan Date Time'),
                                      readOnly: true,
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                spacing: 8,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _numberOfGivesController,
                                      decoration: const InputDecoration(labelText: 'No. Of Gives', prefix: SizedBox(width: 4)),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _giveNumberController,
                                      decoration: const InputDecoration(labelText: 'Give No.', prefix: SizedBox(width: 4)),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                spacing: 8,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _paymentDueDateController,
                                      decoration: const InputDecoration(labelText: 'Payment Due Date', prefix: SizedBox(width: 4)),
                                      readOnly: true,
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _giveAmountController,
                                      decoration: InputDecoration(
                                        prefixText: ' ₱ ',
                                        prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5), fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                        labelText:
                                            'Give Amount${widget.loan!.currentGiveInterest > 0 ? ' (${widget.loan?.payablePerGive} + ${((widget.loan?.payablePerGive)! * (widget.loan!.currentGiveInterest / 100)).toStringAsFixed(2)}(${widget.loan!.currentGiveInterest}%))' : ''}',
                                      ),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                spacing: 8,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _loanAmountAlreadyPaidController,
                                      decoration: InputDecoration(
                                        prefixText: ' ₱ ',
                                        prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5), fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                        labelText: 'Loan Amount Already Paid',
                                      ),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _remainingLoanController,
                                      decoration: InputDecoration(
                                        prefixText: ' ₱ ',
                                        prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5), fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                                        labelText: 'Remaining Loan (${(widget.loan!.numberOfGives - widget.loan!.currentGiveNumber) + 1})',
                                      ),
                                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loanTrackersById.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text('No gives paid yet.', style: Theme.of(context).textTheme.titleLarge),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Column(
                                      spacing: 8,
                                      children: <Widget>[
                                        ListView.builder(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                          itemCount: loanTrackersById.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final LoanTrackerModel loanTracker = loanTrackersById[index];
                                            return Card(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              child: ListTile(
                                                title: Text('₱ ${loanTracker.formattedGiveAmount}   ${loanTracker.formattedPaymentDueDate}', style: Theme.of(context).textTheme.titleMedium),
                                                subtitle: Text('Paid Date: ${loanTracker.formattedPaymentDateTime}', style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)),
                                                trailing: loanTracker.proof != null
                                                    ? InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) => Dialog(
                                                              insetPadding: const EdgeInsets.all(16),
                                                              child: InteractiveViewer(child: Image.memory(loanTracker.proof!)),
                                                            ),
                                                          );
                                                        },
                                                        child: Image.memory(loanTracker.proof!),
                                                      )
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total loan: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(totalLoanTrackerById)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
