
import '../../request_base.dart';

class EmailRegistrationRequestBody extends RequestBodyBase {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  EmailRegistrationRequestBody({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };
}
