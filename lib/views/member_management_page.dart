import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund_manager/controllers/contribution_controller.dart';
import 'package:sinking_fund_manager/models/setting_model.dart';
import 'package:sinking_fund_manager/models/summary_model.dart';

import '../../../../components/footer.dart';
import '../../../../components/side_nav.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../components/confirm_dialog.dart';
import '../../../components/member_dialog.dart';
import '../controllers/member_controller.dart';
import '../api_services/members_api_service.dart';
import '../controllers/setting_controller.dart';
import '../controllers/summary_controller.dart';
import '../models/contribution_model.dart';
import '../models/member_model.dart';
import '../../../views/member_item.dart';
import '../utils/formatters.dart';

class MemberManagementPage extends ConsumerStatefulWidget {
  const MemberManagementPage({super.key});

  @override
  ConsumerState<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends ConsumerState<MemberManagementPage> {
  bool _isLoading = true;
  MemberSortType _selectedSortType = MemberSortType.name;
  MemberSortDirection _selectedSortDirection = MemberSortDirection.ascending;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) async {
      try {
        ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
        if (ref.read(settingControllerProvider) == null && mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Need to setup settings first!', style: TextStyle(color: Colors.white)),
            ),
          );
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
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addMember() async {
    final List<dynamic>? result = await showDialog(barrierDismissible: false, context: context, builder: (BuildContext _) => const MemberDialog(member: null));

    if (result != null && result.isNotEmpty) {
      final MemberModel newMember = result.first;
      ref.read(memberControllerProvider.notifier).addMember(newMember);
      ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Member "${newMember.name}" was successfully added!', style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  Widget _buildLargeScreenHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Members List', style: Theme.of(context).textTheme.titleLarge),
        Row(
          children: <Widget>[
            Text('Sort by: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<MemberSortType>(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              value: _selectedSortType,
              onChanged: (MemberSortType? sortType) {
                if (sortType != null) {
                  setState(() => _selectedSortType = sortType);
                  ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: MemberSortType.values.map((MemberSortType type) {
                final String label = switch (type) {
                  MemberSortType.name => 'Name',
                  MemberSortType.numberOfHeads => 'Number of Heads',
                };
                return DropdownMenuItem<MemberSortType>(value: type, child: Text(label));
              }).toList(),
            ),
            const SizedBox(width: 16),
            Text('Direction: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<MemberSortDirection>(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              value: _selectedSortDirection,
              onChanged: (MemberSortDirection? value) {
                if (value != null) {
                  setState(() => _selectedSortDirection = value);
                  ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: MemberSortDirection.values.map((MemberSortDirection dir) {
                final String label = switch (dir) {
                  MemberSortDirection.ascending => 'Ascending',
                  MemberSortDirection.descending => 'Descending',
                };
                return DropdownMenuItem<MemberSortDirection>(value: dir, child: Text(label));
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Sort by: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<MemberSortType>(
              value: _selectedSortType,
              onChanged: (MemberSortType? sortType) {
                if (sortType != null) {
                  setState(() => _selectedSortType = sortType);
                  ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: MemberSortType.values.map((MemberSortType type) {
                final String label = switch (type) {
                  MemberSortType.name => 'Name',
                  MemberSortType.numberOfHeads => 'Number of Heads',
                };
                return DropdownMenuItem<MemberSortType>(
                  value: type,
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(label)),
                );
              }).toList(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Direction: ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            DropdownButton<MemberSortDirection>(
              value: _selectedSortDirection,
              onChanged: (MemberSortDirection? value) {
                if (value != null) {
                  setState(() => _selectedSortDirection = value);
                  ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              items: MemberSortDirection.values.map((MemberSortDirection dir) {
                final String label = switch (dir) {
                  MemberSortDirection.ascending => 'Ascending',
                  MemberSortDirection.descending => 'Descending',
                };
                return DropdownMenuItem<MemberSortDirection>(
                  value: dir,
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(label)),
                );
              }).toList(),
            ),
          ],
        ),
        Text('Members List', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MemberModel> members = ref.watch(memberControllerProvider);
    final SettingModel? setting = ref.watch(settingControllerProvider);
    final SummaryModel? summary = ref.watch(summaryControllerProvider);
    final List<ContributionModel> contributions = ref.watch(contributionControllerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Member',
        onPressed: setting != null ? _addMember : null,
        backgroundColor: setting != null ? null : Colors.grey.shade700,
        child: Icon(Icons.add, color: setting != null ? null : Colors.white),
      ),
      appBar: const CustomAppBar(title: 'Member Management'),
      drawer: SideNav(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? Center(child: Text('No members found.', style: Theme.of(context).textTheme.titleLarge))
          : LayoutBuilder(
              builder: (BuildContext _, BoxConstraints constraints) {
                final bool isSmallScreen = constraints.maxWidth < 600;
                return Column(
                  spacing: 8,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: isSmallScreen ? _buildSmallScreenHeader() : _buildLargeScreenHeader()),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        interactive: true,
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: Column(
                                spacing: 8,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                      spacing: 32,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total contribution: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(summary?.totalContribution)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleLarge,
                                            children: <InlineSpan>[
                                              const TextSpan(text: 'Total Cash On-hand: '),
                                              TextSpan(
                                                text: '₱ ${numberFormatter.format(summary?.totalCashOnHand)}',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: members.length,
                                    itemBuilder: (BuildContext ctx, int idx) => Dismissible(
                                      key: ValueKey<String>(members[idx].id),
                                      confirmDismiss: (DismissDirection direction) async {
                                        if (contributions.where((ContributionModel c) => c.memberId == members[idx].id).isNotEmpty) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Only members without contributions can be deleted.', style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return false;
                                        }
                                        return await showConfirmDialog(context: context, title: 'Confirm Deletion', message: 'Are you sure you want to delete "${members[idx].name}"?', confirmText: 'Delete', cancelText: 'Cancel');
                                      },
                                      onDismissed: (DismissDirection direction) async {
                                        setState(() => _isLoading = true);
                                        try {
                                          await MembersApiService().deleteMemberById(members[idx].id);
                                          if (context.mounted) {
                                            ref.read(memberControllerProvider.notifier).deleteMember(members[idx]);
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${members[idx].name}" was successfully deleted!')));
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
                                      background: Container(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75), margin: Theme.of(context).cardTheme.margin),
                                      child: MemberItem(member: members[idx]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Footer(),
                  ],
                );
              },
            ),
    );
  }
}
