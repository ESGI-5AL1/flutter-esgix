part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {
  const LoginEvent();
}

class ExecuteLogin extends LoginEvent {
  final String email;
  final String password;

  const ExecuteLogin(this.email, this.password);
}
