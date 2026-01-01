import 'package:azkar/net/api_interface/response_base.dart';

class DeleteFromPubliclyAvailableUsersResponse extends ResponseBase {
  static DeleteFromPubliclyAvailableUsersResponse fromJson(
      Map<String, dynamic> json) {
    DeleteFromPubliclyAvailableUsersResponse response =
        new DeleteFromPubliclyAvailableUsersResponse();
    response.setError(json);

    return response;
  }
}
