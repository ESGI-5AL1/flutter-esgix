import 'package:equatable/equatable.dart';


import '../../shared/models/post.dart';

abstract class CommentState extends Equatable {
  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Post> comments;

  CommentLoaded(this.comments);

  @override
  List<Object> get props => [comments];
}

class CommentError extends CommentState {
  final String message;

  CommentError(this.message);

  @override
  List<Object> get props => [message];
}
