import 'package:azkar/models/reading_quran_challenge.dart';
import 'package:azkar/net/api_interface/request_base.dart';

class AddReadingQuranChallengeRequestBody extends RequestBodyBase {
  List<String> friendsIds;
  ReadingQuranChallenge readingQuranChallenge;

  AddReadingQuranChallengeRequestBody({
    required this.friendsIds,
    required this.readingQuranChallenge,
  });

  @override
  Map<String, dynamic> toJson() => {
        'friendsIds': friendsIds,
        'readingQuranChallenge': readingQuranChallenge.toJson(),
      };
}
