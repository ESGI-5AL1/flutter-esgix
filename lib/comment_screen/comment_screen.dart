import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/models/PostResult.dart';
import '../shared/widgets/modal_add_comment.dart';
import '../shared/widgets/post_card.dart';
import 'bloc/comment_bloc.dart';
import 'bloc/comment_event.dart';
import 'bloc/comment_state.dart';
import 'comment_repository.dart';

class CommentScreen extends StatelessWidget {
  final PostResult post;
  final CommentRepository commentRepository;

  const CommentScreen({super.key, required this.post, required this.commentRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentBloc(commentRepository)..add(LoadComments(post.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
        ),
        body: Column(
          children: [
            PostCard(post: post, commentRepository: commentRepository),
            const Divider(),
            Expanded(
              child: BlocBuilder<CommentBloc, CommentState>(
                builder: (context, state) {
                  if (state is CommentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CommentLoaded) {
                    return ListView.builder(
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: state.comments[index],
                          commentRepository: commentRepository,
                        );
                      },
                    );
                  } else if (state is CommentError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('No comments yet.'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => ModalAddComment(
                parentId: post.id,
                commentRepository: commentRepository,
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
