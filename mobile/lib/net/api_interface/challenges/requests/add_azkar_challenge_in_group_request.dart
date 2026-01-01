import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/net/api_interface/request_base.dart';

class AddAzkarChallengeInGroupRequest extends RequestBodyBase {
  AzkarChallenge challenge;

  AddAzkarChallengeInGroupRequest({required this.challenge});

  @override
  Map<String, dynamic> toJson() => {'challenge': challenge.toJson()};
}
