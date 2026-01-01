import 'package:azkar/net/api_interface/response_base.dart';

class FinishMeaningChallengeResponse extends ResponseBase {
  static FinishMeaningChallengeResponse fromJson(Map<String, dynamic> json) {
    FinishMeaningChallengeResponse response =
        new FinishMeaningChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    return response;
  }
}
