class Post {
  final String id;
  final String content;
  final String imageUrl;
  final String parent;
  final int likes;

  const Post({
    required this.id,
    required this.content,
    required this.imageUrl,
    required this.parent,
    required this.likes,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      likes: json['likes'],
      imageUrl: json['imageUrl'],
      parent: json['parent'],
    );
  }
}
