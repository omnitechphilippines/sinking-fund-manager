import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../api_services/auth_api_service.dart';
import '../models/auth_model.dart';

class AuthController extends Notifier<AuthModel> {
  @override
  AuthModel build() => const AuthModel(status: AuthStatus.initial);

  Future<void> login(String userName, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final AuthApiService authApi = ref.read(authApiServiceProvider);
      final Map<String, dynamic> response = await authApi.login(userName, password);
      if(response.isNotEmpty){
        final Box<dynamic> box = Hive.box('auth');
        await box.put('status', 'success');
        await box.put('userName', response['user_name']);
        await box.put('user', '${response['first_name']} ${response['last_name']}');
        state = state.copyWith(status: AuthStatus.success, token: response['status'], userName: response['user_name'], user: '${response['first_name']} ${response['last_name']}');
      }
      else if(response.isEmpty){
        state = state.copyWith(status: AuthStatus.failure, error:null);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, error: e.toString());
    }
  }
}

final NotifierProvider<AuthController, AuthModel> authControllerProvider = NotifierProvider<AuthController, AuthModel>(() => AuthController());
