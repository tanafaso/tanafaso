import 'package:azkar/models/custom_simple_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class AddCustomSimpleChallengeResponse extends ResponseBase {
  CustomSimpleChallenge? challenge;

  static AddCustomSimpleChallengeResponse fromJson(Map<String, dynamic> json) {
    AddCustomSimpleChallengeResponse response =
        new AddCustomSimpleChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = CustomSimpleChallenge.fromJson(json['data']);
    return response;
  }
}
