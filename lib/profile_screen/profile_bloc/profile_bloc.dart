// profile_bloc.dart
import 'package:bloc/bloc.dart';
import '../../shared/repositories/posts_repository/posts_repository.dart';
import './profile_event.dart';
import './profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final PostRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileData>((event, emit) async {
      emit(ProfileLoading());
      try {
        final posts = event.loadLikes
            ? await repository.getUserLikes(event.userId)
            : await repository.getUserPosts(event.userId);
        emit(ProfileLoaded(posts));
      } catch (error) {
        emit(ProfileError(error.toString()));
      }
    });

    on<FetchUserPosts>((event, emit) async {
      emit(ProfileLoading());
      try {
        final posts = await repository.getUserPosts(event.userId);
        emit(ProfileLoaded(posts));
      } catch (error) {
        emit(ProfileError(error.toString()));
      }
    });

    on<FetchUserLikes>((event, emit) async {
      emit(ProfileLoading());
      try {
        final posts = await repository.getUserLikes(event.userId);
        emit(ProfileLoaded(posts));
      } catch (error) {
        emit(ProfileError(error.toString()));
      }
    });
  }
}