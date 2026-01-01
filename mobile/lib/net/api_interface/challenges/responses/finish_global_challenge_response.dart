import 'package:azkar/net/api_interface/response_base.dart';

class FinishGlobalChallengeResponse extends ResponseBase {
  static FinishGlobalChallengeResponse fromJson(
      Map<String, dynamic> json) {
    FinishGlobalChallengeResponse response =
        new FinishGlobalChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    return response;
  }
}
