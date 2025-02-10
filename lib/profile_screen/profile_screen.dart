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
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<PostBloc>().add(FetchUserPosts(userId: userState.user.id));
    }
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
              child: const Text('Enregistrer'),
            ),
          ] else ...[
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
            Text(
              user.description.isNotEmpty ? user.description : "",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
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
              title: const Text('Profil'),
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
            body: Column(children: [
              _buildProfileHeader(user),
              const Divider(),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: const [
                          Tab(icon: Icon(Icons.list), text: "Posts"),
                          Tab(icon: Icon(Icons.thumb_up), text: "Posts likés"),
                        ],
                        indicatorColor: Colors.blue,
                        onTap: (index) {
                          if (index == 0) {
                            context
                                .read<PostBloc>()
                                .add(FetchUserPosts(userId: user.id));
                          } else {
                            context
                                .read<PostBloc>()
                                .add(FetchUserLikes(userId: user.id));
                          }
                        },
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Posts Tab
                            BlocBuilder<PostBloc, PostState>(
                              builder: (context, state) {
                                if (state is PostLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is PostLoaded) {
                                  final userPosts = state.posts
                                      .where((post) => post.parent.isEmpty)
                                      .toList();
                                  return _buildPostList(userPosts);
                                } else if (state is PostError) {
                                  return Center(
                                      child: Text('Error: ${state.message}'));
                                }
                                return const Center(
                                    child: Text("Rien à voir ici..."));
                              },
                            ),

                            // Liked Posts Tab
                            BlocBuilder<PostBloc, PostState>(
                              builder: (context, state) {
                                if (state is PostLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is PostLoaded) {
                                  if (state.posts.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "PAs de posts likés pour l'instant...",
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }
                                  return _buildPostList(state.posts);
                                } else if (state is PostError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text('Error: ${state.message}'),
                                    ),
                                  );
                                }
                                return const Center(
                                    child: Text("Chargement..."));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]),
          );
        } else if (userState is UserError) {
          return Scaffold(
            body: Center(child: Text(userState.message)),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Rien à voir ici...')),
        );
      },
    );
  }
}

Widget _buildPostList(List<Post> posts) {
  if (posts.isEmpty) {
    return const Center(child: Text("Rien à voir ici..."));
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
