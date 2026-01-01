import '../../response_base.dart';

class ResetPasswordResponse extends ResponseBase {
  static ResetPasswordResponse fromJson(Map<String, dynamic> json) {
    ResetPasswordResponse response = new ResetPasswordResponse();
    response.setError(json);
    return response;
  }
}
