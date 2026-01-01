import 'package:azkar/net/api_interface/response_base.dart';

class AddFriendResponse extends ResponseBase {
  static AddFriendResponse fromJson(Map<String, dynamic> json) {
    AddFriendResponse response = new AddFriendResponse();
    response.setError(json);
    return response;
  }
}
