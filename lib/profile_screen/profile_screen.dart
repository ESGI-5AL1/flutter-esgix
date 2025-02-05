import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../login_screen/login_bloc/login_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/bloc/user_bloc/user_bloc.dart';
import '../shared/models/user.dart';
import '../shared/widgets/navigation_widget.dart';
import '../shared/widgets/post_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = await LoginBloc.getUserId();
    if (userId != null && mounted) {
      context.read<UserBloc>().add(FetchUserProfile(userId));
      context.read<PostBloc>().add(FetchUserPosts(userId));
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (userState is UserLoaded && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _startEditing(userState.user),
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isEditing = false),
                ),
            ],
          ),
          drawer: const AppNavigationDrawer(),
          body: RefreshIndicator(
            onRefresh: _loadUserProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (userState is UserLoaded) ...[
                    Container(
                      width: MediaQuery.of(context).size.width, // Make it full width
                      padding: const EdgeInsets.symmetric(vertical: 16), // Remove horizontal padding
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(userState.user.avatar),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userState.user.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (userState.user.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                userState.user.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _avatarController,
                              decoration: const InputDecoration(
                                labelText: 'Avatar URL',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
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
                            ),
                          ],
                        ),
                      )
                    else
                      BlocBuilder<PostBloc, PostState>(
                        builder: (context, postState) {
                          if (postState is PostLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (postState is PostLoaded) {
                            if (postState.posts.isEmpty) {
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No posts yet',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: postState.posts.length,
                              itemBuilder: (context, index) {
                                return PostWidget(
                                  post: postState.posts[index],
                                  isProfileScreen: true,
                                );
                              },
                            );
                          } else if (postState is PostError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(postState.message),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
          floatingActionButton: !_isEditing ? FloatingActionButton(
            onPressed: () => context.go('/create-post'),
            child: const Icon(Icons.add),
          ) : null,
        );
      },
    );
  }
}