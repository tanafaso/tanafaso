import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class AddAzkarChallengeResponse extends ResponseBase {
  AzkarChallenge? challenge;

  static AddAzkarChallengeResponse fromJson(Map<String, dynamic> json) {
    AddAzkarChallengeResponse response = new AddAzkarChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = AzkarChallenge.fromJson(json['data']);
    return response;
  }
}
