class UserGroup {
  UserGroup({
    this.groupId,
    this.groupName,
    this.invitingUserId,
    this.isPending,
    this.monthScore,
    this.totalScore,
  });

  String? groupId;
  String? groupName;
  String? invitingUserId;
  bool? isPending;
  int? monthScore;
  int? totalScore;

  factory UserGroup.fromJson(Map<String, dynamic> json) => UserGroup(
        groupId: json["groupId"],
        groupName: json["groupName"],
        invitingUserId: json["invitingUserId"],
        isPending: json["isPending"],
        monthScore: json["monthScore"],
        totalScore: json["totalScore"],
      );

  Map<String, dynamic> toJson() => {
        "groupId": groupId,
        "groupName": groupName,
        "invitingUserId": invitingUserId,
        "isPending": isPending,
        "monthScore": monthScore,
        "totalScore": totalScore,
      };
}
