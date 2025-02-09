import '../../models/user.dart';

abstract class UserDataSource {
  Future<User> getUserProfile(String userId);
  Future<User> updateUserProfile(String userId, Map<String, String> updateData);
}