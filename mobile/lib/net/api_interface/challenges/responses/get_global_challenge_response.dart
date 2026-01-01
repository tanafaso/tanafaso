import 'package:azkar/models/global_challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetGlobalChallengeResponse extends ResponseBase {
  late GlobalChallenge challenge;

  GetGlobalChallengeResponse();

  static GetGlobalChallengeResponse fromJson(Map<String, dynamic> json) {
    GetGlobalChallengeResponse response = new GetGlobalChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenge = GlobalChallenge.fromJson(json['data']);
    return response;
  }

  Map<String, dynamic> toJson() =>
      {'data': challenge.toJson()};
}
