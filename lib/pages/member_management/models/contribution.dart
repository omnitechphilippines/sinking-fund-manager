import '../../../utils/formatters.dart';

class Contribution {
  final String id;
  final String name;
  final double amount;
  final DateTime paymentDateTime;
  final List<int>? proof;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contribution({required this.id, required this.name, required this.amount, required this.paymentDateTime, this.proof, required this.createdAt, required this.updatedAt});

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      name: json['name'],
      amount: double.parse(json['number_of_heads'].toString()),
      paymentDateTime: DateTime.parse(json['payment_date_time']),
      proof: json['proof'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'amount': amount, 'payment_date_time': paymentDateTime.toString(), 'proof': proof, 'created_at': createdAt.toString(), 'updated_at': updatedAt.toString()};
  }

  Contribution copyWith({String? id, String? name, double? amount, DateTime? paymentDateTime, List<int>? proof, DateTime? createdAt, DateTime? updatedAt}) => Contribution(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    paymentDateTime: paymentDateTime ?? this.paymentDateTime,
    proof: proof ?? this.proof,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedCreatedDate => dateFormatter.format(createdAt);

  String get formattedUpdatedDate => dateFormatter.format(updatedAt);

  String get formattedNumber => numberFormatter.format(amount);
}
