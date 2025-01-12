import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:esgix/shared/models/auth_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';

import '../../shared/models/user.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<ExecuteRegister>((event, emit) async {
      try {
        final authResult = await _register(
          event.email,
          event.password,
          event.username,
          event.avatar,
        );

        final user = authResult.user;
        final token = authResult.token;
        print("[TOKEN] : $token");

        emit(state.copyWith(
          user: user,
          status: RegisterStatus.success,
        ));
      } catch (error) {
        print("[ERROR] : $error");
        emit(state.copyWith(
          status: RegisterStatus.error,
        ));
      }
    });
  }
}

Future<AuthResult> _register(
  String email,
  String password,
  String username,
  String avatar,
) async {
  final String? token = dotenv.env['API_KEY'];

  if (token == null) {
    throw Exception('API_KEY not loaded from .env');
  }

  try {
    final response = await Dio().post(
      options: Options(headers: {
        'x-api-key': token,
        'Content-Type': 'application/json',
      }),
      "https://esgix.tech/auth/register",
      data: {
        'email': email,
        'password': password,
        'username': username,
        'avatar': avatar,
      },
    );

    print('Response: ${response.data}');

    final data = response.data;

    if (data == null || data is! Map<String, dynamic>) {
      print('Invalid or missing response data: $data');
      return const AuthResult(
        user: User(
          username: "",
          description: "",
          id: "0",
          email: "",
          avatar: "",
        ),
        token: "",
      );
    }

    final userInfo = data['record'];
    final authToken = data['token'];

    if (userInfo == null || userInfo is! Map<String, dynamic>) {
      print("The user's information is invalid or missing: $userInfo");
      return const AuthResult(
        user: User(
          username: "",
          description: "",
          id: "0",
          email: "",
          avatar: "",
        ),
        token: "",
      );
    }

    final user = User.fromJson(userInfo);

    print('User: ${user.username}, ${user.email}');
    print('Token: $authToken');

    return AuthResult(user: user, token: authToken);
  } catch (e) {
    if (e is DioException) {
      print('Dio: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('[ERROR]: $e');
    }
    throw e;
  }
}
