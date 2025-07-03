import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/controllers/summary_controller.dart';
import 'package:sinking_fund_manager/models/summary_model.dart';
import 'package:uuid/uuid.dart';

import '../api_services/contributions_api_service.dart';
import '../models/contribution_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';

class ContributionDialog extends ConsumerStatefulWidget {
  final String id;
  final String name;
  final double contributionAmount;
  final DateTime contributionDate;
  final double maximumAmountToPay;
  final String hintText;

  const ContributionDialog({super.key, required this.id, required this.name, required this.contributionAmount, required this.contributionDate, required this.maximumAmountToPay, required this.hintText});

  @override
  ConsumerState<ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends ConsumerState<ContributionDialog> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contributionAmountController = TextEditingController();
  final TextEditingController _paymentDateTimeController = TextEditingController(text: dateTimeFormatter.format(DateTime.now()));
  final FocusNode _contributionAmountControllerFocusNode = FocusNode();
  final FocusNode _escapeKeyFocusNode = FocusNode();
  Uint8List? _proofImageBytes;
  String? _proofImageName;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _contributionAmountControllerFocusNode.requestFocus();
    _contributionAmountController.text = widget.maximumAmountToPay.toString();
    appendDecimal(_contributionAmountController);
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contributionAmountController.dispose();
    _paymentDateTimeController.dispose();
    _contributionAmountControllerFocusNode.dispose();
    _escapeKeyFocusNode.dispose();
    super.dispose();
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

  void _addContribution() async {
    if (_contributionAmountController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      _contributionAmountControllerFocusNode.requestFocus();
      return;
    }
    _isError = false;
    setState(() => _isLoading = true);
    try {
      appendDecimal(_contributionAmountController);
      final SummaryModel? summary = ref.read(summaryControllerProvider);
      final String id = const Uuid().v4();
      final bool response = await ContributionsApiService().addContribution(
        ContributionModel(
          id: id,
          memberId: widget.id,
          memberName: widget.name,
          contributionDate: widget.contributionDate,
          contributionAmount: numberFormatter.parse(_contributionAmountController.text).toDouble(),
          paymentDateTime: dateTimeFormatter.parse(_paymentDateTimeController.text),
          proof: _proofImageBytes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        _proofImageName,
      );
      if (response) {
        final ContributionModel newContribution = await ContributionsApiService().getContributionById(id);
        ref.read(summaryControllerProvider.notifier).editSummary(totalContribution: summary!.totalContribution + newContribution.contributionAmount,totalCashOnHand: summary.totalCashOnHand + newContribution.contributionAmount);
        if (mounted) Navigator.of(context).pop(<ContributionModel>[newContribution]);
      } else {
        if (mounted) {
          final String dateTime = dateTimeFormatter.format(dateTimeFormatter.parse(_paymentDateTimeController.text));
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Adding new contribution to member "${widget.name}" on $dateTime failed!', style: const TextStyle(color: Colors.white)),
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
        _paymentDateTimeController.text = dateTimeFormatter.format(fullDateTime);
      }
    }
    appendDecimal(_contributionAmountController);
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
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
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
                                  const TextSpan(text: 'Add Contribution for:   '),
                                  TextSpan(
                                    text: dateFormatter.format(widget.contributionDate),
                                    style: TextStyle(color: DateTime.now().difference(widget.contributionDate).inDays > 0 ? Colors.red : Colors.blue),
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
                                child: TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(labelText: 'Name', prefix: SizedBox(width: 4)),
                                  style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                  readOnly: true,
                                  onTap: () => appendDecimal(_contributionAmountController),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: _contributionAmountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: <TextInputFormatter>[
                                    TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) => (double.tryParse(newValue.text) ?? 0) <= widget.maximumAmountToPay ? newValue : oldValue),
                                    CurrencyFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    prefixText: ' ₱ ',
                                    prefixStyle: TextStyle(
                                      color: _isError && _contributionAmountController.text.isEmpty ? const Color(0xFFD39992) : Theme.of(context).textTheme.titleMedium?.color,
                                      fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                                    ),
                                    labelText: 'Contribution Amount (${widget.hintText})',
                                    errorText: _isError && _contributionAmountController.text.isEmpty ? 'Required' : null,
                                  ),
                                  onSubmitted: (String _) {
                                    appendDecimal(_contributionAmountController);
                                    _dateTimePicker();
                                  },
                                  focusNode: _contributionAmountControllerFocusNode,
                                  style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: _paymentDateTimeController,
                                  decoration: InputDecoration(
                                    prefix: const SizedBox(width: 4),
                                    labelText: 'Payment Date Time',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        appendDecimal(_contributionAmountController);
                                        _dateTimePicker();
                                      },
                                      icon: const Icon(Icons.calendar_month),
                                    ),
                                  ),
                                  onSubmitted: (String _) {
                                    appendDecimal(_contributionAmountController);
                                    _addContribution();
                                  },
                                  readOnly: true,
                                  style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                  onTap: () => appendDecimal(_contributionAmountController),
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
                                            appendDecimal(_contributionAmountController);
                                          },
                                          icon: const Icon(Icons.upload),
                                          label: const Text('Choose Image'),
                                        ),
                                        if (_proofImageName != null)
                                          Expanded(
                                            child: Text(_proofImageName!, overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.titleMedium),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomIconButton(
                              onPressed: _addContribution,
                              label: 'Add Contribution',
                              backgroundColor: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: 4,
                              foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
