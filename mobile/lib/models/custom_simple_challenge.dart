// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

CustomSimpleChallenge customSimpleChallengeFromJson(String str) =>
    CustomSimpleChallenge.fromJson(json.decode(str));

String customSimpleChallengeToJson(CustomSimpleChallenge data) =>
    json.encode(data.toJson());

class CustomSimpleChallenge {
  CustomSimpleChallenge({
    this.id,
    this.groupId,
    this.creatingUserId,
    this.expiryDate,
    this.usersFinished = const [],
    this.description,
    this.finished,
  });

  String? id;
  String? groupId;
  String? creatingUserId;
  int? expiryDate;
  List<String>? usersFinished;
  String? description;
  bool? finished;

  factory CustomSimpleChallenge.fromJson(Map<String, dynamic> json) =>
      CustomSimpleChallenge(
        id: json["id"],
        groupId: json["groupId"],
        creatingUserId: json["creatingUserId"],
        expiryDate: json["expiryDate"],
        usersFinished: List<String>.from(json["usersFinished"].map((x) => x)),
        description: json["description"],
        finished: json["finished"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "creatingUserId": creatingUserId,
        "expiryDate": expiryDate,
        "usersFinished": usersFinished,
        "description": description,
        "finished": finished,
      };

  String? getName() {
    return description;
  }
}

class SurahSubChallenge {
  SurahSubChallenge({
    this.surahName,
    this.startingVerseNumber,
    this.endingVerseNumber,
  });

  String? surahName;
  int? startingVerseNumber;
  int? endingVerseNumber;

  factory SurahSubChallenge.fromJson(Map<String, dynamic> json) =>
      SurahSubChallenge(
        surahName: json["surahName"],
        startingVerseNumber: json["startingVerseNumber"],
        endingVerseNumber: json["endingVerseNumber"],
      );

  Map<String, dynamic> toJson() => {
        "surahName": surahName,
        "startingVerseNumber": startingVerseNumber,
        "endingVerseNumber": endingVerseNumber,
      };
}
