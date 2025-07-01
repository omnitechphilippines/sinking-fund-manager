import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund_manager/components/member_dialog.dart';
import 'package:sinking_fund_manager/controllers/summary_controller.dart';

import '../components/confirm_dialog.dart';
import '../components/contribution_dialog.dart';
import '../controllers/member_controller.dart';
import '../api_services/members_api_service.dart';
import '../controllers/setting_controller.dart';
import '../models/member_model.dart';
import '../models/setting_model.dart';
import '../controllers/contribution_controller.dart';
import '../models/contribution_model.dart';
import '../models/summary_model.dart';

class MemberItem extends ConsumerStatefulWidget {
  final MemberModel member;

  const MemberItem({super.key, required this.member});

  @override
  ConsumerState<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends ConsumerState<MemberItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final SettingModel? setting = ref.watch(settingControllerProvider);
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
                    // RichText(
                    //   text: TextSpan(
                    //     style: Theme.of(context).textTheme.titleLarge,
                    //     children: const <InlineSpan>[TextSpan(text: 'Due Date: ')],
                    //   ),
                    // ),
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
                                    builder: (BuildContext _) => ContributionDialog(id: widget.member.id, name: widget.member.name, contributionAmount: widget.member.contributionAmount),
                                  );
                                  if (result != null && result.isNotEmpty) {
                                    final ContributionModel newContribution = result.first;
                                    ref.read(contributionControllerProvider.notifier).addContribution(newContribution);
                                    ref.read(summaryControllerProvider.notifier).editSummary(totalContribution: result[1],totalCashOnHand: result[2]);
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
                        IconButton(
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
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${widget.member.name}" was successfully deleted!'), duration: const Duration(seconds: 5)));
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
