import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/net/api_interface/request_base.dart';

class AddAzkarChallengeRequestBody extends RequestBodyBase {
  AzkarChallenge challenge;
  List<String> friendsIds;

  AddAzkarChallengeRequestBody({
    required this.challenge,
    required this.friendsIds,
  });

  @override
  Map<String, dynamic> toJson() => {
        'challenge': challenge.toJson(),
        'friendsIds': friendsIds,
      };
}
