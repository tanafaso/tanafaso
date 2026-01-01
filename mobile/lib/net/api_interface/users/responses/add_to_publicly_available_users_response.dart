import 'package:azkar/net/api_interface/response_base.dart';

class AddToPubliclyAvailableUsersResponse extends ResponseBase {
  static AddToPubliclyAvailableUsersResponse fromJson(
      Map<String, dynamic> json) {
    AddToPubliclyAvailableUsersResponse response =
        new AddToPubliclyAvailableUsersResponse();
    response.setError(json);
    return response;
  }
}
