import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/components/member_dialog.dart';

import '../components/confirm_dialog.dart';
import '../components/contribution_dialog.dart';
import '../controllers/member_controller.dart';
import '../api_services/members_api_service.dart';
import '../controllers/setting_controller.dart';
import '../models/member_model.dart';
import '../models/setting_model.dart';
import '../controllers/contribution_controller.dart';
import '../models/contribution_model.dart';
import '../utils/formatters.dart';

class MemberItem extends ConsumerStatefulWidget {
  final MemberModel member;

  const MemberItem({super.key, required this.member});

  @override
  ConsumerState<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends ConsumerState<MemberItem> {
  bool _isLoading = false;
  late DateTime _contributionDate;
  double _maximumAmountToPay = 0;
  String _hintText = '';
  List<ContributionModel> _contributionsById = <ContributionModel>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SettingModel? setting = ref.watch(settingControllerProvider);
    final List<ContributionModel> allContributions = ref.watch(contributionControllerProvider);
    _contributionsById = allContributions.where((ContributionModel c) => c.memberId == widget.member.id).toList();
    _contributionsById.sort((ContributionModel a, ContributionModel b) => b.contributionDate.compareTo(a.contributionDate));
    if (_contributionsById.isNotEmpty) {
      _contributionDate = _contributionsById[0].contributionDate;
      final int lastDayOfMonth = DateTime(_contributionDate.year, _contributionDate.month + 1, 0).day;
      final bool is15 = _contributionDate.day == 15;
      final List<ContributionModel> contributionsByIdAndDate = _contributionsById.where((ContributionModel c) => c.contributionDate == _contributionDate).toList();
      final double totalContributionByDate = contributionsByIdAndDate.fold<double>(0.0, (double sum, ContributionModel contribution) => sum + contribution.contributionAmount);
      if (totalContributionByDate == widget.member.contributionAmount) {
        _contributionDate = is15 ? DateTime(_contributionDate.year, _contributionDate.month, lastDayOfMonth) : DateTime(_contributionDate.year, _contributionDate.month + 1, 15);
        _hintText = 'not yet paid';
        _maximumAmountToPay = totalContributionByDate;
      } else {
        _hintText = 'paid ₱${numberFormatter.format(totalContributionByDate)}';
        _maximumAmountToPay = widget.member.contributionAmount - totalContributionByDate;
      }
    } else {
      _contributionDate = ref.read(settingControllerProvider)!.startingDate;
      _hintText = 'not yet paid';
      _maximumAmountToPay = widget.member.contributionAmount;
    }
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 5,
            shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : Colors.black,
            child: InkWell(
              onTap: () async => await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext _) => MemberDialog(member: widget.member),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.member.name, style: Theme.of(context).textTheme.titleLarge),
                        Text('₱ ${widget.member.formattedContributionAmount} (${widget.member.numberOfHeads})', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Due Date: ', style: Theme.of(context).textTheme.titleLarge),
                        Text(dateFormatter.format(_contributionDate), style: TextStyle(color: DateTime.now().difference(_contributionDate).inDays > 0 ? Colors.red : Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      spacing: 4,
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Add Contribution',
                          onPressed: setting != null
                              ? () async {
                                  final List<dynamic>? result = await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext _) => ContributionDialog(
                                      id: widget.member.id,
                                      name: widget.member.name,
                                      contributionAmount: widget.member.contributionAmount,
                                      contributionDate: _contributionDate,
                                      maximumAmountToPay: _maximumAmountToPay,
                                      hintText: _hintText,
                                    ),
                                  );
                                  if (result != null && result.isNotEmpty) {
                                    final ContributionModel newContribution = result.first;
                                    ref.read(contributionControllerProvider.notifier).addContribution(newContribution);
                                    if (context.mounted) {
                                      final String dateTime = newContribution.formattedPaymentDateTime;
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text('Contribution for member "${newContribution.memberName}" on $dateTime was successfully added!', style: const TextStyle(color: Colors.white)),
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          icon: Icon(Icons.add_circle_sharp, color: setting != null ? null : Colors.grey.shade600),
                        ),
                        _contributionsById.isEmpty ? IconButton(
                          tooltip: 'Delete Member',
                          onPressed: () async {
                            final bool shouldDelete = await showConfirmDialog(context: context, title: 'Confirm Deletion', message: 'Are you sure you want to delete "${widget.member.name}"?', confirmText: 'Delete', cancelText: 'Cancel');
                            setState(() => _isLoading = true);
                            try {
                              if (shouldDelete) {
                                await MembersApiService().deleteMemberById(widget.member.id);
                                if (context.mounted) {
                                  ref.read(memberControllerProvider.notifier).deleteMember(widget.member);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${widget.member.name}" was successfully deleted!')));
                                }
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
                              setState(() => _isLoading = false);
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ) : IconButton(
                          tooltip: 'Disable Member',
                          onPressed: () async {
                            final bool shouldDelete = await showConfirmDialog(context: context, title: 'Confirm Deactivation', message: 'Are you sure you want to disable "${widget.member.name}"?', confirmText: 'Disable', cancelText: 'Cancel');
                            setState(() => _isLoading = true);
                            try {
                              if (shouldDelete) {
                                await MembersApiService().deleteMemberById(widget.member.id);
                                if (context.mounted) {
                                  ref.read(memberControllerProvider.notifier).deleteMember(widget.member);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${widget.member.name}" was successfully disabled!')));
                                }
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
                              setState(() => _isLoading = false);
                            }
                          },
                          icon: const Icon(Icons.do_disturb_alt_outlined , color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
