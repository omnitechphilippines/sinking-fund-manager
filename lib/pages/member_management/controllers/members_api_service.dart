import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/member.dart';

class MembersApiService {
  static const String baseUrl = 'http://localhost:1880/members';

  /// Get all members
  Future<List<Member>> getMembers() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((dynamic json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Members API failed: ${response.body}');
    }
  }

  /// Add a new member
  Future<String> addMember(Member member) async {
    final http.Response response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(member.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? 'success' : 'failed';
    } else {
      throw Exception('Add Member failed: ${response.body}');
    }
  }

  /// Get member by ID
  Future<Member> getMemberById(String id) async {
    final http.Response response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Member.fromJson(jsonDecode(response.body).first);
    } else {
      throw Exception('Get Member by ID failed: ${response.body}');
    }
  }

  /// Delete member by ID
  Future<void> deleteMemberById(String id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete Member failed: ${response.body}');
    }
  }
}
