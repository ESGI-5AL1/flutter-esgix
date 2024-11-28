class Author {
  final String id;
  final String username;
  final String avatar;

  const Author({
    required this.id,
    required this.username,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
