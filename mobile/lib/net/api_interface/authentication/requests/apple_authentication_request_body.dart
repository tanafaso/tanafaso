
import '../../request_base.dart';

class AppleAuthenticationRequestBody extends RequestBodyBase {
  final String firstName;
  final String lastName;
  final String email;
  final String authCode;

  AppleAuthenticationRequestBody({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.authCode,
  });

  @override
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'authCode': authCode,
      };
}
