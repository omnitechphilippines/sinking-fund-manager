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
  final double contributionAmount;

  const ContributionDialog({super.key, required this.name, required this.contributionAmount});

  @override
  State<ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<ContributionDialog> {
  bool _isLoading = false;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _contributionAmountController = TextEditingController();
  late final TextEditingController _paymentDateTimeController = TextEditingController();
  final FocusNode _paymentDateTimeControllerFocusNode = FocusNode();
  Uint8List? _proofImageBytes;
  String? _proofImageName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _nameController.text = widget.name;
      _contributionAmountController.text = '₱ ${numberFormatter.format(widget.contributionAmount)}';
      _paymentDateTimeController.text = dateTimeFormatter.format(DateTime.now());
      _paymentDateTimeControllerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contributionAmountController.dispose();
    _paymentDateTimeController.dispose();
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
    setState(() => _isLoading = true);
    try {
      final String id = const Uuid().v4();
      final String response = await ContributionsApiService().addContribution(
        Contribution(
          id: id,
          name: widget.name,
          contributionAmount: double.parse(_contributionAmountController.text.substring(1).replaceAll(',', '')),
          paymentDateTime: dateTimeFormatter.parse(_paymentDateTimeController.text),
          proof: _proofImageBytes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (response == 'success') {
        final Contribution newContribution = await ContributionsApiService().getContributionById(id);
        if (mounted) Navigator.of(context).pop(<Contribution>[newContribution]);
      } else {
        if (mounted) {
          final String dateTime = dateTimeFormatter.format(dateTimeFormatter.parse(_paymentDateTimeController.text));
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Adding new contribution to "${widget.name}" on ${dateTime} failed!', style: const TextStyle(color: Colors.white)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Add Contribution', style: Theme.of(context).textTheme.titleLarge),
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
                              decoration: const InputDecoration(labelText: 'Name'),
                              style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _contributionAmountController,
                              decoration: const InputDecoration(labelText: 'Contribution Amount'),
                              readOnly: true,
                              onSubmitted: (String _) {
                                _contributionAmountController.text = _contributionAmountController.text.contains(',') || _contributionAmountController.text.isEmpty
                                    ? _contributionAmountController.text
                                    : numberFormatter.format(int.parse(_contributionAmountController.text));
                                _dateTimePicker();
                              },
                              style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
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
                                    onSubmitted: (String _) {
                                      _contributionAmountController.text = _contributionAmountController.text.contains(',') || _contributionAmountController.text.isEmpty
                                          ? _contributionAmountController.text
                                          : numberFormatter.format(int.parse(_contributionAmountController.text));
                                      _addContribution();
                                    },
                                    readOnly: true,
                                    style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                                  ),
                                ),
                                IconButton(focusNode: _paymentDateTimeControllerFocusNode, onPressed: _dateTimePicker, icon: const Icon(Icons.calendar_month)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Upload Proof (Optional):', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                      onPressed: _pickProofImage,
                                      icon: const Icon(Icons.upload),
                                      label: const Text('Choose Image'),
                                    ),
                                    const SizedBox(width: 16),
                                    if (_proofImageName != null) Text(_proofImageName!, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
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
                        ],
                      ),
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
      ),
    );
  }
}
