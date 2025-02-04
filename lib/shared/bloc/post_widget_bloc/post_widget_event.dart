
import 'package:flutter/material.dart';

@immutable
abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class FetchComments extends PostEvent {
  final String postId;

  FetchComments({required this.postId});
}

class FetchPostById extends PostEvent {
  final String postId;

  FetchPostById({required this.postId});
}

class LikePost extends PostEvent {
  final String postId;

  LikePost({required this.postId});
}

class DislikePost extends PostEvent {
  final String postId;

  DislikePost({required this.postId});
}