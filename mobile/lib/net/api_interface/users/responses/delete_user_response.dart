import 'package:azkar/models/user.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class DeleteUserResponse extends ResponseBase {
  User? user;

  static DeleteUserResponse fromJson(Map<String, dynamic> json) {
    DeleteUserResponse response = new DeleteUserResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }

    response.user = User.fromJson(json['data']);
    return response;
  }
}
