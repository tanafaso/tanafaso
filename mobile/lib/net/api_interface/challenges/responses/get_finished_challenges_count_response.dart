import 'package:azkar/net/api_interface/response_base.dart';

class GetFinishedChallengesCountResponse extends ResponseBase {
  int? finishedChallengesCount;

  static GetFinishedChallengesCountResponse fromJson(
      Map<String, dynamic> json) {
    GetFinishedChallengesCountResponse response =
        new GetFinishedChallengesCountResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.finishedChallengesCount = json['data'];
    return response;
  }
}
