import 'package:azkar/models/publicly_available_user.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetPubliclyAvailableUsersResponse extends ResponseBase {
  List<PubliclyAvailableUser>? publiclyAvailableUsers;

  static GetPubliclyAvailableUsersResponse fromJson(Map<String, dynamic> json) {
    GetPubliclyAvailableUsersResponse response =
        new GetPubliclyAvailableUsersResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }

    response.publiclyAvailableUsers = [];
    for (var data in json["data"]) {
      response.publiclyAvailableUsers!
          .add(PubliclyAvailableUser.fromJson(data));
    }
    return response;
  }
}
