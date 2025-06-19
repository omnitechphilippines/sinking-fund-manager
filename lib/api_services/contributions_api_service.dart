import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/contribution_model.dart';

class ContributionsApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/contributions';

  /// Get all contributions
  Future<List<ContributionModel>> getContributions() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((dynamic json) => ContributionModel.fromJson(json)).toList();
    } else {
      throw Exception('Get Contributions API failed: ${response.body}');
    }
  }

  /// Add a new contribution
  Future<bool> addContribution(ContributionModel contribution, String? proofImageName) async {
    final Map<String, dynamic> body = contribution.toJson();
    body.remove('proof');
    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields.addAll(body.map((String k, dynamic v) => MapEntry<String, String>(k, v.toString())));
    if (contribution.proof != null && proofImageName != null) {
      final String? mimeType = lookupMimeType(proofImageName);
      if (mimeType != null) {
        request.files.add(http.MultipartFile.fromBytes('proof', contribution.proof as List<int>, filename: proofImageName, contentType: MediaType.parse(mimeType)));
      }
    }
    final http.StreamedResponse response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(await response.stream.bytesToString())['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Add Contribution failed: ${response.statusCode}');
    }
  }

  /// Get contribution by ID
  Future<ContributionModel> getContributionById(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/id/$id'));

    if (response.statusCode == 200) {
      return ContributionModel.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get Contribution by ID failed: ${response.body}');
    }
  }

  /// Get contributions by name
  Future<ContributionModel> getContributionsByName(String name) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/name/$name'));

    if (response.statusCode == 200) {
      return ContributionModel.fromJson(jsonDecode(response.body).first);
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
