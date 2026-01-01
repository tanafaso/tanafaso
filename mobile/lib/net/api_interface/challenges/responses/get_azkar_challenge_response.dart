import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetAzkarChallengeResponse extends ResponseBase {
  AzkarChallenge? challenge;

  static GetAzkarChallengeResponse fromJson(Map<String, dynamic> json) {
    GetAzkarChallengeResponse response = new GetAzkarChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = AzkarChallenge.fromJson(json['data']);
    return response;
  }
}
