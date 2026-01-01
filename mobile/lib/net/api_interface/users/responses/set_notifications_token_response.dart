import 'package:azkar/net/api_interface/response_base.dart';

class SetNotificationsTokenResponse extends ResponseBase {
  SetNotificationsTokenResponse();

  static SetNotificationsTokenResponse fromJson(Map<String, dynamic> json) {
    SetNotificationsTokenResponse response =
        new SetNotificationsTokenResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    return response;
  }
}
