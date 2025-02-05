import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/models/author.dart';
import '../shared/widgets/post_widget.dart';
import '../shared/models/post.dart';

class PostCommentsScreen extends StatelessWidget {
  final String postId;

  const PostCommentsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final postBloc = context.read<PostBloc>();

    if (postId.isNotEmpty) {
      postBloc.add(FetchPostById(postId: postId));
      postBloc.add(FetchComments(postId: postId));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post and Comments'),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostLoaded) {
            final post = state.posts.firstWhere(
              (p) => p.id == postId,
              orElse: () => Post(
                id: '',
                content: '',
                imageUrl: '',
                likesCount: 0,
                commentsCount: 0,
                parent: '',
                author: Author(id: '', username: '', avatar: ''),
                likedByUser: false,
                createdAt: '',
                updatedAt: '',
              ),
            );

            final comments =
                state.posts.where((p) => p.parent == postId).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.id.isEmpty)
                      const Center(child: Text('Post not found.'))
                    else
                      PostWidget(post: post, isProfileScreen: false),
                    const SizedBox(height: 16),
                    ...comments.map((comment) => Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: PostWidget(
                            post: comment,
                            isProfileScreen: false,
                          ),
                        )),
                  ],
                ),
              ),
            );
          } else if (state is PostError) {
            return const Center(
                child: Text('Failed to load post and comments.'));
          } else {
            return const Center(child: Text('Failed to load comments.'));
          }
        },
      ),
    );
  }
}
