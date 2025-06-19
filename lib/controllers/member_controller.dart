// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// import '../models/member_model.dart';
// import 'members_api_service.dart';
//
// part 'member_controller.g.dart';
//
// @Riverpod(keepAlive: true)
// class MemberController extends _$MemberController {
//   @override
//   List<Member> build() => <Member>[];
//
//   Future<void> init() async {
//     final List<Member> members = await MembersApiService().getMembers();
//     state = members;
//   }
//
//   void addMember(Member newMember) {
//     state = <Member>[...state, newMember];
//   }
//
//   void deleteMember(Member memberToDelete) {
//     state = state.where((Member m) => m.id != memberToDelete.id).toList();
//   }
//
//   List<Member> get members => state;
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_model.dart';
import '../api_services/members_api_service.dart';

enum MemberSortType { name, contribution, numberOfHeads }

enum SortDirection { ascending, descending }

class MemberController extends Notifier<List<MemberModel>> {
  MemberSortType _sortType = MemberSortType.name;
  SortDirection _sortDirection = SortDirection.ascending;

  @override
  List<MemberModel> build() => <MemberModel>[];

  Future<void> init() async {
    final List<MemberModel> members = await MembersApiService().getMembers();
    state = members;
  }

  List<MemberModel> get members => state;

  void addMember(MemberModel newMember) {
    state = <MemberModel>[...state, newMember];
  }

  void deleteMember(MemberModel memberToDelete) {
    state = state.where((MemberModel m) => m.id != memberToDelete.id).toList();
  }

  void setSort(MemberSortType type, SortDirection direction) {
    _sortType = type;
    _sortDirection = direction;
    _sortMembers();
    state = <MemberModel>[...state];
  }

  void _sortMembers() {
    state.sort((MemberModel a, MemberModel b) {
      int compare;

      switch (_sortType) {
        case MemberSortType.name:
          compare = a.name.compareTo(b.name);
          break;
        case MemberSortType.contribution:
          compare = a.contributionAmount.compareTo(b.contributionAmount);
          break;
        case MemberSortType.numberOfHeads:
          compare = a.numberOfHeads.compareTo(b.numberOfHeads);
          break;
      }

      return _sortDirection == SortDirection.ascending ? compare : -compare;
    });
  }
}

final NotifierProvider<MemberController, List<MemberModel>> memberControllerProvider = NotifierProvider<MemberController, List<MemberModel>>(() => MemberController());
