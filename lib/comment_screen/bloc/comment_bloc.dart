import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_event.dart';
import 'comment_state.dart';
import '../comment_repository.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc(this.commentRepository) : super(CommentInitial()) {
    on<LoadComments>((event, emit) async {
      emit(CommentLoading());
      try {
        final comments = await commentRepository.fetchComments(event.postId);
        emit(CommentLoaded(comments));
      } catch (e) {
        emit(CommentError("Failed to load comments"));
      }
    });

    on<AddComment>((event, emit) async {
      try {
        await commentRepository.addComment(event.postId, event.content);
        add(LoadComments(event.postId)); // Reload comments after adding
      } catch (e) {
        emit(CommentError("Failed to add comment"));
      }
    });
  }
}
