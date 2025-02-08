import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../login_screen/login_bloc/login_bloc.dart';
import '../../models/user.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Dio dio;

  UserBloc({required this.dio}) : super(UserInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final String? apiKey = dotenv.env['API_KEY'];
    final String? token = await LoginBloc.getToken();

    try {
      final response = await dio.get(
        'https://esgix.tech/users/${event.userId}',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Debug print to see response structure
        print('User profile response: ${response.data}');

        // Handle both possible response formats
        final userData = response.data is Map
            ? (response.data['data'] ?? response.data)
            : response.data;

        if (userData != null) {
          final user = User.fromJson(userData);
          emit(UserLoaded(user));
        } else {
          emit(UserError('Invalid response format'));
        }
      } else {
        emit(UserError('Failed to fetch user profile'));
      }
    } catch (error) {
      print('Error fetching user profile: $error');
      emit(UserError('Failed to fetch user profile: $error'));
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

    final String? apiKey = dotenv.env['API_KEY'];
    final String? token = await LoginBloc.getToken();
    final String? userId = await LoginBloc.getUserId();

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

      print('Update profile request payload: $updateData');

      final response = await dio.put(
        'https://esgix.tech/users/$userId',
        data: updateData,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Update profile response: ${response.data}');

      if (response.statusCode == 200) {
        final userData = response.data is Map
            ? (response.data['data'] ?? response.data)
            : response.data;

        if (userData != null) {
          final updatedUser = User.fromJson(userData);
          emit(UserLoaded(updatedUser));
        } else {
          emit(UserError('Invalid response format'));
        }
      } else {
        String errorMessage = 'Failed to update profile';

        if (response.data is Map && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }

        if (response.statusCode == 400 &&
            errorMessage.contains('Username already used')) {
          errorMessage =
              'This username is already taken. Please choose another one.';
        }

        emit(UserError(errorMessage));
      }
    } on DioException catch (error) {
      print('DioException during profile update: $error');
      String errorMessage = 'Failed to update profile';

      if (error.response?.data is Map &&
          error.response?.data['message'] != null) {
        errorMessage = error.response?.data['message'];

        if (error.response?.statusCode == 400 &&
            errorMessage.contains('Username already used')) {
          errorMessage =
              'This username is already taken. Please choose another one.';
        }
      }

      emit(UserError(errorMessage));
    } catch (error) {
      print('Unexpected error during profile update: $error');
      emit(UserError('An unexpected error occurred: $error'));
    }
  }
}
