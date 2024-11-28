import 'package:flutter/material.dart';

import '../models/post.dart';  // Import the Post model

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author information
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.author.avatar),
                ),
                SizedBox(width: 8.0),
                Text(post.author.username, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8.0),
            // Content of the post
            Text(post.content),
            SizedBox(height: 8.0),
            // Image (if available)
            if (post.imageUrl.isNotEmpty)
              Image.network(post.imageUrl),
            // Like/Comment info
            Row(
              children: [
                Text('${post.likes} Likes'),
                SizedBox(width: 8.0),
                Text('${post.commentsCount} Comments'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
