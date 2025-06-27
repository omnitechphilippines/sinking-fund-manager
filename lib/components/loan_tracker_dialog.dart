import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/api_services/loan_trackers_api_service.dart';
import 'package:sinking_fund_manager/models/loan_model.dart';
import 'package:uuid/uuid.dart';

import '../api_services/loans_api_service.dart';
import '../controllers/loan_tracker_controller.dart';
import '../models/loan_tracker_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';

class LoanTrackerDialog extends ConsumerStatefulWidget {
  final LoanModel loan;

  const LoanTrackerDialog({super.key, required this.loan});

  @override
  ConsumerState<LoanTrackerDialog> createState() => _LoanTrackerDialogState();
}

class _LoanTrackerDialogState extends ConsumerState<LoanTrackerDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _loanDateTimeController = TextEditingController();
  final TextEditingController _numberOfGivesController = TextEditingController();
  final TextEditingController _paymentStartDateController = TextEditingController();
  final TextEditingController _totalAmountToPayController = TextEditingController();
  final TextEditingController _payablePerGiveController = TextEditingController();
  final TextEditingController _giveNumberController = TextEditingController();
  final TextEditingController _giveAmountController = TextEditingController();
  final TextEditingController _loanAmountAlreadyPaidController = TextEditingController();
  final TextEditingController _remainingLoanController = TextEditingController();
  final TextEditingController _paymentDateTimeController = TextEditingController(text: dateTimeFormatter.format(DateTime.now()));
  final FocusNode _giveAmountControllerFocusNode = FocusNode();
  final FocusNode _paymentDateTimeControllerFocusNode = FocusNode();
  final FocusNode _escapeKeyFocusNode = FocusNode();
  bool _isLoading = false, _isError = false;
  List<LoanTrackerModel> _loanTrackers = <LoanTrackerModel>[];
  Uint8List? _proofImageBytes;
  String? _proofImageName;

  @override
  void initState() {
    super.initState();
    _loanTrackers = ref.read(loanTrackerControllerProvider);
    _giveAmountControllerFocusNode.requestFocus();
    _nameController.text = widget.loan.name;
    _loanAmountController.text = widget.loan.formattedLoanAmount;
    _loanDateTimeController.text = widget.loan.formattedLoanDateTime;
    _numberOfGivesController.text = widget.loan.numberOfGives.toString();
    _giveNumberController.text = _loanTrackers.isNotEmpty ? _loanTrackers[0].giveNumber.toString() : '1';
    _giveAmountController.text = widget.loan.formattedCurrentGiveAmount;
    _remainingLoanController.text = widget.loan.formattedCurrentRemainingAmountToPay;
    _loanAmountAlreadyPaidController.text = _loanTrackers.isNotEmpty ? _loanTrackers[0].formattedGiveAmount : numberFormatter.format(0);
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
    _giveAmountControllerFocusNode.dispose();
    _escapeKeyFocusNode.dispose();
    _giveNumberController.dispose();
    _paymentDateTimeControllerFocusNode.dispose();
    super.dispose();
  }

  void _addLoanTracker() async {
    if (_giveAmountController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      _giveAmountControllerFocusNode.requestFocus();
      return;
    }
    appendDecimal(_giveAmountController);
    _isError = false;
    setState(() => _isLoading = true);
    try {
      final String id = const Uuid().v4();
      final bool isFullyPaid = double.parse(_giveAmountController.text) == widget.loan.currentGiveAmount;
      final bool response = await LoanTrackersApiService().addLoanTracker(
        LoanTrackerModel(
          id: id,
          loanId: widget.loan.id,
          loanName: widget.loan.name,
          paymentDueDate: widget.loan.currentPaymentDueDate,
          giveNumber: widget.loan.currentGiveNumber,
          interestRate: widget.loan.currentGiveInterest,
          giveAmount: double.parse(_giveAmountController.text),
          remainingGiveAmount: widget.loan.currentGiveAmount - double.parse(_giveAmountController.text),
          paymentDateTime: dateTimeFormatter.parse(_paymentDateTimeController.text),
          proof: _proofImageBytes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        _proofImageName,
      );
      if (response) {
        final DateTime now = DateTime.now();
        final int weekNumber = ((now.day - 1) ~/ 7) + 1;
        final int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        DateTime newDueDate;
        if (weekNumber == 1) {
          newDueDate = DateTime(now.year, now.month, 15);
        } else if (weekNumber == 2 || weekNumber == 3) {
          newDueDate = DateTime(now.year, now.month, lastDayOfMonth);
        } else {
          newDueDate = DateTime(now.year, now.month + 1, 15);
        }
        final LoanModel updatedLoan = widget.loan.copyWith(
          currentGiveNumber: isFullyPaid && widget.loan.currentGiveNumber != widget.loan.numberOfGives ? widget.loan.currentGiveNumber + 1 : widget.loan.currentGiveNumber,
          currentGiveInterest: 0,
          currentGiveAmount: isFullyPaid ? widget.loan.payablePerGive : widget.loan.currentGiveAmount - double.parse(_giveAmountController.text),
          currentRemainingAmountToPay: widget.loan.currentRemainingAmountToPay - double.parse(_giveAmountController.text),
          currentPaymentDueDate: newDueDate,
        );
        final bool response2 = await LoansApiService().updateLoan(updatedLoan);
        if (response2 && mounted) Navigator.of(context).pop(<LoanModel>[updatedLoan]);
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
    final DateTime selectedDateTime = dateTimeFormatter.parse(_paymentDateTimeController.text);
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
    appendDecimal(_giveAmountController);
  }

  Future<void> _pickProofImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _proofImageBytes = result.files.single.bytes;
        _proofImageName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
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
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.titleLarge,
                                children: <InlineSpan>[
                                  const TextSpan(text: 'Pay Loan for:   '),
                                  TextSpan(
                                    text: widget.loan.formattedCurrentPaymentDueDate,
                                    style: TextStyle(color: DateTime.now().difference(widget.loan.paymentStartDate).inDays > 0 ? Colors.red : Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 8,
                            children: <Widget>[
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
                                        hint: Text(widget.loan.comaker == '' ? ' None' : ' ${widget.loan.comaker!}', style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5))),
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
                                        controller: _giveAmountController,
                                        focusNode: _giveAmountControllerFocusNode,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: <TextInputFormatter>[
                                          TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) => (int.tryParse(newValue.text) ?? 0) <= widget.loan.currentGiveAmount ? newValue : oldValue),
                                          CurrencyFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          prefixText: ' ₱ ',
                                          prefixStyle: TextStyle(
                                            color: _isError && _giveAmountController.text.isEmpty ? const Color(0xFFD39992) : Theme.of(context).textTheme.titleMedium?.color,
                                            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                                          ),
                                          labelText:
                                              'Give Amount${widget.loan.currentGiveInterest > 0 ? ' (${widget.loan.payablePerGive} + ${((widget.loan.payablePerGive) * (widget.loan.currentGiveInterest / 100)).toStringAsFixed(2)}(${widget.loan.currentGiveInterest}%))' : ''}',
                                          errorText: _isError && _giveAmountController.text.isEmpty ? 'Required' : null,
                                        ),
                                        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _paymentDateTimeController,
                                        focusNode: _paymentDateTimeControllerFocusNode,
                                        decoration: InputDecoration(
                                          prefix: const SizedBox(width: 4),
                                          labelText: 'Payment Date Time',
                                          suffixIcon: IconButton(
                                            focusNode: _paymentDateTimeControllerFocusNode,
                                            onPressed: () {
                                              appendDecimal(_giveAmountController);
                                              _dateTimePicker();
                                            },
                                            icon: const Icon(Icons.calendar_month),
                                          ),
                                        ),
                                        onSubmitted: (String _) {
                                          appendDecimal(_giveAmountController);
                                          _addLoanTracker();
                                        },
                                        readOnly: true,
                                        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                        onTap: () => appendDecimal(_giveAmountController),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: <Widget>[
                                    Text('Upload Proof (Optional):', style: Theme.of(context).textTheme.titleMedium),
                                    Row(
                                      spacing: 16,
                                      children: <Widget>[
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                          onPressed: () {
                                            _pickProofImage();
                                            appendDecimal(_giveAmountController);
                                          },
                                          icon: const Icon(Icons.upload),
                                          label: const Text('Choose Image'),
                                        ),
                                        if (_proofImageName != null)
                                          Expanded(
                                            child: Text(_proofImageName!, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                                          ),
                                        if (_proofImageName != null)
                                          IconButton(
                                            onPressed: () {
                                              _proofImageName = null;
                                              _proofImageBytes = null;
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                      ],
                                    ),
                                    if (_proofImageBytes != null)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: InkWell(
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (BuildContext context) => Dialog(child: InteractiveViewer(child: Image.memory(_proofImageBytes!))),
                                            ),
                                            child: Image.memory(_proofImageBytes!),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                onPressed: () => _addLoanTracker(),
                                label: 'Pay Loan',
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
