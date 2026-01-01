import 'dart:convert';

MemorizationChallenge memorizationFromJson(String str) =>
    MemorizationChallenge.fromJson(json.decode(str));

String memorizationToJson(MemorizationChallenge data) =>
    json.encode(data.toJson());

class MemorizationChallenge {
  MemorizationChallenge({
    this.id,
    this.groupId,
    this.creatingUserId,
    this.expiryDate,
    this.usersFinished,
    this.questions,
    this.firstJuz,
    this.lastJuz,
    this.firstSurah,
    this.lastSurah,
    this.difficulty,
  });

  String? id;
  String? groupId;
  String? creatingUserId;
  int? expiryDate;
  List<String>? usersFinished;
  List<Question>? questions;
  int? firstJuz;
  int? lastJuz;
  int? firstSurah;
  int? lastSurah;
  int? difficulty;

  factory MemorizationChallenge.fromJson(Map<String, dynamic> json) =>
      MemorizationChallenge(
        id: json["id"],
        groupId: json["groupId"],
        creatingUserId: json["creatingUserId"],
        expiryDate: json["expiryDate"],
        usersFinished: List<String>.from(json["usersFinished"].map((x) => x)),
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
        firstJuz: json["firstJuz"],
        lastJuz: json["lastJuz"],
        firstSurah: json["firstSurah"],
        lastSurah: json["lastSurah"],
        difficulty: json["difficulty"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "creatingUserId": creatingUserId,
        "expiryDate": expiryDate,
        "usersFinished": List<String>.from(usersFinished ?? [].map((x) => x)),
        "questions": List<dynamic>.from(questions ?? [].map((x) => x.toJson())),
        "firstJuz": firstJuz,
        "lastJuz": lastJuz,
        "firstSurah": firstSurah,
        "lastSurah": lastSurah,
        "difficulty": difficulty,
      };

  String getName() {
    return "اختبار حفظ قرآن";
  }

  bool done() {
    for (Question question in questions ?? []) {
      if (question.finished == null || !question.finished!) {
        return false;
      }
    }
    return true;
  }
}

class Question {
  Question({
    this.number,
    this.juz,
    this.ayah,
    this.surah,
    this.firstAyahInRub,
    this.firstAyahInJuz,
    this.wrongPreviousAyahOptions,
    this.wrongNextAyahOptions,
    this.wrongFirstAyahInRubOptions,
    this.wrongFirstAyahInJuzOptions,
    this.wrongSurahOptions,
    this.finished,
  });

  int? number;
  // ALL ONE-BASED
  int? juz;
  int? ayah;
  int? surah;
  int? firstAyahInRub;
  int? firstAyahInJuz;
  List<int>? wrongPreviousAyahOptions;
  List<int>? wrongNextAyahOptions;
  List<int>? wrongFirstAyahInRubOptions;
  List<int>? wrongFirstAyahInJuzOptions;
  List<int>? wrongSurahOptions;
  bool? finished;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        number: json["number"],
        juz: json["juz"],
        ayah: json["ayah"],
        surah: json["surah"],
        firstAyahInRub: json["firstAyahInRub"],
        firstAyahInJuz: json["firstAyahInJuz"],
        wrongPreviousAyahOptions:
            List<int>.from(json["wrongPreviousAyahOptions"].map((x) => x)),
        wrongNextAyahOptions:
            List<int>.from(json["wrongNextAyahOptions"].map((x) => x)),
        wrongFirstAyahInRubOptions:
            List<int>.from(json["wrongFirstAyahInRubOptions"].map((x) => x)),
        wrongFirstAyahInJuzOptions:
            List<int>.from(json["wrongFirstAyahInJuzOptions"].map((x) => x)),
        wrongSurahOptions:
            List<int>.from(json["wrongSurahOptions"].map((x) => x)),
        finished: json["finished"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "juz": juz,
        "ayah": ayah,
        "surah": surah,
        "firstAyahInRub": firstAyahInRub,
        "firstAyahInJuz": firstAyahInJuz,
        "wrongPreviousAyahOptions":
            List<dynamic>.from(wrongPreviousAyahOptions ?? [].map((x) => x)),
        "wrongNextAyahOptions":
            List<dynamic>.from(wrongNextAyahOptions ?? [].map((x) => x)),
        "wrongFirstAyahInRubOptions":
            List<dynamic>.from(wrongFirstAyahInRubOptions ?? [].map((x) => x)),
        "wrongFirstAyahInJuzOptions":
            List<dynamic>.from(wrongFirstAyahInJuzOptions ?? [].map((x) => x)),
        "wrongSurahOptions":
            List<dynamic>.from(wrongSurahOptions ?? [].map((x) => x)),
        "finished": finished,
      };
}
