part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class SetUser extends UserEvent {
  final User user;

  SetUser({required this.user});
}

class ClearUser extends UserEvent {}