import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sinking_fund_manager/pages/member_management/controllers/members_api_service.dart';
import 'package:uuid/uuid.dart';

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
  final FocusNode _nameControllerFocusNode = FocusNode();
  final FocusNode _numberOfHeadsControllerFocusNode = FocusNode();
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _numberOfHeadsController.text = widget.member!.numberOfHeads.toString();
      _contributionAmountController.text = numberFormatter.format(widget.member!.contributionAmount).toString();
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _nameControllerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberOfHeadsController.dispose();
    _contributionAmountController.dispose();
    _nameControllerFocusNode.dispose();
    _numberOfHeadsControllerFocusNode.dispose();
    super.dispose();
  }

  void _addMember() async {
    if (_nameController.text.trim().isEmpty || _numberOfHeadsController.text.isEmpty) {
      setState(() => _isError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      _nameController.text.isEmpty ? _nameControllerFocusNode.requestFocus() : _numberOfHeadsControllerFocusNode.requestFocus();
      return;
    }
    _isError = false;
    setState(() => _isLoading = true);
    try {
      final String id = const Uuid().v4();
      final String response = await MembersApiService().addMember(
        Member(
          id: id,
          name: capitalize(_nameController.text.trim()),
          numberOfHeads: int.parse(_numberOfHeadsController.text),
          contributionAmount: double.parse(_contributionAmountController.text.substring(1).replaceAll(',', '')),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (response == 'success') {
        final Member newMember = await MembersApiService().getMemberById(id);
        if (mounted) Navigator.of(context).pop(<Member>[newMember]);
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
                          Text(widget.member == null ? 'Add Member' : 'Member', style: Theme.of(context).textTheme.titleLarge),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name', errorText: _isError && _nameController.text.isEmpty ? 'Required' : null),
                        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: widget.member == null ? 1 : 0.5)),
                        focusNode: widget.member == null ? _nameControllerFocusNode : null,
                        onSubmitted: (String _) => _numberOfHeadsControllerFocusNode.requestFocus(),
                        readOnly: widget.member == null ? false : true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _numberOfHeadsController,
                        decoration: InputDecoration(labelText: 'Number of Heads', errorText: _isError && _numberOfHeadsController.text.isEmpty ? 'Required' : null),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: widget.member == null ? 1 : 0.5)),
                        onChanged: (String value) => _contributionAmountController.text = value.isNotEmpty ? '₱ ${numberFormatter.format((int.parse(value) * 500))}' : '',
                        focusNode: _numberOfHeadsControllerFocusNode,
                        onSubmitted: (String _) => _addMember(),
                        readOnly: widget.member == null ? false : true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _contributionAmountController,
                        decoration: const InputDecoration(labelText: 'Contribution Amount'),
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    widget.member == null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                              color: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CustomIconButton(
                                  onPressed: () => _addMember(),
                                  label: 'Add Member',
                                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                  borderRadius: 4,
                                  foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
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
