import 'package:dio/dio.dart';
import 'package:esgix/shared/datasources/user_data_source/user_data_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../login_screen/login_bloc/login_bloc.dart';
import '../../models/user.dart';

class UserRemoteDataSource implements UserDataSource {
  final Dio dio;
  final String baseUrl = 'https://esgix.tech';

  UserRemoteDataSource({required this.dio});

  Future<Map<String, String>> _getHeaders() async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? token = await LoginBloc.getToken();

    return {
      'x-api-key': apiKey ?? '',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<User> getUserProfile(String userId) async {
    try {
      final response = await dio.get(
        '$baseUrl/users/$userId',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        final userData = response.data is Map
            ? (response.data['data'] ?? response.data)
            : response.data;

        if (userData != null) {
          return User.fromJson(userData);
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to fetch user profile');
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<User> updateUserProfile(String userId, Map<String, String> updateData) async {
    try {
      final response = await dio.put(
        '$baseUrl/users/$userId',
        data: updateData,
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        final userData = response.data is Map
            ? (response.data['data'] ?? response.data)
            : response.data;

        if (userData != null) {
          return User.fromJson(userData);
        }
        throw Exception('Invalid response format');
      }

      String errorMessage = 'Failed to update profile';
      if (response.data is Map && response.data['message'] != null) {
        errorMessage = response.data['message'];
      }

      if (response.statusCode == 400 && errorMessage.contains('Username already used')) {
        throw Exception('This username is already taken. Please choose another one.');
      }

      throw Exception(errorMessage);
    } on DioException catch (error) {
      String errorMessage = 'Failed to update profile';

      if (error.response?.data is Map && error.response?.data['message'] != null) {
        errorMessage = error.response?.data['message'];
        if (error.response?.statusCode == 400 && errorMessage.contains('Username already used')) {
          throw Exception('This username is already taken. Please choose another one.');
        }
      }

      throw Exception(errorMessage);
    }
  }
}