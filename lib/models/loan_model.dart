import '../../../utils/formatters.dart';

class LoanModel {
  final String id;
  final String name;
  final String? comaker;
  final double loanAmount;
  final DateTime loanDateTime;
  final int numberOfGives;
  final DateTime paymentStartDate;
  final double payablePerGive;
  final double totalAmountToPay;
  final int currentGiveNumber;
  final int currentGiveInterest;
  final double currentGiveAmount;
  final double currentTotalAmountToPay;
  final double currentRemainingAmountToPay;
  final DateTime currentPaymentDueDate;
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
    required this.payablePerGive,
    required this.totalAmountToPay,
    required this.currentGiveNumber,
    required this.currentGiveInterest,
    required this.currentGiveAmount,
    required this.currentTotalAmountToPay,
    required this.currentRemainingAmountToPay,
    required this.currentPaymentDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
    id: json['id'],
    name: json['name'],
    comaker: json['comaker'],
    loanAmount: double.parse(json['loan_amount'].toString()),
    loanDateTime: DateTime.parse(json['loan_date_time']).toLocal(),
    numberOfGives: int.parse(json['number_of_gives'].toString()),
    paymentStartDate: DateTime.parse(json['payment_start_date']).toLocal(),
    payablePerGive: double.parse(json['payable_per_give'].toString()),
    totalAmountToPay: double.parse(json['total_amount_to_pay'].toString()),
    currentGiveNumber: int.parse(json['current_give_number'].toString()),
    currentGiveInterest: int.parse(json['current_give_interest'].toString()),
    currentGiveAmount: double.parse(json['current_give_amount'].toString()),
    currentTotalAmountToPay: double.parse(json['current_total_amount_to_pay'].toString()),
    currentRemainingAmountToPay: double.parse(json['current_remaining_amount_to_pay'].toString()),
    currentPaymentDueDate: DateTime.parse(json['current_payment_due_date']).toLocal(),
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'comaker': comaker,
    'loan_amount': loanAmount,
    'loan_date_time': loanDateTime.toIso8601String(),
    'number_of_gives': numberOfGives,
    'payment_start_date': paymentStartDate.toIso8601String(),
    'payable_per_give': payablePerGive,
    'total_amount_to_pay': totalAmountToPay,
    'current_give_number': currentGiveNumber,
    'current_give_interest': currentGiveInterest,
    'current_give_amount': currentGiveAmount,
    'current_total_amount_to_pay': currentTotalAmountToPay,
    'current_remaining_amount_to_pay': currentRemainingAmountToPay,
    'current_payment_due_date': currentPaymentDueDate.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  LoanModel copyWith({
    String? id,
    String? name,
    String? comaker,
    double? loanAmount,
    DateTime? loanDateTime,
    int? numberOfGives,
    DateTime? paymentStartDate,
    double? payablePerGive,
    double? totalAmountToPay,
    int? currentGiveNumber,
    int? currentGiveInterest,
    double? currentGiveAmount,
    double? currentTotalAmountToPay,
    double? currentRemainingAmountToPay,
    DateTime? currentPaymentDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LoanModel(
    id: id ?? this.id,
    name: name ?? this.name,
    comaker: comaker ?? this.comaker,
    loanAmount: loanAmount ?? this.loanAmount,
    loanDateTime: loanDateTime ?? this.loanDateTime,
    numberOfGives: numberOfGives ?? this.numberOfGives,
    paymentStartDate: paymentStartDate ?? this.paymentStartDate,
    payablePerGive: payablePerGive ?? this.payablePerGive,
    totalAmountToPay: totalAmountToPay ?? this.totalAmountToPay,
    currentGiveNumber: currentGiveNumber ?? this.currentGiveNumber,
    currentGiveInterest: currentGiveInterest ?? this.currentGiveInterest,
    currentGiveAmount: currentGiveAmount ?? this.currentGiveAmount,
    currentTotalAmountToPay: currentTotalAmountToPay ?? this.currentTotalAmountToPay,
    currentRemainingAmountToPay: currentRemainingAmountToPay ?? this.currentRemainingAmountToPay,
    currentPaymentDueDate: currentPaymentDueDate ?? this.currentPaymentDueDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedLoanAmount => numberFormatter.format(loanAmount);

  String get formattedPayablePerGive => numberFormatter.format(payablePerGive);

  String get formattedTotalAmountToPay => numberFormatter.format(totalAmountToPay);

  String get formattedCurrentGiveAmount => numberFormatter.format(currentGiveAmount);

  String get formattedCurrentTotalAmountToPay => numberFormatter.format(currentTotalAmountToPay);

  String get formattedCurrentRemainingAmountToPay => numberFormatter.format(currentRemainingAmountToPay);

  String get formattedLoanDateTime => dateTimeFormatter.format(loanDateTime);

  String get formattedPaymentStartDate => dateFormatter.format(paymentStartDate);

  String get formattedCurrentPaymentDueDate => dateFormatter.format(currentPaymentDueDate);
}
