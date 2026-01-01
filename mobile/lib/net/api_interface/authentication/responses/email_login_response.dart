import '../../response_base.dart';

class EmailLoginResponse extends ResponseBase {
  static EmailLoginResponse fromJson(Map<String, dynamic> json) {
    EmailLoginResponse response = new EmailLoginResponse();
    response.setError(json);
    return response;
  }
}
