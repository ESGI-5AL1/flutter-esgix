part of 'auth_token_bloc.dart';

enum TokenStatus {
  unavailable,
  available,
}


@immutable
sealed class AuthTokenState {}

final class AuthTokenInitial extends AuthTokenState {}
