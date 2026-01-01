import 'package:azkar/net/api_interface/status.dart';

class ApiException implements Exception {
  Status errorStatus;

  ApiException(this.errorStatus);

  static ApiException withDefaultError() {
    return new ApiException(Status.getDefaultApiErrorStatus());
  }
}
