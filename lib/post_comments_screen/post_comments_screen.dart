import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import '../shared/bloc/post_widget_bloc/post_widget_event.dart';
import '../shared/bloc/post_widget_bloc/post_widget_state.dart';
import '../shared/models/author.dart';
import '../shared/widgets/post_widget.dart';
import '../shared/models/post.dart';

class PostCommentsScreen extends StatefulWidget {
  final String postId;

  const PostCommentsScreen({super.key, required this.postId});

  @override
  PostCommentsScreenState createState() => PostCommentsScreenState();
}

class PostCommentsScreenState extends State<PostCommentsScreen> {
  late PostBloc postBloc;
  bool commentsLoaded = false;

  @override
  void initState() {
    super.initState();
    postBloc = context.read<PostBloc>();

    if (widget.postId.isNotEmpty) {
      postBloc.add(FetchPostById(postId: widget.postId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post and Comments')),
      body: BlocListener<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostLoaded) {
            final postExists = state.posts.any((p) => p.id == widget.postId);
            if (postExists && !commentsLoaded) {
              postBloc.add(FetchComments(postId: widget.postId));
              commentsLoaded = true; // Empêcher le chargement multiple des commentaires
            }
          }
        },
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PostLoaded) {
              final post = state.posts.firstWhere(
                    (p) => p.id == widget.postId,
                orElse: () => Post(
                  id: '',
                  content: '',
                  imageUrl: '',
                  likesCount: 0,
                  commentsCount: 0,
                  parent: '',
                  author: Author(id: '', username: '', avatar: ''),
                  likedByUser: false,
                  createdAt: '',
                  updatedAt: '',
                ),
              );

              final comments = state.posts.where((p) => p.parent == widget.postId).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post parent affiché en haut, ne bouge pas
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: post.id.isEmpty
                        ? Center(child: Text('Post not found.'))
                        : PostWidget(post: post, isProfileScreen: false),
                  ),

                  const Divider(),

                  // Zone scrollable uniquement pour les commentaires
                  Expanded(
                    child: comments.isEmpty
                        ? Center(child: Text('No comments yet.'))
                        : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 32.0, right: 16.0, bottom: 8.0), // Décalage des commentaires
                          child: PostWidget(post: comment, isProfileScreen: false),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is PostError) {
              return Center(child: Text('Failed to load post and comments.'));
            } else {
              return Center(child: Text('Something went wrong.'));
            }
          },
        ),
      ),
    );
  }
}
