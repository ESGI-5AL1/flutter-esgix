import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';

import '../../shared/models/user.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<ExecuteLogin>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        _login(email, password);
      } catch (error) {
        print("[ERROR] : $error");
      }
    });
  }
}


void _login(String email, String password) async {
  final String? token = dotenv.env['API_KEY'];

  try {
    final response = await Dio().post(
      options: Options(
        headers: {
          'x-api-key': token,
          'Content-Type': 'application/json',
        }
      ),
      "https://esgix.tech/auth/login",
      data: {'email': email, 'password': password},
    );

    print('Response: ${response.data}');

    final data = response.data;

    if (data == null || data is! Map<String, dynamic>) {
      print('Invalid or mmissing response data: $data');
      return;
    }

    final userInfo = data['record'];
    final authToken = data['token'];

    if (userInfo == null || userInfo is! Map<String, dynamic>) {
      print("The user's information is invalid or missing: $userInfo");
      return;
    }

    final user = User.fromJson(userInfo);

    print('User: ${user.username}, ${user.email}');
    print('Token: $authToken');

  } catch (e) {
    if (e is DioException) {
      print('Dio: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('[ERROR]: $e');
    }
  }
}
