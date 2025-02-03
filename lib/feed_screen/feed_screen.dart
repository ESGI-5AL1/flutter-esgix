import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../login_screen/login_bloc/login_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/bloc/user_bloc/user_bloc.dart';
import '../shared/widgets/navigation_widget.dart';
import '../shared/widgets/post_widget.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch posts
    context.read<PostBloc>().add(FetchPosts());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESGIX'),
      ),
      drawer: const AppNavigationDrawer(), // Add the drawer here
      body: Column(
        children: [
          // Add FutureBuilder in the widget tree
          FutureBuilder<String?>(
            future: LoginBloc.getUserId(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                context.read<UserBloc>().add(FetchUserProfile(snapshot.data!));
              }
              return const SizedBox.shrink();
            },
          ),
          // Posts list in Expanded to take remaining space
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create-post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}