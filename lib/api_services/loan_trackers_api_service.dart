import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/loan_tracker_model.dart';

class LoanTrackersApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/loan-trackers';

  /// Get all loan trackers
  Future<List<LoanTrackerModel>> getLoanTrackers() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((dynamic json) => LoanTrackerModel.fromJson(json)).toList();
    } else {
      throw Exception('Get Loan Trackers API failed: ${response.body}');
    }
  }

  /// Add a new loan tracker
  Future<bool> addLoanTracker(LoanTrackerModel loanTracker, String? proofImageName) async {
    final Map<String, dynamic> body = loanTracker.toJson();
    body.remove('proof');
    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields.addAll(body.map((String k, dynamic v) => MapEntry<String, String>(k, v.toString())));
    if (loanTracker.proof != null && proofImageName != null) {
      final String? mimeType = lookupMimeType(proofImageName);
      if (mimeType != null) {
        request.files.add(http.MultipartFile.fromBytes('proof', loanTracker.proof as List<int>, filename: proofImageName, contentType: MediaType.parse(mimeType)));
      }
    }
    final http.StreamedResponse response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(await response.stream.bytesToString())['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Add Loan Tracker failed: ${response.statusCode}');
    }
  }

  /// Get loan tracker by ID
  Future<LoanTrackerModel> getLoanTrackerById(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return LoanTrackerModel.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get Loan Tracker by ID failed: ${response.body}');
    }
  }

  /// Delete loan tracker by ID
  Future<void> deleteLoanById(String id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete Loan Tracker failed: ${response.body}');
    }
  }
}
