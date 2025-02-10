import 'package:esgix/profile_screen/profile_bloc/profile_event.dart';
import 'package:esgix/profile_screen/profile_bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/models/user.dart';
import '../shared/repositories/posts_repository/posts_repository.dart';
import './profile_bloc/profile_bloc.dart';
import '../shared/models/post.dart';
import '../shared/widgets/post_widget.dart';

class ProfilePostScreen extends StatelessWidget {
  final User user;

  const ProfilePostScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        repository: context.read<PostRepository>(),
      )..add(LoadProfileData(
          userId: user.id,
          loadLikes: false
      )),
      child: _ProfilePostScreenContent(user: user),
    );
  }
}

class _ProfilePostScreenContent extends StatelessWidget {
  final User user;

  const _ProfilePostScreenContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                    child: user.avatar.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      user.description ?? "No description available",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(icon: Icon(Icons.list), text: "Posts"),
                      Tab(icon: Icon(Icons.thumb_up), text: "Liked Posts"),
                    ],
                    indicatorColor: Colors.blue,
                    onTap: (index) {
                      context.read<ProfileBloc>().add(LoadProfileData(
                          userId: user.id,
                          loadLikes: index == 1
                      ));
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is ProfileLoaded) {
                              return _buildPostList(state.posts);
                            } else if (state is ProfileError) {
                              return Center(child: Text('Error: ${state.message}'));
                            }
                            return const Center(child: Text("No posts found."));
                          },
                        ),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is ProfileLoaded) {
                              return _buildPostList(state.posts);
                            } else if (state is ProfileError) {
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

  Widget _buildPostList(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No posts available.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostWidget(
          post: post,
          isProfileScreen: false,
        );
      },
    );
  }
}