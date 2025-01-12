import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_event.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_state.dart';
import 'package:esgix/shared/widgets/post_widget.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch FetchPosts event to load posts
    context.read<PostBloc>().add(FetchPosts());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESGIX'),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostLoaded) {
            final posts = state.posts;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostWidget(post: posts[index]);
              },
            );
          } else if (state is PostError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No posts available.'));
          }
        },
      ),
    );
  }
}
