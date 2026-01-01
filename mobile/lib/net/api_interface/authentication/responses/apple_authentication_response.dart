import '../../response_base.dart';

class AppleAuthenticationResponse extends ResponseBase {
  static AppleAuthenticationResponse fromJson(Map<String, dynamic> json) {
    AppleAuthenticationResponse response = new AppleAuthenticationResponse();
    response.setError(json);
    return response;
  }
}
