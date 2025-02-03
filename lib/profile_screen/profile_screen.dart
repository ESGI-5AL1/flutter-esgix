import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/bloc/user_bloc/user_bloc.dart';
import '../shared/models/user.dart';
import '../shared/widgets/navigation_widget.dart';

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
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (state is UserLoaded && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _startEditing(state.user),
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isEditing = false),
                ),
            ],
          ),
          drawer: const AppNavigationDrawer(), // Add the drawer here
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(UserState state) {
    if (state is UserLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is UserLoaded) {
      final user = state.user;
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.blue],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _avatarController,
                        decoration: const InputDecoration(
                          labelText: 'Avatar URL',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.avatar),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing) ...[
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
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
                      ] else ...[
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Username'),
                          subtitle: Text(user.username),
                        ),
                        if (user.description.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('About'),
                            subtitle: Text(user.description),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state is UserError) {
      return Center(child: Text(state.message));
    }
    return const Center(child: Text('No profile data available'));
  }
}