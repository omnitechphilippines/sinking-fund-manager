import '../utils/formatters.dart';

enum ContributionPeriod { quincena, monthly }

class SettingModel {
  final int id;
  final double amountPerHead;
  final ContributionPeriod contributionPeriod;
  final int maxNumberOfGives;
  final DateTime startingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SettingModel({required this.id, required this.amountPerHead, required this.contributionPeriod, required this.maxNumberOfGives, required this.startingDate, required this.createdAt, required this.updatedAt});

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
    id: int.parse(json['id'].toString()),
    amountPerHead: double.parse(json['amount_per_head'].toString()),
    contributionPeriod: _parseContributionPeriod(json['contribution_period']),
    maxNumberOfGives: int.parse(json['max_number_of_gives'].toString()),
    startingDate: DateTime.parse(json['starting_date']).toLocal(),
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'amount_per_head': amountPerHead,
    'contribution_period': _contributionPeriodToString(contributionPeriod),
    'max_number_of_gives': maxNumberOfGives,
    'starting_date': startingDate.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static ContributionPeriod _parseContributionPeriod(String value) {
    switch (value) {
      case 'quincena':
        return ContributionPeriod.quincena;
      case 'monthly':
        return ContributionPeriod.monthly;
      default:
        throw ArgumentError('Unknown contribution period: $value');
    }
  }

  static String _contributionPeriodToString(ContributionPeriod period) {
    switch (period) {
      case ContributionPeriod.quincena:
        return 'quincena';
      case ContributionPeriod.monthly:
        return 'monthly';
    }
  }

  SettingModel copyWith({int? id, double? amountPerHead, ContributionPeriod? contributionPeriod, int? maxNumberOfGives, DateTime? startingDate, DateTime? createdAt, DateTime? updatedAt}) => SettingModel(
    id: id ?? this.id,
    amountPerHead: amountPerHead ?? this.amountPerHead,
    contributionPeriod: contributionPeriod ?? this.contributionPeriod,
    maxNumberOfGives: maxNumberOfGives ?? this.maxNumberOfGives,
    startingDate: startingDate ?? this.startingDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get formattedAmountPerHead => numberFormatter.format(amountPerHead);

  String get formattedStartingDate => dateFormatter.format(startingDate);
}
