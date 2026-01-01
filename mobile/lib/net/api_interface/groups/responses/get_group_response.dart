import 'package:azkar/models/group.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetGroupResponse extends ResponseBase {
  Group? group;

  static GetGroupResponse fromJson(Map<String, dynamic> json) {
    GetGroupResponse response = new GetGroupResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.group = Group.fromJson(json['data']);
    return response;
  }
}
