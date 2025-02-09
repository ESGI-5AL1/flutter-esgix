import '../../datasources/user_data_source/user_remote_data_source.dart';
import '../../models/user.dart';

class UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepository({required this.remoteDataSource});

  Future<User> getUserProfile(String userId) async {
    try {
      return await remoteDataSource.getUserProfile(userId);
    } catch (e) {
      throw Exception('Repository: Failed to fetch user profile: $e');
    }
  }

  Future<User> updateUserProfile(
      String userId, Map<String, String> updateData) async {
    try {
      return await remoteDataSource.updateUserProfile(userId, updateData);
    } catch (e) {
      throw Exception('Repository: Failed to update user profile: $e');
    }
  }
}
