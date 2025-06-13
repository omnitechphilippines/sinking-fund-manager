import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/contribution.dart';

class ContributionsApiService {
  static const String baseUrl = 'http://localhost:1880/contributions';

  /// Get all contributions
  Future<List<Contribution>> getContributions() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((dynamic json) => Contribution.fromJson(json)).toList();
    } else {
      throw Exception('Contributions API failed: ${response.body}');
    }
  }

  /// Add a new contribution
  Future<String> addContribution(Contribution contribution) async {
    final http.Response response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(contribution.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? 'success' : 'failed';
    } else {
      throw Exception('Add Contribution failed: ${response.body}');
    }
  }

  /// Get contribution by ID
  Future<Contribution> getContributionById(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/id/$id'));

    if (response.statusCode == 200) {
      return Contribution.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get Contribution by ID failed: ${response.body}');
    }
  }

  /// Get contributions by name
  Future<Contribution> getContributionsByName(String name) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/name/$name'));

    if (response.statusCode == 200) {
      return Contribution.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get Contribution by Name failed: ${response.body}');
    }
  }

  /// Delete contribution by ID
  Future<void> deleteContributionById(String id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete Contribution failed: ${response.body}');
    }
  }
}
