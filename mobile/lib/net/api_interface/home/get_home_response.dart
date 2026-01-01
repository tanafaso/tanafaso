import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/group.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetHomeResponse extends ResponseBase {
  List<Challenge>? challenges;
  List<Friend>? friends;
  List<Group>? groups;

  static GetHomeResponse fromJson(Map<String, dynamic> json) {
    GetHomeResponse response = new GetHomeResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.challenges = [];
    for (var jsonChallenge in json['data']['challenges']) {
      response.challenges!.add(Challenge.fromJson(jsonChallenge));
    }
    response.friends = [];
    for (var jsonFriend in json['data']['friends']) {
      response.friends!.add(Friend.fromJson(jsonFriend));
    }
    response.groups = [];
    for (var jsonGroup in json['data']['groups']) {
      response.groups!.add(Group.fromJson(jsonGroup));
    }
    return response;
  }
}
