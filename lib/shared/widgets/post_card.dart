import 'package:flutter/material.dart';
import '../../comment_screen/comment_repository.dart';
import '../models/PostResult.dart';

class PostCard extends StatefulWidget {
  final PostResult post;
  final CommentRepository commentRepository;
  final List<PostResult> childrenPosts; // Liste des commentaires enfants

  const PostCard({
    super.key,
    required this.post,
    required this.commentRepository,
    this.childrenPosts = const [], // Par défaut, pas de commentaires enfants
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
    isLiked = false; // Par défaut, le like n'est pas actif
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
                // Menu contextuel (Edit/Delete)
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(widget.post.imageUrl),
              ),
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


            if (widget.childrenPosts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.childrenPosts.map((childPost) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: PostCard(
                        post: childPost,
                        commentRepository: widget.commentRepository,
                        childrenPosts: [],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
