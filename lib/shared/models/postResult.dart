class PostResult {
  final String id;
  final String content;
  final String imageUrl;
  final String parent;
  final int likes;
  final int commentsCount;
  final String authorUsername;
  final String authorAvatar;

  const PostResult({
    required this.id,
    required this.content,
    required this.imageUrl,
    required this.parent,
    required this.likes,
    required this.commentsCount,
    required this.authorUsername,
    required this.authorAvatar,
  });

  factory PostResult.fromJson(Map<String, dynamic> json) {
    return PostResult(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'] ?? '',
      parent: json['parent'] ?? '',
      likes: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      authorUsername: json['author']['username'],
      authorAvatar: json['author']['avatar'] ?? '',
    );
  }
}
