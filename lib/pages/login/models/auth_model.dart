enum AuthStatus { initial, loading, success, failure }

class AuthModel {
  final AuthStatus status;
  final String? token;
  final String? error;
  final String? userName;
  final String? user;

  const AuthModel({this.status = AuthStatus.initial, this.token, this.error, this.userName, this.user});

  AuthModel copyWith({AuthStatus? status, String? token, String? error, final String? userName, final String? user}) {
    return AuthModel(status: status ?? this.status, token: token ?? this.token, error: error ?? this.error, userName: userName ?? this.userName, user: user ?? this.user);
  }
}
