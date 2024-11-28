import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String title;
  final String content;
  final int likes;
  final int comments;

  const PostWidget({
    super.key,
    required this.username,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Username, and Context Menu
            Row(
              children: [
                // Profile picture
                const CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 8.0),
                // Username
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Context menu (3 dots)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Handle "more" action
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Content with "See more"
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 4.0),
            GestureDetector(
              onTap: () {
                // Handle "See more" action
              },
              child: const Text(
                "See more",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Footer: Likes and Comments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Likes
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 20.0),
                    const SizedBox(width: 4.0),
                    Text(
                      likes.toString(),
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
                // Comments
                Row(
                  children: [
                    const Icon(Icons.comment, size: 20.0),
                    const SizedBox(width: 4.0),
                    Text(
                      comments.toString(),
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
