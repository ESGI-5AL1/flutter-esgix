import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../login_screen/login_bloc/login_bloc.dart';
import '../bloc/user_bloc/user_bloc.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close drawer
    context.read<LoginBloc>().add(LogoutRequested());
    await Future.delayed(const Duration(milliseconds: 100));
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
          child: FutureBuilder<String?>(
            future: LoginBloc.getUserId(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              return BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(state.user.avatar),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.user.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Feed'),
          onTap: () {
            Navigator.pop(context);
            context.go('/feed');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {
            Navigator.pop(context);
            context.go('/profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }
}