// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ReadingQuranChallenge readingQuranChallengeFromJson(String str) =>
    ReadingQuranChallenge.fromJson(json.decode(str));

String readingQuranChallengeToJson(ReadingQuranChallenge data) =>
    json.encode(data.toJson());

class ReadingQuranChallenge {
  ReadingQuranChallenge({
    this.id,
    this.groupId,
    this.creatingUserId,
    this.expiryDate,
    this.usersFinished = const [],
    this.surahSubChallenges,
    this.finished,
  });

  String? id;
  String? groupId;
  String? creatingUserId;
  int? expiryDate;
  List<String>? usersFinished;
  List<SurahSubChallenge>? surahSubChallenges;
  bool? finished;

  factory ReadingQuranChallenge.fromJson(Map<String, dynamic> json) =>
      ReadingQuranChallenge(
        id: json["id"],
        groupId: json["groupId"],
        creatingUserId: json["creatingUserId"],
        expiryDate: json["expiryDate"],
        usersFinished: List<String>.from(json["usersFinished"].map((x) => x)),
        surahSubChallenges: List<SurahSubChallenge>.from(
            json["surahSubChallenges"]
                .map((x) => SurahSubChallenge.fromJson(x))),
        finished: json["finished"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "creatingUserId": creatingUserId,
        "expiryDate": expiryDate,
        "usersFinished": usersFinished,
        "surahSubChallenges":
            List<dynamic>.from(surahSubChallenges ?? [].map((x) => x.toJson())),
        "finished": finished,
      };

  String getName() {
    return "قراءة قرآن";
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
