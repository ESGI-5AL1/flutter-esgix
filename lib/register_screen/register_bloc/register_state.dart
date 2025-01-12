part of 'register_bloc.dart';

enum RegisterStatus {
  initial,
  loading,
  success,
  error,
}

class RegisterState {
  final RegisterStatus status;
  final User user;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.user = const User(
      username: "username",
      description: "description",
      id: "id",
      email: "email",
      avatar: "avatar",
    ),
  });

  RegisterState copyWith({
    RegisterStatus? status,
    User? user,
  }) {
    return RegisterState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}
