import 'package:esgix/shared/widgets/post_widget.dart';
import 'package:flutter/material.dart';

class feed_Screen extends StatelessWidget {
  final List<PostWidget> posts = [
    PostWidget(
      username: "/bpkhalil",
      title: "Syntax Verification",
      content:
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, Lorem Ipsum.",
      likes: 69,
      comments: 12,
    ),
    PostWidget(
      username: "/flutterdev",
      title: "New Flutter Update",
      content:
      "Flutter has introduced new features for better performance. Check out the new widgets and enhancements available in the latest version.",
      likes: 120,
      comments: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feed")),
      body: ListView(
        children: posts, // Utiliser la liste dynamique ici
      ),
    );
  }
}
