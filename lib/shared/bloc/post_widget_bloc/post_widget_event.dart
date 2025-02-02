
import 'package:flutter/material.dart';

@immutable
abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class FetchComments extends PostEvent {
  final String postId;

  FetchComments({required this.postId});
}