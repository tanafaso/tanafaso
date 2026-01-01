import 'package:azkar/models/meaning_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class AddMeaningChallengeResponse extends ResponseBase {
  MeaningChallenge? challenge;

  static AddMeaningChallengeResponse fromJson(Map<String, dynamic> json) {
    AddMeaningChallengeResponse response = new AddMeaningChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = MeaningChallenge.fromJson(json['data']);
    return response;
  }
}
