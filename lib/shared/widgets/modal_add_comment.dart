import 'package:flutter/material.dart';
import '../../comment_screen/comment_repository.dart';

class ModalAddComment extends StatelessWidget {
  final String parentId;
  final CommentRepository commentRepository;

  const ModalAddComment({super.key, required this.parentId, required this.commentRepository});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Comment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Enter your comment'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await commentRepository.addComment(parentId, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
