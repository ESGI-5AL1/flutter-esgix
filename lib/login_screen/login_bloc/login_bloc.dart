import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  final Dio dio;

  LoginBloc({Dio? dio}) :
        dio = dio ?? Dio(),
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    final String? apiKey = dotenv.env['API_KEY'];

    try {
      final response = await dio.post(
        'https://esgix.tech/auth/login',
        data: {
          'email': event.email,
          'password': event.password,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userId = response.data['record']['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userIdKey, userId);

        emit(LoginSuccess(token: token));
      } else {
        emit(LoginFailure('Login failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(LoginFailure(e.response?.data['message'] ?? 'Login failed'));
      } else {
        emit(LoginFailure('Network error: ${e.message}'));
      }
    } catch (error) {
      emit(LoginFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<LoginState> emit,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      emit(LoginInitial());
    } catch (error) {
      emit(LoginFailure('Failed to logout'));
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.containsKey(_tokenKey);
    final hasUserId = prefs.containsKey(_userIdKey);
    return hasToken && hasUserId;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}