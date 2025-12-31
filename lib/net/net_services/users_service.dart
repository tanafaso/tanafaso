import 'dart:convert';

import 'package:azkar/models/friend.dart';
import 'package:azkar/models/publicly_available_user.dart';
import 'package:azkar/models/user.dart';
import 'package:azkar/net/api_caller.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/users/requests/set_notifications_token_request_body.dart';
import 'package:azkar/net/api_interface/users/responses/add_friend_response.dart';
import 'package:azkar/net/api_interface/users/responses/add_to_publicly_available_users_response.dart';
import 'package:azkar/net/api_interface/users/responses/delete_friend_response.dart';
import 'package:azkar/net/api_interface/users/responses/delete_from_publicly_available_users_response.dart';
import 'package:azkar/net/api_interface/users/responses/delete_user_response.dart';
import 'package:azkar/net/api_interface/users/responses/get_friends_leaderboard_response.dart';
import 'package:azkar/net/api_interface/users/responses/get_publicly_available_users_response.dart';
import 'package:azkar/net/api_interface/users/responses/get_user_response.dart';
import 'package:azkar/net/api_interface/users/responses/resolve_friend_request_response.dart';
import 'package:azkar/net/api_interface/users/responses/set_notifications_token_response.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class UsersService {
  static final Lock getUserByIdLock = new Lock();
  static final Lock getCurrentUserLock = new Lock();

  // ignore: missing_return
  Future<User> getCurrentUser() async {
    late User result;
    await getCurrentUserLock.synchronized(() async {
      SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
      String key = CacheManager.CACHE_KEY_CURRENT_USER.toString();

      if (prefs.containsKey(key)) {
        result =
            GetUserResponse.fromJson(jsonDecode(prefs.getString(key)!)).user!;
        return;
      }

      http.Response httpResponse = await ApiCaller.get(
          route:
              Endpoint(endpointRoute: EndpointRoute.GET_CURRENT_USER_PROFILE));
      var responseBody = utf8.decode(httpResponse.bodyBytes);
      var response = GetUserResponse.fromJson(jsonDecode(responseBody));
      if (response.hasError()) {
        throw new ApiException(response.error!);
      }

      prefs.setString(key, responseBody);
      result = response.user!;
    });
    return result;
  }

  Future<User> deleteCurrentUser() async {
    http.Response httpResponse = await ApiCaller.delete(
        route: Endpoint(endpointRoute: EndpointRoute.DELETE_CURRENT_USER));
    var responseBody = utf8.decode(httpResponse.bodyBytes);
    var response = DeleteUserResponse.fromJson(jsonDecode(responseBody));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    return response.user!;
  }

  // Either returns the current user's ID or throws an ApiException.
  Future<String> getCurrentUserId() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_CURRENT_USER_ID.toString();
    if (prefs.containsKey(key)) {
      return prefs.getString(key)!;
    }
    User user = await getCurrentUser();
    await cacheCurrentUserDetails(user);
    return user.id;
  }

  // Either returns the current user's name or throws an ApiException.
  Future<String> getCurrentUserFullName() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_CURRENT_USER_FULL_NAME.toString();
    if (prefs.containsKey(key)) {
      return prefs.getString(key)!;
    }
    User user = await getCurrentUser();
    await cacheCurrentUserDetails(user);
    return user.firstName + " " + (user.lastName ?? "");
  }

  // Either returns the current user's email or throws an ApiException.
  Future<String> getCurrentUserEmail() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_CURRENT_USER_EMAIL.toString();
    if (prefs.containsKey(key)) {
      return prefs.getString(key)!;
    }
    User user = await getCurrentUser();
    await cacheCurrentUserDetails(user);
    return user.email!;
  }

  Future<void> cacheCurrentUserDetails(User user) async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    prefs.setString(CacheManager.CACHE_KEY_CURRENT_USER_ID, user.id);
    prefs.setString(CacheManager.CACHE_KEY_CURRENT_USER_EMAIL, user.email!);
    prefs.setString(CacheManager.CACHE_KEY_CURRENT_USER_FULL_NAME,
        user.firstName + " " + (user.lastName ?? ""));
  }

  Future<String> getSabeqId() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_SABEQ.toString();
    if (prefs.containsKey(key)) {
      return prefs.getString(key)!;
    }
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(endpointRoute: EndpointRoute.GET_SABEQ));
    GetUserResponse response;
    try {
      response = GetUserResponse.fromJson(
          jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    } on FormatException {
      // Server returned non-JSON response (e.g., timeout message)
      throw ApiException.withDefaultError();
    }
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    prefs.setString(key, response.user!.id);
    return response.user!.id;
  }

  Future<User> getUserById(String id) async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_USER_BY_ID, pathVariables: [id]));
    var response = GetUserResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.user!;
  }

  // ignore: missing_return
  Future<String> getUserFullNameById(String id) async {
    String fullName = "";
    await getUserByIdLock.synchronized(() async {
      SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
      String key = CacheManager.CACHE_KEY_USER_FULL_NAME_PREFIX.toString() + id;
      if (prefs.containsKey(key)) {
        fullName = prefs.getString(key)!;
        return;
      }
      User user = await getUserById(id);
      fullName = user.firstName + " " + (user.lastName ?? "");
      prefs.setString(key, fullName);
    });
    return fullName;
  }

  Future<User> getUserByUsername(String username) async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_USER_BY_USERNAME,
            requestParams: {'username': username}));
    var response = GetUserResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.user!;
  }

  Future<User> getUserByFacebookUserId(String facebookUserId) async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_USER_BY_FACEBOOK_USER_ID,
            requestParams: {'facebook_user_id': facebookUserId}));
    var response = GetUserResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.user!;
  }

  Future<List<PubliclyAvailableUser>> getPubliclyAvailableUsers() async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_PUBLICLY_AVAILABLE_USERS));
    var response = GetPubliclyAvailableUsersResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.publiclyAvailableUsers!;
  }

  Future<List<PubliclyAvailableUser>> getPubliclyAvailableUsersWithPage(
      int pageNum) async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_PUBLICLY_AVAILABLE_USERS_WITH_PAGE,
            requestParams: {'page_num': pageNum.toString()}));
    var response = GetPubliclyAvailableUsersResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.publiclyAvailableUsers!;
  }

  Future<void> deleteFromPubliclyAvailableUsers() async {
    http.Response httpResponse = await ApiCaller.delete(
        route: Endpoint(
            endpointRoute: EndpointRoute.DELETE_FROM_PUBLICLY_AVAILABLE_USERS));
    var response = DeleteFromPubliclyAvailableUsersResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addToPubliclyAvailableMales() async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.ADD_TO_PUBLICLY_AVAILABLE_MALES));
    var response = AddToPubliclyAvailableUsersResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addToPubliclyAvailableFemales() async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.ADD_TO_PUBLICLY_AVAILABLE_FEMALES));
    var response = AddToPubliclyAvailableUsersResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addFriendWithUsername(String username) async {
    User user = await getUserByUsername(username);

    String userId = user.id;
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.ADD_FRIEND, pathVariables: [userId]));
    var response = AddFriendResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addFriendWithId(String userId) async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.ADD_FRIEND, pathVariables: [userId]));
    var response = AddFriendResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> deleteFriend(String id) async {
    http.Response httpResponse = await ApiCaller.delete(
        route: Endpoint(
            endpointRoute: EndpointRoute.DELETE_FRIEND, pathVariables: [id]));

    var response = DeleteFriendResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));

    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
  }

  Future<List<Friend>> getFriendsLeaderboard() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_FRIENDS_LEADERBOARD.toString();

    if (prefs.containsKey(key)) {
      return GetFriendsLeaderboardResponse.fromJson(
              jsonDecode(prefs.getString(key)!))
          .friends!;
    }

    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(endpointRoute: EndpointRoute.GET_FRIENDS_LEADERBOARD));
    var responseBody = utf8.decode(httpResponse.bodyBytes);
    var response =
        GetFriendsLeaderboardResponse.fromJson(jsonDecode(responseBody));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    prefs.setString(key, responseBody);
    return response.friends!;
  }

  Future<void> acceptFriend(String friendId) async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.ACCEPT_FRIEND,
            pathVariables: [friendId]));
    var response = ResolveFriendRequestResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
  }

  Future<void> rejectFriend(String friendId) async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.REJECT_FRIEND,
            pathVariables: [friendId]));
    var response = ResolveFriendRequestResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
  }

  Future<void> setNotificationsToken(
      SetNotificationsTokenRequestBody requestBody) async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(endpointRoute: EndpointRoute.SET_NOTIFICATIONS_TOKEN),
        requestBody: requestBody);
    var response = SetNotificationsTokenResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }
}
