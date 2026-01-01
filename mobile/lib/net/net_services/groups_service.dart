import 'dart:convert';

import 'package:azkar/models/group.dart';
import 'package:azkar/net/api_caller.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/groups/responses/get_group_response.dart';
import 'package:azkar/net/api_interface/groups/responses/get_groups_response.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupsService {
  Future<Group> getGroup(String groupId) async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_GROUP, pathVariables: [groupId]));
    var response = GetGroupResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.group!;
  }

  Future<List<Group>> getGroups() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_GROUPS.toString();

    if (prefs.containsKey(key)) {
      return GetGroupsResponse.fromJson(jsonDecode(prefs.getString(key)!))
          .groups!;
    }

    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(endpointRoute: EndpointRoute.GET_GROUPS));
    var responseBody = utf8.decode(httpResponse.bodyBytes);
    var response = GetGroupsResponse.fromJson(jsonDecode(responseBody));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    prefs.setString(key, responseBody);
    return response.groups!;
  }
}
