import 'package:azkar/net/api_interface/response_base.dart';

class FinishReadingQuranChallengeResponse extends ResponseBase {
  static FinishReadingQuranChallengeResponse fromJson(
      Map<String, dynamic> json) {
    FinishReadingQuranChallengeResponse response =
        new FinishReadingQuranChallengeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    return response;
  }
}
