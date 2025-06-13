import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../pages/member_management/controllers/contributions_api_service.dart';
import '../pages/member_management/models/contribution.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';

class ContributionDialog extends StatefulWidget {
  final String name;

  const ContributionDialog({super.key, required this.name});

  @override
  State<ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<ContributionDialog> {
  bool _isLoading = false;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _paymentDateTimeController = TextEditingController();
  final FocusNode _amountControllerFocusNode = FocusNode();
  final FocusNode _paymentDateTimeControllerFocusNode = FocusNode();
  Uint8List? _proofImageBytes;
  String? _proofImageName;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _nameController.text = widget.name;
      _paymentDateTimeController.text = dateTimeFormatter.format(DateTime.now());
      _amountControllerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _paymentDateTimeController.dispose();
    _amountControllerFocusNode.dispose();
    _paymentDateTimeControllerFocusNode.dispose();
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
    _amountController.text = _amountController.text.contains(',') || _amountController.text.isEmpty ? _amountController.text : numberFormatter.format(int.parse(_amountController.text));
    if (_amountController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      _amountControllerFocusNode.requestFocus();
      return;
    }
    _isError = false;
    setState(() => _isLoading = true);
    try {
      final String id = const Uuid().v4();
      final String response = await ContributionsApiService().addContribution(
        Contribution(
          id: id,
          name: widget.name,
          amount: double.parse(_amountController.text.substring(1).replaceAll(',', '')),
          paymentDateTime: dateTimeFormatter.parse(_paymentDateTimeController.text),
          proof: _proofImageBytes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (response == 'success') {
        final Contribution newMember = await ContributionsApiService().getContributionById(id);
        if (mounted) Navigator.of(context).pop(<Contribution>[newMember]);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Adding new member failed!', style: TextStyle(color: Colors.white)),
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
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Stack(
          children: <Widget>[
            SizedBox(
              width: 600,
              child: Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Add Contribution', style: Theme.of(context).textTheme.titleLarge),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                      readOnly: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount', prefixText: '₱ ', errorText: _isError && _amountController.text.isEmpty? 'Required' : null),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      focusNode: _amountControllerFocusNode,
                      onSubmitted: (String _) {
                        _amountController.text = _amountController.text.contains(',') || _amountController.text.isEmpty ? _amountController.text : numberFormatter.format(int.parse(_amountController.text));
                        _dateTimePicker();
                      },
                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _paymentDateTimeController,
                            decoration: const InputDecoration(labelText: 'DateTime'),
                            focusNode: _paymentDateTimeControllerFocusNode,
                            onSubmitted: (String _) {
                              _amountController.text = _amountController.text.contains(',') || _amountController.text.isEmpty ? _amountController.text : numberFormatter.format(int.parse(_amountController.text));
                              _addContribution();
                            },
                            readOnly: true,
                            style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                          ),
                        ),
                        IconButton(onPressed: _dateTimePicker, icon: const Icon(Icons.calendar_month)),
                      ],
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Upload Proof (Optional):', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                onPressed: _pickProofImage,
                                icon: const Icon(Icons.upload),
                                label: const Text('Choose Image'),
                              ),
                              const SizedBox(width: 16),
                              if (_proofImageName != null)
                                Expanded(
                                  child: Text(_proofImageName!, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                                ),
                            ],
                          ),
                          if (_proofImageBytes != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                                child: Image.memory(_proofImageBytes!, fit: BoxFit.contain),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    padding: const EdgeInsets.all(12),
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
    );
  }
}
