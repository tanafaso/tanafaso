import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class AddMemorizationChallengeResponse extends ResponseBase {
  MemorizationChallenge? challenge;

  static AddMemorizationChallengeResponse fromJson(Map<String, dynamic> json) {
    AddMemorizationChallengeResponse response =
        new AddMemorizationChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = MemorizationChallenge.fromJson(json['data']);
    return response;
  }
}
