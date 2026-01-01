class MeaningChallenge {
  MeaningChallenge({
    this.id,
    this.groupId,
    this.creatingUserId,
    this.expiryDate,
    this.usersFinished,
    this.words,
    this.meanings,
    this.finished,
  });

  String? id;
  String? groupId;
  String? creatingUserId;
  int? expiryDate;
  List<String>? usersFinished;
  List<String>? words;
  List<String>? meanings;
  bool? finished;

  factory MeaningChallenge.fromJson(Map<String, dynamic> json) =>
      MeaningChallenge(
        id: json["id"],
        groupId: json["groupId"],
        creatingUserId: json["creatingUserId"],
        expiryDate: json["expiryDate"],
        usersFinished: List<String>.from(json["usersFinished"].map((x) => x)),
        words: List<String>.from(json["words"].map((x) => x)),
        meanings: List<String>.from(json["meanings"].map((x) => x)),
        finished: json["finished"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "creatingUserId": creatingUserId,
        "expiryDate": expiryDate,
        "usersFinished": List<String>.from(usersFinished ?? [].map((x) => x)),
        "words": List<String>.from(words ?? [].map((x) => x)),
        "meanings": List<String>.from(meanings ?? [].map((x) => x)),
        "finished": finished,
      };

  String getName() {
    return "تفسير القرآن";
  }
}
