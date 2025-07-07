import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/member_model.dart';

class MembersApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/members';

  /// Get all members
  Future<List<MemberModel>> getMembers() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((dynamic json) => MemberModel.fromJson(json)).toList();
    } else {
      throw Exception('Get members failed: ${response.body}');
    }
  }

  /// Add a new member
  Future<bool> addMember(MemberModel member) async {
    final http.Response response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(member.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Add member failed: ${response.body}');
    }
  }

  /// Get member by ID
  Future<MemberModel> getMemberById(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return MemberModel.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get member by ID failed: ${response.body}');
    }
  }

  /// Delete member by name
  Future<void> deleteMemberById(String id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete member failed: ${response.body}');
    }
  }
}
