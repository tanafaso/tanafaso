
import '../../request_base.dart';

class EmailVerificationRequestBody extends RequestBodyBase {
  final String email;
  final int pin;

  EmailVerificationRequestBody({required this.email, required this.pin});

  @override
  Map<String, dynamic> toJson() => {'email': email, 'pin': pin};
}
