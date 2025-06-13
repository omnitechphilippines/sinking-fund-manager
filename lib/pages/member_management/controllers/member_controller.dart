// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// import '../models/member.dart';
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

import '../models/member.dart';
import 'members_api_service.dart';

enum MemberSortType {
  name,
  contribution,
  numberOfHeads,
}

enum SortDirection {
  ascending,
  descending,
}

class MemberController extends Notifier<List<Member>> {
  MemberSortType _sortType = MemberSortType.name;
  SortDirection _sortDirection = SortDirection.ascending;

  @override
  List<Member> build() => <Member>[];

  Future<void> init() async {
    final List<Member> members = await MembersApiService().getMembers();
    state = members;
  }

  void addMember(Member newMember) {
    state = <Member>[...state, newMember];
  }

  void deleteMember(Member memberToDelete) {
    state = state.where((Member m) => m.id != memberToDelete.id).toList();
  }

  // void sortMembers(MemberSortType sortType) {
  //   final List<Member> sortedList = <Member>[...state];
  //   switch (sortType) {
  //     case MemberSortType.name:
  //       sortedList.sort((Member a, Member b) => a.name.compareTo(b.name));
  //       break;
  //     case MemberSortType.contribution:
  //       sortedList.sort((Member a, Member b) => b.contributionAmount.compareTo(a.contributionAmount));
  //       break;
  //     case MemberSortType.numberOfHeads:
  //       sortedList.sort((Member a, Member b) => b.numberOfHeads.compareTo(a.numberOfHeads));
  //       break;
  //   }
  //   state = sortedList;
  // }

  void setSort(MemberSortType type, SortDirection direction) {
    _sortType = type;
    _sortDirection = direction;
    _sortMembers();
    state = <Member>[...state];
  }

  void _sortMembers() {
    state.sort((Member a, Member b) {
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

  List<Member> get members => state;
}

final NotifierProvider<MemberController, List<Member>> memberControllerProvider = NotifierProvider<MemberController, List<Member>>(() => MemberController());
