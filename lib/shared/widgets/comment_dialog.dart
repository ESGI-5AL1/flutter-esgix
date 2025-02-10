// lib/shared/widgets/comment_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/post.dart';
import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_event.dart';

class CommentDialog extends StatefulWidget {
  final Post post;

  const CommentDialog({super.key, required this.post});

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un commentaire'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Écrivez votre commentaire...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              hintText: 'URL de l\'image (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () async {
            if (_commentController.text.trim().isEmpty) return;

            setState(() => _isSubmitting = true);

            final imageUrl = _imageUrlController.text.trim();

            context.read<PostBloc>().add(
              CreateComment(
                _commentController.text.trim(),
                widget.post.id,
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
              ),
            );

            context.read<PostBloc>().add(FetchPosts());

            Navigator.pop(context);
          },
          child: _isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Commenter'),
        ),
      ],
    );
  }
}