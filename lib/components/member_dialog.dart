import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/models/contribution_model.dart';
import 'package:uuid/uuid.dart';

import '../api_services/contributions_api_service.dart';
import '../api_services/members_api_service.dart';
import '../controllers/contribution_controller.dart';
import '../controllers/setting_controller.dart';
import '../models/member_model.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/custom_icon_button.dart';
import 'confirm_dialog.dart';

class MemberDialog extends ConsumerStatefulWidget {
  final MemberModel? member;

  const MemberDialog({super.key, this.member});

  @override
  ConsumerState<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends ConsumerState<MemberDialog> {
  bool _isLoading = false;
  bool _isDeleteLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberOfHeadsController = TextEditingController();
  final TextEditingController _contributionAmountController = TextEditingController();
  final FocusNode _nameControllerFocusNode = FocusNode();
  final FocusNode _numberOfHeadsControllerFocusNode = FocusNode();
  final FocusNode _escapeKeyFocusNode = FocusNode();
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _numberOfHeadsController.text = widget.member!.numberOfHeads.toString();
      _contributionAmountController.text = widget.member!.formattedContributionAmount;
    }
    _nameControllerFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberOfHeadsController.dispose();
    _contributionAmountController.dispose();
    _nameControllerFocusNode.dispose();
    _numberOfHeadsControllerFocusNode.dispose();
    _escapeKeyFocusNode.dispose();
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
      final bool response = await MembersApiService().addMember(
        MemberModel(
          id: id,
          name: capitalize(_nameController.text.trim()),
          numberOfHeads: int.parse(_numberOfHeadsController.text),
          contributionAmount: numberFormatter.parse(_contributionAmountController.text).toDouble(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (response) {
        final MemberModel newMember = await MembersApiService().getMemberById(id);
        if (mounted) Navigator.of(context).pop(<MemberModel>[newMember]);
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
    double totalContributionById = 0;
    List<ContributionModel> contributionsById = <ContributionModel>[];
    List<ContributionModel> latestContributionsPerQuincena = <ContributionModel>[];
    if (widget.member != null) {
      // contributionsById = ref.watch(contributionControllerProvider.notifier).getContributionsByMemberId(widget.member!.id);
      contributionsById = ref.watch(contributionsByMemberIdProvider(widget.member!.id));

      if (contributionsById.isNotEmpty) {
        final DateTime latestDate = contributionsById.last.contributionDate;
        latestContributionsPerQuincena = contributionsById.where((ContributionModel c) => c.contributionDate == latestDate).toList();
      }

      totalContributionById = contributionsById.fold<double>(0.0, (double sum, ContributionModel c) => sum + c.contributionAmount);
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
                SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
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
                              Text(widget.member == null ? 'Add Member' : 'Member', style: Theme.of(context).textTheme.titleLarge),
                              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Name', errorText: _isError && _nameController.text.isEmpty ? 'Required' : null, prefix: const SizedBox(width: 4)),
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
                            decoration: InputDecoration(labelText: 'Number of Heads', errorText: _isError && _numberOfHeadsController.text.isEmpty ? 'Required' : null, prefix: const SizedBox(width: 4)),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: widget.member == null ? 1 : 0.5)),
                            onChanged: (String value) => _contributionAmountController.text = value.isNotEmpty ? numberFormatter.format((int.parse(value) * ref.read(settingControllerProvider)!.amountPerHead)) : '',
                            focusNode: _numberOfHeadsControllerFocusNode,
                            onSubmitted: (String _) => _addMember(),
                            readOnly: widget.member == null ? false : true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _contributionAmountController,
                            decoration: InputDecoration(
                              labelText: 'Contribution Amount',
                              prefixText: ' ₱ ',
                              prefixStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.5)),
                          ),
                        ),
                        widget.member == null
                            ? Padding(
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
                                ),
                              )
                            : contributionsById.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('No contributions yet.', style: Theme.of(context).textTheme.titleLarge),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Column(
                                  spacing: 8,
                                  children: <Widget>[
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: contributionsById.length,
                                      itemBuilder: (BuildContext context, int idx) {
                                        final bool isFullyPaid = latestContributionsPerQuincena.fold<double>(0.0, (double sum, ContributionModel c) => sum + c.contributionAmount) == contributionsById[idx].contributionAmount;
                                        return Dismissible(
                                          key: ValueKey<String>(contributionsById[idx].id),
                                          confirmDismiss: (DismissDirection direction) async {
                                            if (idx != contributionsById.length - 1) {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Only the latest contribution can be deleted.', style: TextStyle(color: Colors.white)),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                              return false;
                                            }
                                            return await showConfirmDialog(
                                              context: context,
                                              title: 'Confirm Deletion',
                                              message: 'Are you sure you want to delete contribution for "${contributionsById[idx].memberName}"?',
                                              confirmText: 'Delete',
                                              cancelText: 'Cancel',
                                            );
                                          },
                                          onDismissed: (DismissDirection direction) async {
                                            setState(() => _isDeleteLoading = true);
                                            try {
                                              await ContributionsApiService().deleteContributionById(contributionsById[idx].id, contributionsById[idx].contributionAmount);
                                              if (context.mounted) {
                                                ref.read(contributionControllerProvider.notifier).deleteContribution(contributionsById[idx]);
                                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contribution of member "${contributionsById[idx].memberName}" was successfully deleted!')));
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
                                              setState(() => _isDeleteLoading = false);
                                            }
                                          },
                                          background: Container(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75), margin: Theme.of(context).cardTheme.margin),
                                          child: _isDeleteLoading
                                              ? const Center(child: CircularProgressIndicator())
                                              : Card(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  color: !isFullyPaid && contributionsById[idx].contributionDate == contributionsById.last.contributionDate ? Colors.red.shade800 : null,
                                                  child: ListTile(
                                                    title: Text('₱ ${contributionsById[idx].formattedContributionAmount}   ${contributionsById[idx].formattedContributionDate}', style: Theme.of(context).textTheme.titleMedium),
                                                    subtitle: Text('Paid: ${contributionsById[idx].formattedPaymentDateTime}', style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)),
                                                    trailing: contributionsById[idx].proof != null
                                                        ? InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) => Dialog(
                                                                  insetPadding: const EdgeInsets.all(16),
                                                                  child: InteractiveViewer(child: Image.memory(contributionsById[idx].proof!)),
                                                                ),
                                                              );
                                                            },
                                                            child: Image.memory(contributionsById[idx].proof!),
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.titleLarge,
                                        children: <InlineSpan>[
                                          const TextSpan(text: 'Total contribution: '),
                                          TextSpan(
                                            text: '₱ ${numberFormatter.format(totalContributionById)}',
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
