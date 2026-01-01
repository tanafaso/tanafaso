import '../../response_base.dart';

class UpdateAzkarChallengeResponse extends ResponseBase {
  static UpdateAzkarChallengeResponse fromJson(Map<String, dynamic> json) {
    UpdateAzkarChallengeResponse response = new UpdateAzkarChallengeResponse();
    response.setError(json);
    return response;
  }
}
