import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/post.dart';
import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_state.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
            // Header : Avatar + Username + Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.author.avatar.isNotEmpty
                          ? NetworkImage(post.author.avatar)
                          : null,
                      child: post.author.avatar.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.author.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Menu contextuel (Edit/Delete)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      print('Edit post ${post.id}');
                    } else if (value == 'delete') {
                      print('Delete post ${post.id}');
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Post content
            Text(
              post.content,
              style: const TextStyle(fontSize: 16),
            ),

            // Post image (if available)
            if (post.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl,
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

            // Likes and comments
            Row(
              children: [
                // Gestion du Like
                GestureDetector(
                  onTap: () {
                    print('Like clicked for post ${post.id}');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: post.likedByUser ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likes} likes'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Gestion des commentaires
                GestureDetector(
                  onTap: () {
                    print('📌 Commentaires pour le post ${post.id}:');

                    // Récupérer les commentaires directement depuis le BLoC
                    final blocState = context.read<PostBloc>().state;
                    if (blocState is PostLoaded) {

                      List<Post> comments = blocState.posts
                          .where((p) => p.parent == post.id)
                          .toList();

                      if (comments.isNotEmpty) {
                        print('Nombre de commentaires: ${comments.length}');
                        for (var comment in comments) {
                          print('- ${comment.content} (Auteur: ${comment.author.username})');
                        }
                      } else {
                        print('❌ Aucun commentaire pour ce post.');
                      }
                    } else {
                      print('❌ Impossible de récupérer les commentaires.');
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${post.commentsCount} comments'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
