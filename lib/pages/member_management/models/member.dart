import '../../../utils/formatters.dart';

class Member {
  final String id;
  final String name;
  final int numberOfHeads;
  final double contributionAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({required this.id, required this.name, required this.numberOfHeads, required this.contributionAmount, required this.createdAt, required this.updatedAt});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      numberOfHeads: int.parse(json['number_of_heads'].toString()),
      contributionAmount: double.parse(json['contribution_amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'number_of_heads': numberOfHeads, 'contribution_amount': contributionAmount, 'created_at': createdAt.toString(), 'updated_at': updatedAt.toString()};
  }

  String get formattedCreatedDate => dateFormatter.format(createdAt);

  String get formattedUpdatedDate => dateFormatter.format(updatedAt);

  String get formattedNumber => numberFormatter.format(contributionAmount);
}
