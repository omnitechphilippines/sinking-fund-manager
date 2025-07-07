import '../../../utils/formatters.dart';

class MemberModel {
  final String id;
  final String name;
  final int numberOfHeads;
  final double contributionAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemberModel({required this.id, required this.name, required this.numberOfHeads, required this.contributionAmount, required this.isActive, required this.createdAt, required this.updatedAt});

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
    id: json['id'],
    name: json['name'],
    numberOfHeads: int.parse(json['number_of_heads'].toString()),
    contributionAmount: double.parse(json['contribution_amount'].toString()),
    isActive: json['is_active'] == 1 ? true : false,
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'number_of_heads': numberOfHeads,
    'contribution_amount': contributionAmount,
    'is_active': isActive == true ? '1' : '0',
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  MemberModel copyWith({String? id, String? name, int? numberOfHeads, double? contributionAmount, bool? isActive, DateTime? createdAt, DateTime? updatedAt}) => MemberModel(
    id: id ?? this.id,
    name: name ?? this.name,
    numberOfHeads: numberOfHeads ?? this.numberOfHeads,
    contributionAmount: contributionAmount ?? this.contributionAmount,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedContributionAmount => numberFormatter.format(contributionAmount);
}
