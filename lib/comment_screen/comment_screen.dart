import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/models/post.dart';
import '../shared/widgets/comment_card.dart';
import '../shared/widgets/post_card.dart';
import 'bloc/comment_bloc.dart';
import 'bloc/comment_event.dart';
import 'bloc/comment_state.dart';
import 'comment_repository.dart';

class CommentScreen extends StatelessWidget {
  final Post post;
  final CommentRepository commentRepository;

  const CommentScreen({super.key, required this.post, required this.commentRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      CommentBloc(commentRepository)..add(LoadComments(post.id)),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Naviguer vers le feed (ajoutez une fois prêt)
              Navigator.pop(context);
            },
          ),
          title: const Text('Comments'),
        ),
        body: Column(
          children: [
            PostCard(post: post), // Affiche le post parent
            Divider(),
            Expanded(
              child: BlocBuilder<CommentBloc, CommentState>(
                builder: (context, state) {
                  if (state is CommentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CommentLoaded) {
                    return ListView.builder(
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        return CommentCard(comment: state.comments[index]);
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
            // Ajoutez une action pour créer un nouveau commentaire
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
