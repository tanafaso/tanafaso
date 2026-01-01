import 'package:azkar/net/api_interface/response_base.dart';

class FinishMemorizationChallengeResponse extends ResponseBase {
  static FinishMemorizationChallengeResponse fromJson(
      Map<String, dynamic> json) {
    FinishMemorizationChallengeResponse response =
        new FinishMemorizationChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    return response;
  }
}
