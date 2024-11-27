part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

class LoginState {
  final LoginStatus status;
  final User user;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user = const User(username: "username", description: "description", id: "id", email: "email", avatar: "avatar"),
  });

  LoginState copyWith({
    LoginStatus? status,
    User? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}
