import 'package:azkar/net/api_interface/request_base.dart';

class AddMemorizationChallengeRequestBody extends RequestBodyBase {
  List<String>? friendsIds;
  int? expiryDate;
  int? difficulty;
  int? firstJuz;
  int? lastJuz;
  int? firstSurah;
  int? lastSurah;
  int? numberOfQuestions;

  AddMemorizationChallengeRequestBody({
    required this.friendsIds,
    required this.expiryDate,
    required this.difficulty,
    required this.numberOfQuestions,
    this.firstJuz,
    this.lastJuz,
    this.firstSurah,
    this.lastSurah,
  });

  @override
  Map<String, dynamic> toJson() => {
        'friendsIds': friendsIds,
        'expiryDate': expiryDate,
        'difficulty': difficulty,
        'firstJuz': firstJuz,
        'lastJuz': lastJuz,
        'firstSurah': firstSurah,
        'lastSurah': lastSurah,
        'numberOfQuestions': numberOfQuestions,
      };
}
