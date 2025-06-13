import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund_manager/pages/member_management/controllers/contribution_controller.dart';
import 'package:sinking_fund_manager/pages/member_management/controllers/contributions_api_service.dart';

import '../../../../components/footer.dart';
import '../../../../components/side_nav.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../components/confirm_dialog.dart';
import '../../../components/member_dialog.dart';
import '../controllers/member_controller.dart';
import '../controllers/members_api_service.dart';
import '../models/contribution.dart';
import '../models/member.dart';
import 'member_item.dart';

class MemberManagementPage extends ConsumerStatefulWidget {
  const MemberManagementPage({super.key});

  @override
  ConsumerState<MemberManagementPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<MemberManagementPage> {
  bool _isLoading = true;
  MemberSortType _selectedSortType = MemberSortType.name;
  SortDirection _selectedSortDirection = SortDirection.ascending;
  Uint8List? _proofImageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) async {
      try {
        await ref.read(memberControllerProvider.notifier).init();
        ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
        final Contribution contribution = await ContributionsApiService().getContributionById('362da31c-6f82-45fa-bf3f-fba8c4846aff');
        _proofImageBytes = contribution.proof;
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

  void _addMember() async {
    final List<dynamic>? result = await showDialog(barrierDismissible: false, context: context, builder: (BuildContext _) => const MemberDialog(member: null));

    if (result != null && result.isNotEmpty) {
      final Member newMember = result.first;
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

  @override
  Widget build(BuildContext context) {
    final List<Member> members = ref.watch(memberControllerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _addMember, child: const Icon(Icons.add)),
      appBar: const CustomAppBar(title: 'Member Management'),
      drawer: SideNav(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(child: Text('No data found.'))
          : LayoutBuilder(
              builder: (BuildContext _, BoxConstraints constraints) {
                final bool isSmallScreen = constraints.maxWidth < 600;
                return Column(
                  spacing: 8,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () async{
                      await showDialog(context: context, builder: (BuildContext _) {
                        return Dialog(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                              child: Image.memory(_proofImageBytes!, fit: BoxFit.contain),
                            ),
                          ),
                        );
                      });
                    }, child: const Text('test')),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: !isSmallScreen
                          ? Row(
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
                                          MemberSortType.contribution => 'Contribution',
                                          MemberSortType.numberOfHeads => 'Number of Heads',
                                        };
                                        return DropdownMenuItem<MemberSortType>(value: type, child: Text(label));
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 16),
                                    Text('Direction: ', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(width: 8),
                                    DropdownButton<SortDirection>(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      value: _selectedSortDirection,
                                      onChanged: (SortDirection? value) {
                                        if (value != null) {
                                          setState(() => _selectedSortDirection = value);
                                          ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                                          FocusScope.of(context).requestFocus(FocusNode());
                                        }
                                      },
                                      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                                      items: SortDirection.values.map((SortDirection dir) {
                                        final String label = switch (dir) {
                                          SortDirection.ascending => 'Ascending',
                                          SortDirection.descending => 'Descending',
                                        };
                                        return DropdownMenuItem<SortDirection>(value: dir, child: Text(label));
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
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
                                          MemberSortType.contribution => 'Contribution',
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
                                    DropdownButton<SortDirection>(
                                      value: _selectedSortDirection,
                                      onChanged: (SortDirection? value) {
                                        if (value != null) {
                                          setState(() => _selectedSortDirection = value);
                                          ref.read(memberControllerProvider.notifier).setSort(_selectedSortType, _selectedSortDirection);
                                          FocusScope.of(context).requestFocus(FocusNode());
                                        }
                                      },
                                      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                                      items: SortDirection.values.map((SortDirection dir) {
                                        final String label = switch (dir) {
                                          SortDirection.ascending => 'Ascending',
                                          SortDirection.descending => 'Descending',
                                        };
                                        return DropdownMenuItem<SortDirection>(
                                          value: dir,
                                          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(label)),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text('Members List', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (BuildContext ctx, int idx) => Dismissible(
                          key: ValueKey<String>(members[idx].id),
                          confirmDismiss: (DismissDirection direction) async {
                            return await showConfirmDialog(context: context, title: 'Confirm Deletion', message: 'Are you sure you want to delete "${members[idx].name}"?', confirmText: 'Delete', cancelText: 'Cancel');
                          },
                          onDismissed: (DismissDirection direction) async {
                            setState(() => _isLoading = true);
                            try {
                              await MembersApiService().deleteMemberById(members[idx].id);
                              if (context.mounted) {
                                ref.read(memberControllerProvider.notifier).deleteMember(members[idx]);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${members[idx].name}" was successfully deleted!'), duration: const Duration(seconds: 5)));
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
                    ),
                    const Footer(),
                  ],
                );
              },
            ),
    );
  }
}
