import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/login';

  Future<Map<String, dynamic>> login(String userName, String password) async {
    final http.Client client = http.Client();
    try {
      final http.Response response = await http.post(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(<String, String>{'userName': userName, 'password': password}));
      if (response.statusCode == 200) {
        return response.body != '[]' ? jsonDecode(response.body)[0] : <String, dynamic>{};
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } finally {
      client.close();
    }
  }
}

final Provider<AuthApiService> authApiServiceProvider = Provider<AuthApiService>((Ref ref) => AuthApiService());

// @riverpod
// AuthApiService authApiService(Ref ref) => AuthApiService();
