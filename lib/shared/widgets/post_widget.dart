import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../login_screen/login_bloc/login_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_event.dart';
import '../models/post.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: LoginBloc.getUserId(),
      builder: (context, snapshot) {
        final isUserPost = snapshot.data == post.author.id;

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and delete button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(post.author.avatar),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatDate(post.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUserPost)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer la publication'),
                              content: const Text(
                                  'Vous confirmez la suppression?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<PostBloc>().add(DeletePost(post.id));
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  post.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Post image if exists
              if (post.imageUrl.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                  ),
                  width: double.infinity,
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

              // Interaction buttons and counters
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Like button and count
                    InkWell(
                      onTap: () {
                        context.read<PostBloc>().add(LikePost(post.id));
                      },
                      child: Row(
                        children: [
                          Icon(
                            post.likedByUser
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: post.likedByUser ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likesCount.toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Comments count
                    Row(
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.commentsCount.toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}