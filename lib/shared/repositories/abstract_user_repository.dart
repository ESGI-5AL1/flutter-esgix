import '../models/user.dart';

abstract class AbstractUserRepository {
  Future<User> fetchUserProfile(String userId);
  Future<User> updateUserProfile({
    required String userId,
    required String username,
    required String description,
    required String avatar,
  });
}