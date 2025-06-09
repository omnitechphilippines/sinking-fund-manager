import 'package:uuid/uuid.dart';

import '../../../utils/formatters.dart';

const Uuid uuid = Uuid();

class Member {
  final String id;
  final String name;
  final int numberOfHeads;
  final double contributionAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({required this.name, required this.numberOfHeads, required this.contributionAmount, required this.createdAt, required this.updatedAt}) : id = uuid.v4();

  String get formattedCreatedDate => dateFormatter.format(createdAt);
  String get formattedUpdatedDate => dateFormatter.format(updatedAt);
  String get formattedNumber => numberFormatter.format(contributionAmount);
}