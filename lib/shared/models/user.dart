class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String description;
  final String avatar;

  const User({
    required this.username,
    required this.description,
    required this.id,
    required this.password,
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
      password: '',
      email: email,
      avatar: avatar,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      description: json['description'],
      email: json['email'],
      avatar: json['avatar'],
      password: json['password'],
    );
  }
}
