import 'package:flutter/material.dart';

import '../../models/post.dart';

@immutable
abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class FetchUserPosts extends PostEvent {
  final String userId;

  FetchUserPosts({required this.userId});
}

class AddNewPost extends PostEvent {
  final Post post;

  AddNewPost(this.post);
}

class CreatePost extends PostEvent {
  final String content;
  final String? imageUrl;

  CreatePost({
    required this.content,
    this.imageUrl,
  });
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

class SearchPosts extends PostEvent {
  final String query;
  SearchPosts(this.query);
}

class UpdatePost extends PostEvent {
  final String postId;
  final String content;
  final String? imageUrl;

  UpdatePost({
    required this.postId,
    required this.content,
    this.imageUrl,
  });
}

class CreateComment extends PostEvent {
  final String content;
  final String parentId;
  final String? imageUrl;

  CreateComment(this.content, this.parentId, {this.imageUrl});
}

class FetchUserLikes extends PostEvent {
  final String userId;

  FetchUserLikes({required this.userId});
}

class LoadProfileData extends PostEvent {
  final String userId;
  final bool loadLikes;

  LoadProfileData({
    required this.userId,
    required this.loadLikes,
  });
}

class SyncLikeStatus extends PostEvent {
  final String postId;
  final bool isLiked;

  SyncLikeStatus(this.postId, this.isLiked);

  List<Object> get props => [postId, isLiked];
}