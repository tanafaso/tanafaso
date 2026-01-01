import 'sub_challenge.dart';

class AzkarChallenge {
  AzkarChallenge({
    this.id,
    this.groupId,
    this.creatingUserId,
    this.motivation,
    this.name,
    this.expiryDate,
    this.usersFinished = const [],
    this.subChallenges = const [],
  });

  String? id;
  String? groupId;
  String? creatingUserId;
  String? motivation;
  String? name;

  // In seconds since epoch
  int? expiryDate;
  List<String> usersFinished;
  List<SubChallenge> subChallenges;

  factory AzkarChallenge.fromJson(Map<String, dynamic> json) => AzkarChallenge(
        id: json["id"],
        groupId: json["groupId"],
        creatingUserId: json["creatingUserId"],
        motivation: json["motivation"],
        name: json["name"],
        expiryDate: json["expiryDate"],
        usersFinished: List<String>.from(json["usersFinished"].map((x) => x)),
        subChallenges: List<SubChallenge>.from(
            json["subChallenges"].map((x) => SubChallenge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "creatingUserId": creatingUserId,
        "motivation": motivation,
        "name": name,
        "expiryDate": expiryDate,
        "usersFinished": List<String>.from(usersFinished.map((x) => x)),
        "subChallenges":
            List<dynamic>.from(subChallenges.map((x) => x.toJson())),
      };

  bool done() {
    for (SubChallenge subChallenge in subChallenges) {
      if (!subChallenge.done()) {
        return false;
      }
    }
    return true;
  }

  bool deadlinePassed() {
    int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return secondsSinceEpoch >= (expiryDate ?? 0);
  }
}
