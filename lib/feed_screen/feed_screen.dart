import 'dart:async';

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

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostBloc>().add(FetchPosts());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context.read<PostBloc>().add(FetchPosts());
      } else {
        context.read<PostBloc>().add(SearchPosts(query));
      }
    });
  }

  Future<void> _refreshFeed() async {
    _searchController.clear();
    context.read<PostBloc>().add(FetchPosts());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESGIX'),
      ),
      drawer: const AppNavigationDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un post',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<PostBloc>().add(FetchPosts());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          FutureBuilder<String?>(
            future: LoginBloc.getUserId(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                context.read<UserBloc>().add(FetchUserProfile(snapshot.data!));
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PostLoaded) {
                  final posts = state.posts;
                  if (posts.isEmpty) {
                    return const Center(
                      child: Text('Rien à voir ici..'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refreshFeed,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return PostWidget(
                          post: posts[index],
                          isProfileScreen: false,
                        );
                      },
                    ),
                  );
                } else if (state is PostError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PostBloc>().add(FetchPosts());
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
