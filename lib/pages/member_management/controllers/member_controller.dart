import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/member.dart';

part 'member_controller.g.dart';

@Riverpod(keepAlive: true)
class MemberController extends _$MemberController {
  @override
  List<Member> build() => <Member>[];

  void addMember(Member newMember) {
    state = <Member>[...state, newMember];
  }

  void deleteMember(Member memberToDelete) {
    state = state.where((Member m) => m.id != memberToDelete.id).toList();
  }

  List<Member> get members => state;
}
