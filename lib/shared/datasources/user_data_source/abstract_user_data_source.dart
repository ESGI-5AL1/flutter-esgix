abstract class AbstractUserDataSource {
  Future<Map<String, dynamic>> fetchUserProfile(String userId);
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String username,
    required String description,
    required String avatar,
  });
}