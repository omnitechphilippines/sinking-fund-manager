import 'dart:convert';
import 'dart:typed_data';

import '../../../utils/formatters.dart';

class Contribution {
  final String id;
  final String name;
  final double contributionAmount;
  final DateTime paymentDateTime;
  final Uint8List? proof;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contribution({required this.id, required this.name, required this.contributionAmount, required this.paymentDateTime, this.proof, required this.createdAt, required this.updatedAt});

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      name: json['name'],
      contributionAmount: double.parse(json['contribution_amount'].toString()),
      paymentDateTime: DateTime.parse(json['payment_date_time']),
      proof: json['proof'] != null ? base64Decode(json['proof']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'contribution_amount': contributionAmount,
      'payment_date_time': paymentDateTime.toString(),
      'proof': proof != null ? base64Encode(proof!) : null,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }

  Contribution copyWith({String? id, String? name, double? contributionAmount, DateTime? paymentDateTime, Uint8List? proof, DateTime? createdAt, DateTime? updatedAt}) => Contribution(
    id: id ?? this.id,
    name: name ?? this.name,
    contributionAmount: contributionAmount ?? this.contributionAmount,
    paymentDateTime: paymentDateTime ?? this.paymentDateTime,
    proof: proof ?? this.proof,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedCreatedDate => dateFormatter.format(createdAt);

  String get formattedUpdatedDate => dateFormatter.format(updatedAt);

  String get formattedNumber => numberFormatter.format(contributionAmount);
}
