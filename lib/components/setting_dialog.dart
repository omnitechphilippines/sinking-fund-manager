import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/api_services/settings_api_service.dart';

import '../controllers/setting_controller.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';
import '../models/setting_model.dart';

class SettingDialog extends ConsumerStatefulWidget {
  const SettingDialog({super.key});

  @override
  ConsumerState<SettingDialog> createState() => _SettingDialogState();
}

class _SettingDialogState extends ConsumerState<SettingDialog> {
  bool _isLoading = false;
  final TextEditingController _amountPerHeadController = TextEditingController();
  final TextEditingController _startingDateController = TextEditingController();
  final FocusNode _amountPerHeadControllerFocusNode = FocusNode();
  ContributionPeriod? _selectedContributionPeriodType;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _amountPerHeadControllerFocusNode.requestFocus();
    final SettingModel? setting = ref.read(settingControllerProvider);
    if (setting != null) {
      _amountPerHeadController.text = numberFormatter.format(setting.amountPerHead);
      _selectedContributionPeriodType = setting.contributionPeriod;
      _startingDateController.text = dateFormatter.format(setting.startingDate);
    } else {
      _selectedContributionPeriodType = ContributionPeriod.quincena;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _amountPerHeadController.dispose();
    _startingDateController.dispose();
    _amountPerHeadControllerFocusNode.dispose();
    super.dispose();
  }

  void _datePicker() async {
    final DateTime now = DateTime.now();
    final DateTime parsedDate = _startingDateController.text.isNotEmpty ? dateFormatter.parse(_startingDateController.text) : now;

    final DateTime firstDate = DateTime(now.year - 3, now.month, 1);
    final DateTime lastDate = DateTime(now.year + 3, now.month + 1, 0);

    DateTime initialDate = parsedDate;
    final int lastDayOfMonth = DateTime(parsedDate.year, parsedDate.month + 1, 0).day;
    final bool is15 = parsedDate.day == 15;
    final bool isMonthEnd = parsedDate.day == lastDayOfMonth;

    if (_selectedContributionPeriodType == ContributionPeriod.quincena) {
      if (!is15 && !isMonthEnd) {
        initialDate = DateTime(parsedDate.year, parsedDate.month, 15);
      }
    } else {
      if (!isMonthEnd) {
        initialDate = DateTime(parsedDate.year, parsedDate.month, lastDayOfMonth);
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime day) {
        final int lastDay = DateTime(day.year, day.month + 1, 0).day;
        if (_selectedContributionPeriodType == ContributionPeriod.quincena) {
          return day.day == 15 || day.day == lastDay;
        } else {
          return day.day == lastDay;
        }
      },
    );

    if (pickedDate != null) {
      _startingDateController.text = dateFormatter.format(pickedDate);
    }
  }

  void _saveSettings() async {
    if (_amountPerHeadController.text.isEmpty || _startingDateController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields!')));
      if (_amountPerHeadController.text.isEmpty) {
        _amountPerHeadControllerFocusNode.requestFocus();
      } else {
        _amountPerHeadController.text = numberFormatter.format(int.parse(_amountPerHeadController.text));
      }
      return;
    }
    if (_selectedContributionPeriodType == ContributionPeriod.monthly && dateFormatter.parse(_startingDateController.text).day == 15) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid starting date!')));
      return;
    }
    _isError = false;
    setState(() => _isLoading = true);
    try {
      final SettingModel newSetting = SettingModel(
        id: 1,
        amountPerHead: double.parse(_amountPerHeadController.text.replaceAll(',', '')),
        contributionPeriod: _selectedContributionPeriodType!,
        startingDate: dateFormatter.parse(_startingDateController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final bool response = ref.read(settingControllerProvider) != null ? await SettingsApiService().editSetting(newSetting) : await SettingsApiService().addSetting(newSetting);
      if (response && mounted) {
        ref.read(settingControllerProvider.notifier).addSetting(newSetting);
        Navigator.of(context).pop(<bool>[true]);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Save settings failed!', style: TextStyle(color: Colors.white)),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        controller: _amountPerHeadController,
                        focusNode: _amountPerHeadControllerFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Amount Per Head',
                          prefixText: '₱ ',
                          labelStyle: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.titleLarge?.color),
                          errorText: _isError && _amountPerHeadController.text.isEmpty ? 'Required' : null,
                        ),
                        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Contribution Period: ',
                            style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.normal, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<ContributionPeriod>(
                              value: _selectedContributionPeriodType,
                              onChanged: (ContributionPeriod? contributionPeriodType) {
                                if (contributionPeriodType != null) {
                                  setState(() => _selectedContributionPeriodType = contributionPeriodType);
                                  FocusScope.of(context).requestFocus(FocusNode());
                                }
                              },
                              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                              items: ContributionPeriod.values.map((ContributionPeriod type) {
                                final String label = switch (type) {
                                  ContributionPeriod.quincena => 'Quincena',
                                  ContributionPeriod.monthly => 'Monthly',
                                };
                                return DropdownMenuItem<ContributionPeriod>(
                                  value: type,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Text(label, style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _startingDateController,
                              decoration: InputDecoration(
                                labelText: 'Starting Date',
                                labelStyle: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.titleLarge?.color),
                                errorText: _isError && _startingDateController.text.isEmpty
                                    ? 'Required'
                                    : _isError
                                    ? 'Invalid'
                                    : null,
                              ),
                              readOnly: true,
                              style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _amountPerHeadController.text = _amountPerHeadController.text.isNotEmpty && !_amountPerHeadController.text.contains('.') ? numberFormatter.format(int.parse(_amountPerHeadController.text)) : _amountPerHeadController.text;
                              _datePicker();
                            },
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomIconButton(
                            onPressed: () => _saveSettings(),
                            label: 'Save Settings',
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
