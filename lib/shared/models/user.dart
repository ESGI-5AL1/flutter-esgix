class User {
  final String id;
  final String username;
  final String email;
  final String description;
  final String avatar;

  const User({
    required this.username,
    required this.description,
    required this.id,
    required this.email,
    required this.avatar,
  });

  factory User.profileInfos({
    required String username,
    required String description,
    required String id,
    required String email,
    required String avatar,
  }) {
    return User(
      username: username,
      description: description,
      id: id,
      email: email,
      avatar: avatar,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
