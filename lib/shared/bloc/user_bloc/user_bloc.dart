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
          },
        ),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        emit(UserLoaded(user));
      } else {
        emit(UserError('Failed to fetch user profile'));
      }
    } catch (error) {
      emit(UserError('Failed to fetch user profile: $error'));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event,
      Emitter<UserState> emit,
      ) async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? token = await LoginBloc.getToken();
    final String? userId = await LoginBloc.getUserId();

    if (userId == null) {
      emit(UserError('User ID not found'));
      return;
    }

    try {
      final response = await dio.put(
        'https://esgix.tech/users/$userId',
        data: {
          'username': event.username,
          'description': event.description,
          'avatar': event.avatar,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(response.data);
        emit(UserLoaded(updatedUser));
      } else {
        emit(UserError('Failed to update profile'));
      }
    } catch (error) {
      emit(UserError('Failed to update profile: $error'));
    }
  }
}