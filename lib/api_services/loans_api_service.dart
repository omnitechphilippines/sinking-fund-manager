import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/loan_model.dart';

class LoansApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/loans';

  /// Get all loans
  Future<List<LoanModel>> getLoans() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((dynamic json) => LoanModel.fromJson(json)).toList();
    } else {
      throw Exception('Get loans failed: ${response.body}');
    }
  }

  /// Add a new loan
  Future<bool> addLoan(LoanModel loan) async {
    final http.Response response = await http.post(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(loan.toJson()));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 2 ? true : false;
    } else {
      throw Exception('Add loan failed: ${response.body}');
    }
  }

  /// Update a loan
  Future<bool> updateLoan(LoanModel loan, double interestAmount) async {
    final Map<String, dynamic> body = loan.toJson();
    body['interest_amount'] = interestAmount;
    final http.Response response = await http.put(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 2 ? true : false;
    } else {
      throw Exception('Update loan failed: ${response.body}');
    }
  }

  /// Get loan by ID
  Future<LoanModel> getLoanById(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return LoanModel.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get loan by ID failed: ${response.body}');
    }
  }

  /// Delete loan by ID
  Future<void> deleteLoanById(String id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete loan failed: ${response.body}');
    }
  }
}
