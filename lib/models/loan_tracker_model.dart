import 'dart:typed_data';

import '../../../utils/formatters.dart';

class LoanTrackerModel {
  final String id;
  final String loanId;
  final String loanName;
  final DateTime paymentDueDate;
  final int giveNumber;
  final int interestRate;
  final double giveAmount;
  final double remainingGiveAmount;
  final DateTime paymentDateTime;
  final Uint8List? proof;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoanTrackerModel({
    required this.id,
    required this.loanId,
    required this.loanName,
    required this.paymentDueDate,
    required this.giveNumber,
    required this.interestRate,
    required this.giveAmount,
    required this.remainingGiveAmount,
    required this.paymentDateTime,
    required this.proof,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanTrackerModel.fromJson(Map<String, dynamic> json) => LoanTrackerModel(
    id: json['id'],
    loanId: json['loan_id'],
    loanName: json['loan_name'],
    paymentDueDate: DateTime.parse(json['payment_due_date']).toLocal(),
    giveNumber: int.parse(json['give_number'].toString()),
    interestRate: int.parse(json['interest_rate'].toString()),
    giveAmount: double.parse(json['give_amount'].toString()),
    remainingGiveAmount: double.parse(json['remaining_give_amount'].toString()),
    paymentDateTime: DateTime.parse(json['payment_date_time']).toLocal(),
    proof: json['proof'] != null ? Uint8List.fromList(List<int>.from(json['proof']['data'])) : null,
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'loan_id': loanId,
    'loan_name': loanName,
    'payment_due_date': paymentDueDate.toIso8601String(),
    'give_number': giveNumber,
    'interest_rate': interestRate,
    'give_amount': giveAmount,
    'remaining_give_amount': remainingGiveAmount,
    'payment_date_time': paymentDateTime.toIso8601String(),
    'proof': proof,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  LoanTrackerModel copyWith({
    String? id,
    String? loanId,
    String? loanName,
    DateTime? paymentDueDate,
    int? giveNumber,
    int? interestRate,
    double? giveAmount,
    double? remainingGiveAmount,
    DateTime? paymentDateTime,
    Uint8List? proof,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LoanTrackerModel(
    id: id ?? this.id,
    loanId: loanId ?? this.loanId,
    loanName: loanName ?? this.loanName,
    paymentDueDate: paymentDueDate ?? this.paymentDueDate,
    giveNumber: giveNumber ?? this.giveNumber,
    interestRate: interestRate ?? this.interestRate,
    giveAmount: giveAmount ?? this.giveAmount,
    remainingGiveAmount: remainingGiveAmount ?? this.remainingGiveAmount,
    paymentDateTime: paymentDateTime ?? this.paymentDateTime,
    proof: proof ?? this.proof,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedGiveAmount => numberFormatter.format(giveAmount);

  String get formattedRemainingGiveAmount => numberFormatter.format(remainingGiveAmount);

  String get formattedPaymentDueDate => dateFormatter.format(paymentDueDate);

  String get formattedPaymentDateTime => dateTimeFormatter.format(paymentDateTime);
}
