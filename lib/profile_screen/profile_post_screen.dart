import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/models/user.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/models/post.dart';
import '../shared/widgets/post_widget.dart';


class ProfilePostScreen extends StatelessWidget {
  final User user;

  const ProfilePostScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Charger les posts lors de l'ouverture de l'écran
    context.read<PostBloc>().add(FetchPosts());

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: Column(
        children: [
          // Header avec la photo de profil
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            color: Colors.grey[200],
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user.avatar.isNotEmpty
                    ? NetworkImage(user.avatar)
                    : null,
                child: user.avatar.isEmpty ? const Icon(Icons.person, size: 50) : null,
              ),
            ),
          ),
          const Divider(),
          // Onglets pour les posts
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(icon: Icon(Icons.list), text: "Posts"),
                      Tab(icon: Icon(Icons.thumb_up), text: "Liked/Commented"),
                    ],
                    indicatorColor: Colors.blue,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Onglet "Mes posts"
                        BlocBuilder<PostBloc, PostState>(
                          builder: (context, state) {
                            if (state is PostLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is PostLoaded) {
                              final userPosts = state.posts
                                  .where((post) =>
                              post.author.id == user.id && post.parent.isEmpty)
                                  .toList();

                              return _buildPostList(userPosts);
                            } else if (state is PostError) {
                              return Center(child: Text('Error: ${state.message}'));
                            }
                            return const Center(child: Text("No posts found."));
                          },
                        ),
                        // Onglet "Aimés/Commentés"
                        BlocBuilder<PostBloc, PostState>(
                          builder: (context, state) {
                            if (state is PostLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is PostLoaded) {
                              final likedOrCommentedPosts = state.posts
                                  .where((post) =>
                              post.likedByUser || post.commentsCount > 0)
                                  .toList();

                              return _buildPostList(likedOrCommentedPosts);
                            } else if (state is PostError) {
                              return Center(child: Text('Error: ${state.message}'));
                            }
                            return const Center(child: Text("No posts found."));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher la liste des posts
  Widget _buildPostList(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text("No posts available."));
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostWidget(post: post, isProfileScreen: false,); // Réutilisation de PostWidget
      },
    );
  }
}
