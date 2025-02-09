abstract class ProfileEvent {}

class LoadProfileData extends ProfileEvent {
  final String userId;
  final bool loadLikes;

  LoadProfileData({
    required this.userId,
    required this.loadLikes,
  });
}

class FetchUserPosts extends ProfileEvent {
  final String userId;
  FetchUserPosts({required this.userId});
}

class FetchUserLikes extends ProfileEvent {
  final String userId;
  FetchUserLikes({required this.userId});
}