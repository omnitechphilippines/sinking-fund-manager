import '../utils/formatters.dart';

class SummaryModel {
  final int id;
  final double totalContribution;
  final double totalLoan;
  final double totalUnpaidLoan;
  final double totalPaidLoan;
  final double totalCashOnHand;
  final double totalInterestAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SummaryModel({
    required this.id,
    required this.totalContribution,
    required this.totalLoan,
    required this.totalUnpaidLoan,
    required this.totalPaidLoan,
    required this.totalCashOnHand,
    required this.totalInterestAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
    id: int.parse(json['id'].toString()),
    totalContribution: double.parse(json['total_contribution'].toString()),
    totalLoan: double.parse(json['total_loan'].toString()),
    totalUnpaidLoan: double.parse(json['total_unpaid_loan'].toString()),
    totalPaidLoan: double.parse(json['total_paid_loan'].toString()),
    totalCashOnHand: double.parse(json['total_cash_on_hand'].toString()),
    totalInterestAmount: double.parse(json['total_interest_amount'].toString()),
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'total_contribution': totalContribution,
    'total_loan': totalLoan,
    'total_unpaid_loan': totalUnpaidLoan,
    'total_paid_loan': totalPaidLoan,
    'total_cash_on_hand': totalCashOnHand,
    'total_interest_amount': totalInterestAmount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  SummaryModel copyWith({int? id, double? totalContribution, double? totalLoan, double? totalUnpaidLoan, double? totalPaidLoan, double? totalCashOnHand, double? totalInterestAmount, DateTime? createdAt, DateTime? updatedAt}) => SummaryModel(
    id: id ?? this.id,
    totalContribution: totalContribution ?? this.totalContribution,
    totalLoan: totalLoan ?? this.totalLoan,
    totalUnpaidLoan: totalUnpaidLoan ?? this.totalUnpaidLoan,
    totalPaidLoan: totalPaidLoan ?? this.totalPaidLoan,
    totalCashOnHand: totalCashOnHand ?? this.totalCashOnHand,
    totalInterestAmount: totalInterestAmount ?? this.totalInterestAmount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedTotalContribution => numberFormatter.format(totalContribution);

  String get formattedTotalLoan => numberFormatter.format(totalLoan);

  String get formattedTotalUnpaidLoan => numberFormatter.format(totalUnpaidLoan);

  String get formattedTotalPaidLoan => numberFormatter.format(totalPaidLoan);

  String get formattedTotalCashOnHand => numberFormatter.format(totalCashOnHand);

  String get formattedTotalInterestAmount0 => numberFormatter.format(totalInterestAmount);
}
