
class Friend {
  final String userId;
  final String? groupId;
  final String username;
  final String firstName;
  final String lastName;
  final bool pending;
  int? userTotalScore;
  final int friendTotalScore;

  Friend({
    required this.userId,
    this.groupId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.pending,
    this.userTotalScore,
    required this.friendTotalScore,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        userId: json['userId'],
        groupId: json['groupId'],
        username: json['username'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        pending: json['pending'],
        userTotalScore: json['userTotalScore'],
        friendTotalScore: json['friendTotalScore'],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "groupId": groupId,
        "username": username,
        "firstName": firstName,
        "lastName": lastName,
        "pending": pending,
        "userTotalScore": userTotalScore,
        "friendTotalScore": friendTotalScore,
      };
}
