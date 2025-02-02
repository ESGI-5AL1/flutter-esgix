import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/widgets/post_widget.dart';
import '../shared/models/post.dart';

class PostCommentsScreen extends StatelessWidget {
  final String postId;

  const PostCommentsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final postBloc = context.read<PostBloc>();
    postBloc.add(FetchComments(postId: postId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PostLoaded) {
            final comments = state.posts.where((p) => p.parent == postId).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the comments
                    ...comments.map((comment) => Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: PostWidget(post: comment),
                    )),
                  ],
                ),
              ),
            );
          } else if (state is PostError) {
            return Center(child: Text('Failed to load comments.'));
          } else {
            return Center(child: Text('Failed to load comments.'));
          }
        },
      ),
    );
  }
}