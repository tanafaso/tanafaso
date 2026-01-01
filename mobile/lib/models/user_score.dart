class UserScore {
  UserScore({
    this.firstName,
    this.lastName,
    this.username,
    this.totalScore,
  });

  String? firstName;
  String? lastName;
  String? username;
  int? totalScore;

  factory UserScore.fromJson(Map<String, dynamic> json) => UserScore(
        firstName: json["firstName"],
        lastName: json["lastName"],
        username: json["username"],
        totalScore: json["totalScore"],
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "totalScore": totalScore,
      };
}
