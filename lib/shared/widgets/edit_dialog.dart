import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../bloc/post_widget_bloc/post_widget_event.dart';
import '../models/post.dart';

class EditPostDialog extends StatefulWidget {
  final Post post;

  const EditPostDialog({super.key, required this.post});

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  late TextEditingController _contentController;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _imageUrl = widget.post.imageUrl;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mettre à jour le post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Image URL (opt)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _imageUrl = value,
            controller: TextEditingController(text: _imageUrl),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            context.read<PostBloc>().add(
                  UpdatePost(
                    postId: widget.post.id,
                    content: _contentController.text,
                    imageUrl: _imageUrl,
                  ),
                );
            Navigator.pop(context);
          },
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}
