import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/member_management/models/member.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';

class MemberDialog extends StatefulWidget {
  final Member? member;

  const MemberDialog({super.key, this.member});

  @override
  State<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  bool _isLoading = false;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _numberOfHeadsController = TextEditingController();
  late final TextEditingController _contributionAmountController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _numberOfHeadsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _numberOfHeadsController.text = widget.member!.numberOfHeads.toString();
      _contributionAmountController.text = numberFormatter.format(widget.member!.contributionAmount).toString();
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberOfHeadsController.dispose();
    _contributionAmountController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _addOrEditMember(Member? member) {
    if (_nameController.text.trim().isEmpty || _numberOfHeadsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final Member newOrUpdatedMember = Member(
        name: capitalize(_nameController.text.trim()),
        numberOfHeads: int.parse(_numberOfHeadsController.text),
        contributionAmount: double.parse(_contributionAmountController.text.substring(1).replaceAll(',', '')),
        createdAt: member == null ? DateTime.now() : member.createdAt,
        updatedAt: DateTime.now(),
      );
      Navigator.of(context).pop(<Member>[newOrUpdatedMember]);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: 600,
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(widget.member == null ? 'Add Member' : 'Member', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    style: Theme.of(context).textTheme.titleMedium,
                    focusNode: _nameFocus,
                    onSubmitted: (String _) => _numberOfHeadsFocus.requestFocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _numberOfHeadsController,
                    decoration: const InputDecoration(labelText: 'Number of Heads'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    style: Theme.of(context).textTheme.titleMedium,
                    onChanged: (String value) => _contributionAmountController.text = value.isNotEmpty ? '₱ ${numberFormatter.format((int.parse(value) * 500))}' : '',
                    focusNode: _numberOfHeadsFocus,
                    onSubmitted: (String _) => _addOrEditMember(null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _contributionAmountController,
                    decoration: const InputDecoration(labelText: 'Contribution Amount'),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    enabled: false,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomIconButton(
                        onPressed: () {
                          if (widget.member == null) {
                            _addOrEditMember(null);
                          } else {
                            _addOrEditMember(widget.member!);
                          }
                        },
                        label: widget.member == null ? 'Add' : 'Edit',
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: 4,
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
    );
  }
}
