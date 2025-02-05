import 'package:bloc/bloc.dart';

import '../../../login_screen/login_bloc/login_bloc.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event,
      Emitter<UserState> emit,
      ) async {
    emit(UserLoading());
    try {
      final user = await userRepository.fetchUserProfile(event.userId);
      emit(UserLoaded(user));
    } catch (error) {
      emit(UserError('Failed to fetch user profile: $error'));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event,
      Emitter<UserState> emit,
      ) async {
    try {
      final userId = await LoginBloc.getUserId();
      if (userId == null) {
        emit(UserError('User ID not found'));
        return;
      }

      final updatedUser = await userRepository.updateUserProfile(
        userId: userId,
        username: event.username,
        description: event.description,
        avatar: event.avatar,
      );
      emit(UserLoaded(updatedUser));
    } catch (error) {
      emit(UserError('Failed to update profile: $error'));
    }
  }
}