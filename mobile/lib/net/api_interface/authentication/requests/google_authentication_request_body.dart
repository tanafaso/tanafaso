
import '../../request_base.dart';

class GoogleAuthenticationRequestBody extends RequestBodyBase {
  final String googleIdToken;

  GoogleAuthenticationRequestBody({
    required this.googleIdToken,
  });

  @override
  Map<String, dynamic> toJson() => {'googleIdToken': googleIdToken};
}
