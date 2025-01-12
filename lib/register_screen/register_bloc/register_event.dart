part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {
  const RegisterEvent();
}

class ExecuteRegister extends RegisterEvent {
  final String email;
  final String password;
  final String username;
  final String avatar;

  const ExecuteRegister(
    this.email,
    this.password,
    this.username,
    this.avatar,
  );
}
