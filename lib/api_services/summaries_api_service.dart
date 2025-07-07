import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/summary_model.dart';

class SummariesApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/summaries';

  /// Get summary
  Future<SummaryModel?> getSummary() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return SummaryModel.fromJson(data[0]);
      } else {
        return null;
      }
    } else {
      throw Exception('Get summary failed: ${response.body}');
    }
  }

  /// Add a new summary
  Future<bool> addSummary(SummaryModel summary) async {
    final http.Response response = await http.post(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(summary.toJson()));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Add summary failed: ${response.body}');
    }
  }

  /// Update summary
  Future<bool> updateSummary(SummaryModel summary) async {
    final http.Response response = await http.put(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(summary.toJson()));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Update summary failed: ${response.body}');
    }
  }

  /// Delete summary by ID
  Future<bool> deleteSummaryById(int id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Delete summary failed: ${response.body}');
    }
  }
}
