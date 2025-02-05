import 'package:flutter/material.dart';

import '../../models/post.dart';

@immutable
abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class AddNewPost extends PostEvent {
  final Post post;

  AddNewPost(this.post);
}

class CreatePost extends PostEvent {
  final String content;

  CreatePost(this.content);
}

class DeletePost extends PostEvent {
  final String postId;

  DeletePost(this.postId);
}

class LikePost extends PostEvent {
  final String postId;
  LikePost(this.postId);
}

class UpdateLikeStatus extends PostEvent {
  final String postId;
  final bool isLiked;
  final int likesCount;
  UpdateLikeStatus(this.postId, this.isLiked, this.likesCount);
}

class FetchComments extends PostEvent {
  final String postId;

  FetchComments({required this.postId});
}

class FetchPostById extends PostEvent {
  final String postId;

  FetchPostById({required this.postId});
}

class FetchUserPosts extends PostEvent {
  final String userId;
  FetchUserPosts(this.userId);
}

class EditPost extends PostEvent {
  final String postId;
  final String content;
  final String imageUrl;
  final bool isProfileScreen;

  EditPost({
    required this.postId,
    required this.content,
    required this.imageUrl,
    required this.isProfileScreen,
  });
}