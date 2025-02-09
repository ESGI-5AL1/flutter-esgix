import 'package:bloc/bloc.dart';

import '../../../login_screen/login_bloc/login_bloc.dart';
import '../../models/user.dart';
import '../../repositories/user_repository/user_repository.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(UserInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.getUserProfile(event.userId);
      emit(UserLoaded(user));
    } catch (error) {
      print('Error fetching user profile: $error');
      emit(UserError(error.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) {
      emit(UserError('Current user state not loaded'));
      return;
    }

    final currentState = state as UserLoaded;
    final currentUser = currentState.user;
    emit(UserLoading());

    final userId = await LoginBloc.getUserId();
    if (userId == null) {
      emit(UserError('User ID not found'));
      return;
    }

    try {
      final Map<String, String> updateData = {};

      if (event.username.trim() != currentUser.username) {
        updateData['username'] = event.username.trim();
      }
      if (event.description.trim() != currentUser.description) {
        updateData['description'] = event.description.trim();
      }
      if (event.avatar.trim() != currentUser.avatar) {
        updateData['avatar'] = event.avatar.trim();
      }

      if (updateData.isEmpty) {
        emit(UserLoaded(currentUser));
        return;
      }

      final updatedUser =
          await repository.updateUserProfile(userId, updateData);
      emit(UserLoaded(updatedUser));
    } catch (error) {
      print('Error updating user profile: $error');
      emit(UserError(error.toString()));
    }
  }
}
