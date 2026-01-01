import 'package:azkar/models/challenge.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetChallengesResponse extends ResponseBase {
  List<Challenge>? challenges;

  GetChallengesResponse({this.challenges});

  static GetChallengesResponse fromJson(Map<String, dynamic> json) {
    GetChallengesResponse response = new GetChallengesResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenges = [];
    for (var jsonChallenge in json['data']) {
      response.challenges!.add(Challenge.fromJson(jsonChallenge));
    }
    return response;
  }

  Map<String, dynamic> toJson() =>
      {'data': List<dynamic>.from(challenges ?? [].map((x) => x.toJson()))};
}
