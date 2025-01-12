import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadComments extends CommentEvent {
  final String postId;

  LoadComments(this.postId);

  @override
  List<Object> get props => [postId];
}

class AddComment extends CommentEvent {
  final String postId;
  final String content;

  AddComment(this.postId, this.content);

  @override
  List<Object> get props => [postId, content];
}
