import 'package:azkar/models/user.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetUserResponse extends ResponseBase {
  User? user;

  static GetUserResponse fromJson(Map<String, dynamic> json) {
    GetUserResponse response = new GetUserResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }

    response.user = User.fromJson(json['data']);
    return response;
  }
}
