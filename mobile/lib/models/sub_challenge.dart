import 'package:azkar/models/zekr.dart';

class SubChallenge {
  Zekr zekr;
  int repetitions;

  SubChallenge({required this.zekr, required this.repetitions});

  factory SubChallenge.fromJson(Map<String, dynamic> json) {
    Zekr zekr = Zekr.fromJson(json["zekr"]);
    return SubChallenge(
      zekr: zekr,
      repetitions: json["repetitions"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "zekr": zekr.toJson(),
      "repetitions": repetitions,
    };
  }

  bool done() {
    return repetitions == 0;
  }
}
