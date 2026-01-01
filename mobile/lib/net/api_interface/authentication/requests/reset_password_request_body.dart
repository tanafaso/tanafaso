
import '../../request_base.dart';

class ResetPasswordRequestBody extends RequestBodyBase {
  final String email;

  ResetPasswordRequestBody({required this.email});

  @override
  Map<String, dynamic> toJson() => {'email': email};
}
