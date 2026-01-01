
class User {
  String? email;
  String id;
  String username;
  String firstName;
  String? lastName;

  User({
    this.email,
    required this.id,
    required this.username,
    required this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() => {};
}
