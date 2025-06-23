import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_model.dart';
import '../api_services/members_api_service.dart';

enum MemberSortType { name, numberOfHeads }

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
        case MemberSortType.numberOfHeads:
          compare = a.numberOfHeads.compareTo(b.numberOfHeads);
          break;
      }
      return _sortDirection == SortDirection.ascending ? compare : -compare;
    });
  }
}

final NotifierProvider<MemberController, List<MemberModel>> memberControllerProvider = NotifierProvider<MemberController, List<MemberModel>>(() => MemberController());
