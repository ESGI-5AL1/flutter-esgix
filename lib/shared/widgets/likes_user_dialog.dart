// likes_users_dialog.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/posts_repository/posts_repository.dart';
import '../../profile_screen/profile_post_screen.dart';




class LikesUsersDialog extends StatefulWidget {
  final String postId;
  final PostRepository repository;

  const LikesUsersDialog({
    Key? key,
    required this.postId,
    required this.repository,
  }) : super(key: key);

  @override
  State<LikesUsersDialog> createState() => _LikesUsersDialogState();
}

class _LikesUsersDialogState extends State<LikesUsersDialog> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    try {
      // Ajout d'un print pour déboguer
      print('Fetching users for post: ${widget.postId}');
      final users = await widget.repository.getUsersWhoLikedPost(widget.postId);
      print('Fetched users: $users');
      return users;
    } catch (e, stackTrace) {
      // Ajout du print de l'erreur complète et de la stack trace
      print('Error fetching users: $e');
      print('Stack trace: $stackTrace');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personnes qui ont aimé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur: ${snapshot.error.toString()}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _usersFuture = _fetchUsers();
                              });
                            },
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun like',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.avatar.isNotEmpty
                              ? NetworkImage(user.avatar)
                              : null,
                          child: user.avatar.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user.username),
                        subtitle: user.description.isNotEmpty
                            ? Text(
                          user.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePostScreen(user: user),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}