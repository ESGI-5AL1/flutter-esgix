import 'package:flutter/material.dart';
import '../../comment_screen/comment_repository.dart';
import '../models/PostResult.dart';

class PostCard extends StatefulWidget {
  final PostResult post;
  final CommentRepository commentRepository;
  final List<PostResult> childrenPosts;

  const PostCard({
    super.key,
    required this.post,
    required this.commentRepository,
    this.childrenPosts = const [],
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int likesCount;
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    likesCount = widget.post.likes;
    isLiked = false;
  }

  void _toggleLike() async {
    try {
      await widget.commentRepository.toggleLike(widget.post.id);
      setState(() {
        isLiked = !isLiked;
        likesCount += isLiked ? 1 : -1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle like: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bloc principal (Post Parent)
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        // Avatar
                        CircleAvatar(
                          backgroundImage: widget.post.authorAvatar.isNotEmpty
                              ? NetworkImage(widget.post.authorAvatar)
                              : null,
                          child: widget.post.authorAvatar.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 8),

                        Text(
                          '/${widget.post.authorUsername}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          print('Edit post ${widget.post.id}');
                        } else if (value == 'delete') {
                          print('Delete post ${widget.post.id}');
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


                Text(
                  widget.post.content,
                  style: const TextStyle(fontSize: 16),
                ),


                if (widget.post.imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Image.network(widget.post.imageUrl),
                ],

                const SizedBox(height: 8),


                Row(
                  children: [
                    // Likes
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('$likesCount likes'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Comments Count
                    const Icon(Icons.comment, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('${widget.post.commentsCount} comments'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Bloc des commentaires enfants (encadré)
        if (widget.childrenPosts.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(left: 32, right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: widget.childrenPosts.map((childPost) {
                return PostCard(
                  post: childPost,
                  commentRepository: widget.commentRepository,
                  childrenPosts: [],
                  //@TODO Pas de récursion sur plusieurs niveaux: à corriger commentaire d'un commentaire parent
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
