import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../components/footer.dart';
import '../../../../components/side_nav.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../components/member_dialog.dart';
import '../controllers/member_controller.dart';
import '../models/member.dart';
import 'member_item.dart';

class MemberManagementPage extends ConsumerStatefulWidget {
  const MemberManagementPage({super.key});

  @override
  ConsumerState<MemberManagementPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<MemberManagementPage> {

  void _addOrEditMember(Member? member) async {
    final List<dynamic>? result = await showDialog(barrierDismissible: false, context: context, builder: (BuildContext _) => MemberDialog(member: member));

    if (result != null && result.isNotEmpty) {
      final Member newOrUpdatedMember = result.first;
      if(member==null){
        ref.read(memberControllerProvider.notifier).addMember(newOrUpdatedMember);
      }
      else{
        ref.read(memberControllerProvider.notifier).deleteMember(member);
        ref.read(memberControllerProvider.notifier).addMember(newOrUpdatedMember);
      }
      if(mounted){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Member "${newOrUpdatedMember.name}" was successfully ${member==null? 'added!':'edited!'}', style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Member> members = ref.watch(memberControllerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => _addOrEditMember(null), child: const Icon(Icons.add)),
      appBar: const CustomAppBar(title: 'Member Management'),
      drawer: SideNav(currentRoute: GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()),
      body: Column(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (BuildContext ctx, int idx) => Dismissible(
                key: ValueKey<String>(members[idx].id),
                onDismissed: (DismissDirection direction) {
                  ref.read(memberControllerProvider.notifier).deleteMember(members[idx]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Member "${members[idx].name}" was successfully deleted!'),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(label: 'Undo', onPressed: () => ref.read(memberControllerProvider.notifier).addMember(members[idx])),
                    ),
                  );
                },
                background: Container(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75), margin: Theme.of(context).cardTheme.margin),
                child: MemberItem(member: members[idx], onTap: () => _addOrEditMember(members[idx])),
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
