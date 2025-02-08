import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_event.dart';
import '../models/post.dart';

class CommentDialog extends StatefulWidget {
  final Post post;

  const CommentDialog({
    super.key,
    required this.post,
  });

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Répondre'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (_contentController.text.isNotEmpty) {
              context.read<PostBloc>().add(
                CreateComment(
                  _contentController.text,
                  widget.post.id,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Poster'),
        ),
      ],
    );
  }
}