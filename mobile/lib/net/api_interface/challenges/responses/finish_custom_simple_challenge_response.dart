import 'package:azkar/net/api_interface/response_base.dart';

class FinishCustomSimpleChallengeResponse extends ResponseBase {
  static FinishCustomSimpleChallengeResponse fromJson(
      Map<String, dynamic> json) {
    FinishCustomSimpleChallengeResponse response =
        new FinishCustomSimpleChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    return response;
  }
}
