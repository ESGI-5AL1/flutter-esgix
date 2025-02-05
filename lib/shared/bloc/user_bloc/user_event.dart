part of 'user_bloc.dart';

abstract class UserEvent {}

class FetchUserProfile extends UserEvent {
  final String userId;
  FetchUserProfile(this.userId);
}

class UpdateUserProfile extends UserEvent {
  final String username;
  final String description;
  final String avatar;

  UpdateUserProfile({
    required this.username,
    required this.description,
    required this.avatar,
  });
}

