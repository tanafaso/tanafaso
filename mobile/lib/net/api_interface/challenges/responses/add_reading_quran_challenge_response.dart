import 'package:azkar/models/reading_quran_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class AddReadingQuranChallengeResponse extends ResponseBase {
  ReadingQuranChallenge? challenge;

  static AddReadingQuranChallengeResponse fromJson(Map<String, dynamic> json) {
    AddReadingQuranChallengeResponse response =
        new AddReadingQuranChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = ReadingQuranChallenge.fromJson(json['data']);
    return response;
  }
}
