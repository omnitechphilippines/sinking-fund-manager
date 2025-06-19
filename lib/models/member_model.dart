import '../../../utils/formatters.dart';

class MemberModel {
  final String id;
  final String name;
  final int numberOfHeads;
  final double contributionAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemberModel({required this.id, required this.name, required this.numberOfHeads, required this.contributionAmount, required this.createdAt, required this.updatedAt});

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
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

  String get formattedContributionAmount => numberFormatter.format(contributionAmount);
}
