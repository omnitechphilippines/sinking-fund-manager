import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/api_services/settings_api_service.dart';

import '../controllers/setting_controller.dart';
import '../utils/currency_formatter.dart';
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
  final TextEditingController _maxNumberOfGivesController = TextEditingController();
  final TextEditingController _startingDateController = TextEditingController();
  final FocusNode _amountPerHeadControllerFocusNode = FocusNode();
  final FocusNode _contributionPeriodControllerFocusNode = FocusNode();
  final FocusNode _maxNumberOfGivesControllerFocusNode = FocusNode();
  final FocusNode _startingDateControllerFocusNode = FocusNode();
  final FocusNode _escapeKeyFocusNode = FocusNode();
  ContributionPeriod? _selectedContributionPeriodType;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _amountPerHeadControllerFocusNode.requestFocus();
    final SettingModel? setting = ref.read(settingControllerProvider);
    if (setting != null) {
      _amountPerHeadController.text = setting.formattedAmountPerHead;
      _selectedContributionPeriodType = setting.contributionPeriod;
      _maxNumberOfGivesController.text = setting.maxNumberOfGives.toString();
      _startingDateController.text = dateFormatter.format(setting.startingDate);
    } else {
      _selectedContributionPeriodType = ContributionPeriod.quincena;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _amountPerHeadController.dispose();
    _maxNumberOfGivesController.dispose();
    _startingDateController.dispose();
    _amountPerHeadControllerFocusNode.dispose();
    _contributionPeriodControllerFocusNode.dispose();
    _maxNumberOfGivesControllerFocusNode.dispose();
    _startingDateControllerFocusNode.dispose();
    _escapeKeyFocusNode.dispose();
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
    if (_amountPerHeadController.text.isEmpty || _maxNumberOfGivesController.text.isEmpty || _startingDateController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields!')));
      if (_amountPerHeadController.text.isEmpty) {
        _amountPerHeadControllerFocusNode.requestFocus();
      } else if (_maxNumberOfGivesController.text.isEmpty) {
        _maxNumberOfGivesControllerFocusNode.requestFocus();
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
        amountPerHead: numberFormatter.parse(_amountPerHeadController.text).toDouble(),
        contributionPeriod: _selectedContributionPeriodType!,
        maxNumberOfGives: int.parse(_maxNumberOfGivesController.text),
        startingDate: dateFormatter.parse(_startingDateController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final bool response = ref.read(settingControllerProvider) != null ? await SettingsApiService().updateSetting(newSetting) : await SettingsApiService().addSetting(newSetting);
      if (response && mounted) {
        ref.read(settingControllerProvider.notifier).editSetting(newSetting);
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
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, CurrencyFormatter()],
                          controller: _amountPerHeadController,
                          focusNode: _amountPerHeadControllerFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Amount Per Head',
                            prefixText: ' ₱ ',
                            prefixStyle: TextStyle(color: _isError && _amountPerHeadController.text.isEmpty ? const Color(0xFFD39992) : Theme.of(context).textTheme.titleMedium?.color, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
                            errorText: _isError && _amountPerHeadController.text.isEmpty ? 'Required' : null,
                          ),
                          style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                          onSubmitted: (String _) => _contributionPeriodControllerFocusNode.requestFocus(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<ContributionPeriod>(
                          focusNode: _contributionPeriodControllerFocusNode,
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).textTheme.titleLarge?.color),
                          value: _selectedContributionPeriodType,
                          decoration: InputDecoration(
                            labelText: 'Contribution Period',
                            labelStyle: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.titleLarge?.color),
                          ),
                          onChanged: (ContributionPeriod? contributionPeriodType) {
                            if (contributionPeriodType != null) {
                              setState(() => _selectedContributionPeriodType = contributionPeriodType);
                              _maxNumberOfGivesControllerFocusNode.requestFocus();
                            }
                          },
                          onTap: () {
                            _maxNumberOfGivesControllerFocusNode.requestFocus();
                            appendDecimal(_amountPerHeadController);
                          },
                          items: ContributionPeriod.values.map((ContributionPeriod type) {
                            final String label = switch (type) {
                              ContributionPeriod.quincena => 'Quincena',
                              ContributionPeriod.monthly => 'Monthly',
                            };
                            return DropdownMenuItem<ContributionPeriod>(
                              value: type,
                              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(label)),
                            );
                          }).toList(),
                          icon: const Padding(padding: EdgeInsets.only(right: 4.0), child: Icon(Icons.arrow_drop_down)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, CurrencyFormatter()],
                          controller: _maxNumberOfGivesController,
                          focusNode: _maxNumberOfGivesControllerFocusNode,
                          decoration: InputDecoration(labelText: 'Max. Number Of Gives', errorText: _isError && _maxNumberOfGivesController.text.isEmpty ? 'Required' : null),
                          style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                          onSubmitted: (String _) {
                            _datePicker();
                            _startingDateControllerFocusNode.requestFocus();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          focusNode: _startingDateControllerFocusNode,
                          controller: _startingDateController,
                          decoration: InputDecoration(
                            labelText: 'Starting Date',
                            prefix: const SizedBox(width: 4),
                            labelStyle: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.titleLarge?.color),
                            errorText: _isError && _startingDateController.text.isEmpty
                                ? 'Required'
                                : _isError
                                ? 'Invalid'
                                : null,
                            suffixIcon: IconButton(
                              focusNode: _startingDateControllerFocusNode,
                              onPressed: () {
                                appendDecimal(_amountPerHeadController);
                                _datePicker();
                              },
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ),
                          readOnly: true,
                          style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                          onTap: () => appendDecimal(_amountPerHeadController),
                        ),
                      ),
                      const SizedBox(height: 8),
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
      ),
    );
  }
}
