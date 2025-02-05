import '../datasources/user_data_source/user_data_source.dart';
import '../models/user.dart';
import 'abstract_user_repository.dart';

class UserRepository implements AbstractUserRepository {
  final UserDataSource dataSource;

  UserRepository({required this.dataSource});

  @override
  Future<User> fetchUserProfile(String userId) async {
    try {
      final userData = await dataSource.fetchUserProfile(userId);
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<User> updateUserProfile({
    required String userId,
    required String username,
    required String description,
    required String avatar,
  }) async {
    try {
      final userData = await dataSource.updateUserProfile(
        userId: userId,
        username: username,
        description: description,
        avatar: avatar,
      );
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}