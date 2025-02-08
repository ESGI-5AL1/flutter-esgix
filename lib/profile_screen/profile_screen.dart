import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/bloc/user_bloc/user_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/models/post.dart';
import '../shared/models/user.dart';
import '../shared/widgets/navigation_widget.dart';
import '../shared/widgets/post_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(FetchPosts());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _startEditing(User user) {
    _usernameController.text = user.username;
    _descriptionController.text = user.description;
    _avatarController.text = user.avatar;
    setState(() {
      _isEditing = true;
    });
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isEditing) ...[
            // Avatar URL field
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<UserBloc>().add(
                      UpdateUserProfile(
                        username: _usernameController.text,
                        description: _descriptionController.text,
                        avatar: _avatarController.text,
                      ),
                    );
                setState(() => _isEditing = false);
              },
              child: const Text('Save Changes'),
            ),
          ] else ...[
            // Display mode
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
            if (user.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is UserLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (userState is UserLoaded) {
          final user = userState.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _startEditing(user),
                  ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _isEditing = false),
                  ),
              ],
            ),
            drawer: const AppNavigationDrawer(),
            body: Column(
              children: [
                _buildProfileHeader(user),
                const Divider(),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.list), text: "Posts"),
                            Tab(
                                icon: Icon(Icons.thumb_up),
                                text: "Liked/Commented"),
                          ],
                          indicatorColor: Colors.blue,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // My Posts Tab
                              BlocBuilder<PostBloc, PostState>(
                                builder: (context, state) {
                                  if (state is PostLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (state is PostLoaded) {
                                    final userPosts = state.posts
                                        .where((post) =>
                                            post.author.id == user.id &&
                                            post.parent.isEmpty)
                                        .toList();
                                    return _buildPostList(userPosts);
                                  } else if (state is PostError) {
                                    return Center(
                                        child: Text('Error: ${state.message}'));
                                  }
                                  return const Center(
                                      child: Text("No posts found."));
                                },
                              ),
                              // Liked/Commented Tab
                              BlocBuilder<PostBloc, PostState>(
                                builder: (context, state) {
                                  if (state is PostLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (state is PostLoaded) {
                                    final likedOrCommentedPosts = state.posts
                                        .where((post) =>
                                            post.likedByUser ||
                                            post.commentsCount > 0)
                                        .toList();
                                    return _buildPostList(
                                        likedOrCommentedPosts);
                                  } else if (state is PostError) {
                                    return Center(
                                        child: Text('Error: ${state.message}'));
                                  }
                                  return const Center(
                                      child: Text("No posts found."));
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
        } else if (userState is UserError) {
          return Scaffold(
            body: Center(child: Text(userState.message)),
          );
        }
        return const Scaffold(
          body: Center(child: Text('No profile data available')),
        );
      },
    );
  }
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
      return PostWidget(
        post: post,
        isProfileScreen: false,
      ); // Réutilisation de PostWidget
    },
  );
}
