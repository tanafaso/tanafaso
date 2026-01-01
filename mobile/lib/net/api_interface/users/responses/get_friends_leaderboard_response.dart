import 'package:azkar/models/friend.dart';
import 'package:azkar/net/api_interface/response_base.dart';

class GetFriendsLeaderboardResponse extends ResponseBase {
  List<Friend>? friends;

  GetFriendsLeaderboardResponse({this.friends});

  static GetFriendsLeaderboardResponse fromJson(Map<String, dynamic> json) {
    GetFriendsLeaderboardResponse response =
        new GetFriendsLeaderboardResponse();
    response.setError(json);
    if (response.hasError()) {
      return response;
    }
    response.friends = [];
    for (var friendshipScore in json['data']) {
      response.friends!.add(Friend.fromJson(friendshipScore));
    }
    return response;
  }

  Map<String, dynamic> toJson() =>
      {'data': List<dynamic>.from(friends ?? [].map((x) => x.toJson()))};
}
