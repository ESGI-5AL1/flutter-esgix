import 'author.dart';

class Post {
  final String id;
  final String content;
  final String imageUrl;
  final Author author;
  final int likesCount;
  final int commentsCount;
  final bool likedByUser;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'] ?? '',
      author: Author.fromJson(json['author']),
      likesCount: json['likesCount'],
      commentsCount: json['commentsCount'],
      likedByUser: json['likedByUser'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Post copyWith({
    String? id,
    String? content,
    String? imageUrl,
    Author? author,
    int? likesCount,
    int? commentsCount,
    bool? likedByUser,
    String? createdAt,
    String? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedByUser: likedByUser ?? this.likedByUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}