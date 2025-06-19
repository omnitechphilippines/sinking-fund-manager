import '../utils/formatters.dart';

enum ContributionPeriod { quincena, monthly }

class SettingModel {
  final int id;
  final double amountPerHead;
  final ContributionPeriod contributionPeriod;
  final DateTime startingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SettingModel({required this.id, required this.amountPerHead, required this.contributionPeriod, required this.startingDate, required this.createdAt, required this.updatedAt});

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      id: int.parse(json['id'].toString()),
      amountPerHead: double.parse(json['amount_per_head'].toString()),
      contributionPeriod: _parseContributionPeriod(json['contribution_period']),
      startingDate: DateTime.parse(json['starting_date']).toLocal(),
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'amount_per_head': amountPerHead,
      'contribution_period': _contributionPeriodToString(contributionPeriod),
      'starting_date': startingDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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

  String get formattedAmountPerHead => numberFormatter.format(amountPerHead);
}
