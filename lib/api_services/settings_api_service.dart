import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/setting_model.dart';

class SettingsApiService {
  static const String baseUrl = 'http://localhost:1880/api/v1/settings';

  /// Get setting
  Future<SettingModel?> getSetting() async {
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return SettingModel.fromJson(data[0]);
      } else {
        return null;
      }
    } else {
      throw Exception('Get Setting API failed: ${response.body}');
    }
  }

  /// Add a new setting
  Future<bool> addSetting(SettingModel setting) async {
    final http.Response response = await http.post(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(setting.toJson()));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Add Setting failed: ${response.body}');
    }
  }

  /// Update setting
  Future<bool> updateSetting(SettingModel setting) async {
    final http.Response response = await http.put(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(setting.toJson()));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['affectedRows'] == 1 ? true : false;
    } else {
      throw Exception('Update Setting failed: ${response.body}');
    }
  }

  /// Delete setting by ID
  Future<bool> deleteSettingById(int id) async {
    final http.Response response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Delete Setting failed: ${response.body}');
    }
  }
}
