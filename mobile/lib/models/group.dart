import 'dart:convert';

Group groupFromJson(String str) => Group.fromJson(json.decode(str));

String groupToJson(Group data) => json.encode(data.toJson());

class Group {
  Group({
    this.id,
    this.name,
    this.adminId,
    this.usersIds = const [],
    this.challengesIds = const [],
    this.binary,
  });

  String? id;
  String? name;
  String? adminId;
  List<String>? usersIds;
  List<String>? challengesIds;
  bool? binary;

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"],
        name: json["name"],
        adminId: json["adminId"],
        usersIds: List<String>.from(json["usersIds"].map((x) => x)),
        challengesIds: List<String>.from(json["challengesIds"].map((x) => x)),
        binary: json["binary"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "adminId": adminId,
        "usersIds": List<dynamic>.from(usersIds ?? [].map((x) => x)),
        "challengesIds": List<dynamic>.from(challengesIds ?? [].map((x) => x)),
        "binary": binary,
      };
}

class CachedGroupInfo {
  CachedGroupInfo({
    this.id,
    this.name,
    this.adminId,
    this.usersIds = const [],
    // this.challengesIds = const [],
    this.binary,
  });

  String? id;
  String? name;
  String? adminId;
  List<String>? usersIds;

  // List<String> challengesIds;
  bool? binary;

  factory CachedGroupInfo.fromGroup(Group group) => CachedGroupInfo(
        id: group.id,
        name: group.name,
        adminId: group.adminId,
        usersIds: group.usersIds,
        binary: group.binary,
      );

  factory CachedGroupInfo.fromJson(Map<String, dynamic> json) =>
      CachedGroupInfo(
        id: json["id"],
        name: json["name"],
        adminId: json["adminId"],
        usersIds: List<String>.from(json["usersIds"].map((x) => x)),
        // challengesIds: List<String>.from(json["challengesIds"].map((x) => x)),
        binary: json["binary"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "adminId": adminId,
        "usersIds": List<dynamic>.from(usersIds ?? [].map((x) => x)),
        // "challengesIds": List<dynamic>.from(challengesIds.map((x) => x)),
        "binary": binary,
      };
}
