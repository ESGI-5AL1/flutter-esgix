import 'package:dio/dio.dart';
import 'package:esgix/shared/constants/constants.dart';

import '../../../login_screen/login_bloc/login_bloc.dart';
import 'abstract_user_data_source.dart';

class UserDataSource implements AbstractUserDataSource {
  final Dio dio;
  final String? apiKey = ApiConstants.apiKey;
  final String? apiBaseUrl = ApiConstants.apiBaseUrl;

  UserDataSource({required this.dio});

  @override
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {

    final response = await dio.get(
      'https://esgix.tech/users/$userId',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String username,
    required String description,
    required String avatar,
  }) async {
    final String? token = await LoginBloc.getToken();

    final response = await dio.put(
      'https://esgix.tech/users/$userId',
      data: {
        'username': username,
        'description': description,
        'avatar': avatar,
      },
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}