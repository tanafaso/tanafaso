import 'dart:convert';

import 'package:azkar/net/api_caller.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/challenges/responses/get_challenges_response.dart';
import 'package:azkar/net/api_interface/groups/responses/get_groups_response.dart';
import 'package:azkar/net/api_interface/home/get_home_response.dart';
import 'package:azkar/net/api_interface/users/responses/get_friends_leaderboard_response.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class HomeService {
  static final Lock lock = new Lock();

  Future<void> getHomeDataAndCacheIt() async {
    await lock.synchronized(() async {
      SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
      String challengesKey = CacheManager.CACHE_KEY_CHALLENGES.toString();
      String groupsKey = CacheManager.CACHE_KEY_GROUPS.toString();
      String friendsKey = CacheManager.CACHE_KEY_FRIENDS_LEADERBOARD.toString();

      // The three keys are invalidated together, so if only one of them
      // exists then no need to send a new request and return immediately.
      if (prefs.containsKey(challengesKey)) {
        return Future.value();
      }

      http.Response httpResponse = await ApiCaller.get(
          route: Endpoint(endpointRoute: EndpointRoute.GET_HOME));

      // Use bodyBytes instead of body.codeUnits to properly decode UTF-8 response
      String responseBody = utf8.decode(httpResponse.bodyBytes);
      var response = GetHomeResponse.fromJson(jsonDecode(responseBody));

      if (response.hasError()) {
        print(
            'GET_HOME API returned error: ${response.error!.code} - ${response.error!.errorMessage}');
        throw new ApiException(response.error!);
      }

      var challengesResponse =
          GetChallengesResponse(challenges: response.challenges);
      var groupsResponse = GetGroupsResponse(groups: response.groups);
      var friendsResponse =
          GetFriendsLeaderboardResponse(friends: response.friends);

      prefs.setString(challengesKey, jsonEncode(challengesResponse.toJson()));
      prefs.setString(groupsKey, jsonEncode(groupsResponse.toJson()));
      prefs.setString(friendsKey, jsonEncode(friendsResponse.toJson()));
    });
    return Future.value();
  }
}
