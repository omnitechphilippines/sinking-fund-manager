import 'package:hive_flutter/hive_flutter.dart';

bool isUserLoggedIn() {
  final Box<dynamic> box = Hive.box('auth');
  final String? token = box.get('token');

  return token != null;
}