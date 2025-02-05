import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../login_screen/login_bloc/login_bloc.dart';
import '../../profile_screen/profile_post_screen.dart';
import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_event.dart';
import '../models/post.dart';
import '../models/user.dart';


class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: LoginBloc.getUserId(),
      builder: (context, snapshot) {
        final isUserPost = snapshot.data == post.author.id;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Section de l'utilisateur avec navigation
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final user = User(
                              id: post.author.id,
                              username: post.author.username,
                              avatar: post.author.avatar, description: '', email: ''
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePostScreen(user: user),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: post.author.avatar.isNotEmpty
                                ? NetworkImage(post.author.avatar)
                                : null,
                            child: post.author.avatar.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final user = User(
                              id: post.author.id,
                              username: post.author.username,
                              email: 'email@example.com', // Exemple
                              description: 'User description', // Exemple
                              avatar: post.author.avatar,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePostScreen(user: user),
                              ),
                            );
                          },
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
                      ],
                    ),
                    // Options de modification ou suppression
                    if (isUserPost)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Action pour éditer le post
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Supprimer la publication'),
                                  content: const Text('Vous confirmez la suppression?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<PostBloc>()
                                            .add(DeletePost(post.id));
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
                  ],
                ),
                const SizedBox(height: 8),
                // Contenu du post
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 16),
                ),
                if (post.imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          height: 150,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Boutons Like et Comment
                Row(
                  children: [
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
                    GestureDetector(
                      onTap: () {
                        context.push('/post/${post.id}/comments');
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.comment_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.commentsCount.toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
