import 'package:azkar/models/challenge.dart';


class GlobalChallenge {
  GlobalChallenge({
    required this.challenge,
    required this.finishedCount,
  });

  Challenge challenge;
  int finishedCount;

  factory GlobalChallenge.fromJson(Map<String, dynamic> json) =>
      GlobalChallenge(
        challenge: Challenge.fromJson(json["challenge"]),
        finishedCount: json["finishedCount"],
      );

  Map<String, dynamic> toJson() => {
        "challenge": challenge.toJson(),
        "finishedCount": finishedCount,
      };
}
