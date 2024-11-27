part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}
