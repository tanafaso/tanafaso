class Zekr {
  // This ID is preserved for Azkar created by users.
  static final int customZekrIdOffset = 10000;

  int? id;
  String? zekr;

  Zekr({this.id, this.zekr});

  factory Zekr.fromJson(Map<String, dynamic> json) {
    return Zekr(
      id: json["id"],
      zekr: json["zekr"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "zekr": zekr,
      };
}
