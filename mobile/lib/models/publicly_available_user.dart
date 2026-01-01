import 'dart:convert';

List<PubliclyAvailableUser> welcomeFromJson(String str) =>
    List<PubliclyAvailableUser>.from(
        json.decode(str).map((x) => PubliclyAvailableUser.fromJson(x)));

String welcomeToJson(List<PubliclyAvailableUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PubliclyAvailableUser {
  PubliclyAvailableUser({
    this.userId,
    this.firstName,
    this.lastName,
  });

  String? userId;
  String? firstName;
  String? lastName;

  factory PubliclyAvailableUser.fromJson(Map<String, dynamic> json) =>
      PubliclyAvailableUser(
        userId: json["userId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
      };
}
