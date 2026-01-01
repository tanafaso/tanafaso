import 'package:azkar/net/api_interface/response_base.dart';

class DeleteFriendResponse extends ResponseBase {
  static DeleteFriendResponse fromJson(Map<String, dynamic> json) {
    DeleteFriendResponse response = new DeleteFriendResponse();
    response.setError(json);
    return response;
  }
}
