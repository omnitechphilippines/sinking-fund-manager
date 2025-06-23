import '../../../utils/formatters.dart';

class LoanModel {
  final String id;
  final String name;
  final String? comaker;
  final double loanAmount;
  final DateTime loanDateTime;
  final int numberOfGives;
  final DateTime paymentStartDate;
  final double totalAmountToPay;
  final double payablePerGive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoanModel({
    required this.id,
    required this.name,
    this.comaker,
    required this.loanAmount,
    required this.loanDateTime,
    required this.numberOfGives,
    required this.paymentStartDate,
    required this.totalAmountToPay,
    required this.payablePerGive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      name: json['name'],
      comaker: json['comaker'],
      loanAmount: double.parse(json['loan_amount'].toString()),
      loanDateTime: DateTime.parse(json['loan_date_time']).toLocal(),
      numberOfGives: int.parse(json['number_of_gives'].toString()),
      paymentStartDate: DateTime.parse(json['payment_start_date']).toLocal(),
      totalAmountToPay: double.parse(json['total_amount_to_pay'].toString()),
      payablePerGive: double.parse(json['payable_per_give'].toString()),
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'comaker': comaker,
      'loan_amount': loanAmount,
      'loan_date_time': loanDateTime.toIso8601String(),
      'number_of_gives': numberOfGives,
      'payment_start_date': paymentStartDate.toIso8601String(),
      'total_amount_to_pay': totalAmountToPay,
      'payable_per_give': payablePerGive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedLoanAmount => numberFormatter.format(loanAmount);
  String get formattedTotalAmountToPay => numberFormatter.format(totalAmountToPay);
  String get formattedPayablePerGive => numberFormatter.format(payablePerGive);
  String get formattedRemainingPayable => numberFormatter.format(paymentStartDate);
}
