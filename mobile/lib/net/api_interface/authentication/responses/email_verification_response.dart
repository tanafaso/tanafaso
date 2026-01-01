import '../../response_base.dart';

class EmailVerificationResponse extends ResponseBase {
  static EmailVerificationResponse fromJson(Map<String, dynamic> json) {
    EmailVerificationResponse response = new EmailVerificationResponse();
    response.setError(json);
    return response;
  }
}
