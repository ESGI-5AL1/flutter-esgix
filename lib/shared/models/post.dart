import 'author.dart';  // Import the Author model
import 'package:flutter/material.dart';

class Post {
  final String id;
  final String content;
  final String imageUrl;
  final String parent;
  final int likes;
  final int commentsCount;
  final Author author;  // Author object (or User if you prefer)
  final String createdAt;
  final String updatedAt;

  const Post({
    required this.id,
    required this.content,
    required this.imageUrl,
    required this.parent,
    required this.likes,
    required this.commentsCount,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      parent: json['parent'] ?? '',
      likes: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      author: Author.fromJson(json['author']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
