part of 'auth_token_bloc.dart';

@immutable
sealed class AuthTokenEvent {
  const AuthTokenEvent();
}

class GetAuthToken extends AuthTokenEvent {
  const GetAuthToken();
}

class SetAuthToken extends AuthTokenEvent {
  const SetAuthToken();
}
