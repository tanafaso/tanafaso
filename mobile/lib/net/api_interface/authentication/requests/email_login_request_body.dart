
import '../../request_base.dart';

class EmailLoginRequestBody extends RequestBodyBase {
  final String email;
  final String password;

  EmailLoginRequestBody({required this.email, required this.password});

  @override
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
