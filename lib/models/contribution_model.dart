import 'dart:typed_data';

import '../utils/formatters.dart';

class ContributionModel {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime contributionDate;
  final double contributionAmount;
  final DateTime paymentDateTime;
  final Uint8List? proof;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContributionModel({required this.id, required this.memberId, required this.memberName, required this.contributionDate, required this.contributionAmount, required this.paymentDateTime, this.proof, required this.createdAt, required this.updatedAt});

  factory ContributionModel.fromJson(Map<String, dynamic> json) => ContributionModel(
    id: json['id'],
    memberId: json['member_id'],
    memberName: json['member_name'],
    contributionDate: DateTime.parse(json['contribution_date']).toLocal(),
    contributionAmount: double.parse(json['contribution_amount'].toString()),
    paymentDateTime: DateTime.parse(json['payment_date_time']).toLocal(),
    proof: json['proof'] != null ? Uint8List.fromList(List<int>.from(json['proof']['data'])) : null,
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'member_id': memberId,
    'contribution_date': contributionDate.toIso8601String(),
    'contribution_amount': contributionAmount,
    'payment_date_time': paymentDateTime.toIso8601String(),
    'proof': proof,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  ContributionModel copyWith({String? id, String? memberId, String? memberName, DateTime? contributionDate, double? contributionAmount, DateTime? paymentDateTime, Uint8List? proof, DateTime? createdAt, DateTime? updatedAt}) => ContributionModel(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    contributionDate: contributionDate ?? this.contributionDate,
    contributionAmount: contributionAmount ?? this.contributionAmount,
    paymentDateTime: paymentDateTime ?? this.paymentDateTime,
    proof: proof ?? this.proof,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedContributionAmount => numberFormatter.format(contributionAmount);

  String get formattedContributionDate => dateFormatter.format(contributionDate);

  String get formattedPaymentDateTime => dateTimeFormatter.format(paymentDateTime);
}
