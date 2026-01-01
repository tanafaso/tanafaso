import '../../response_base.dart';

class GoogleAuthenticationResponse extends ResponseBase {
  static GoogleAuthenticationResponse fromJson(Map<String, dynamic> json) {
    GoogleAuthenticationResponse response = new GoogleAuthenticationResponse();
    response.setError(json);
    return response;
  }
}
