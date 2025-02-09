import '../../shared/models/post.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<Post> posts;
  ProfileLoaded(this.posts);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}