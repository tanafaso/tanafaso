import 'dart:io' show Platform;


enum EndpointRoute {
  BASE_URL,
  GET_HOME,
  LOGIN_WITH_APPLE,
  LOGIN_WITH_FACEBOOK,
  LOGIN_WITH_GOOGLE,
  CONNECT_FACEBOOK,
  REGISTER_WITH_EMAIL_V2,
  LOGIN_WITH_EMAIL,
  RESET_PASSWORD,
  GET_CATEGORIES,
  GET_CURRENT_USER_PROFILE,
  GET_SABEQ,
  GET_USER_BY_ID,
  GET_USER_BY_USERNAME,
  GET_USER_BY_FACEBOOK_USER_ID,
  DELETE_CURRENT_USER,
  GET_PUBLICLY_AVAILABLE_USERS,
  GET_PUBLICLY_AVAILABLE_USERS_WITH_PAGE,
  DELETE_FROM_PUBLICLY_AVAILABLE_USERS,
  ADD_TO_PUBLICLY_AVAILABLE_MALES,
  ADD_TO_PUBLICLY_AVAILABLE_FEMALES,
  SET_NOTIFICATIONS_TOKEN,
  ADD_FRIEND,
  DELETE_FRIEND,
  GET_FRIENDS,
  GET_FRIENDS_LEADERBOARD,
  ACCEPT_FRIEND,
  REJECT_FRIEND,
  ADD_GROUP,
  GET_GROUP,
  GET_GROUPS,
  ADD_GROUP_CHALLENGE,
  ADD_AZKAR_CHALLENGE,
  ADD_MEANING_CHALLENGE,
  ADD_READING_QURAN_CHALLENGE,
  ADD_MEMORIZATION_CHALLENGE,
  ADD_CUSTOM_SIMPLE_CHALLENGE,
  FINISH_MEANING_CHALLENGE,
  FINISH_READING_QURAN_CHALLENGE,
  FINISH_CUSTOM_SIMPLE_CHALLENGE,
  FINISH_GLOBAL_CHALLENGE,
  GET_ALL_CHALLENGES,
  GET_ALL_CHALLENGES_IN_GROUP,
  GET_AZKAR_CHALLENGE,
  GET_GLOBAL_CHALLENGE,
  DELETE_CHALLENGE,
  DELETE_PERSONAL_CHALLENGE,
  GET_ORIGINAL_CHALLENGE,
  UPDATE_AZKAR_CHALLENGE,
  FINISH_MEMORIZATION_CHALLENGE_QUESTION,
  UPDATE_PERSONAL_CHALLENGE,
  GET_PERSONAL_CHALLENGES,
  GET_FINISHED_CHALLENGES_COUNT,
}

class Endpoint {
  final EndpointRoute endpointRoute;
  List<String> pathVariables = List.empty();
  Map<String, String> requestParams = Map<String, String>();

  Endpoint(
      {required this.endpointRoute,
      this.pathVariables = const [],
      this.requestParams = const {}});
}

class ApiRoutesUtil {
  static String apiRouteToString(Endpoint route) {
    switch (route.endpointRoute) {
      case EndpointRoute.BASE_URL:
        if (Platform.isAndroid) {
          // Use the following for testing locally.
          // return '10.0.2.2:8080';
          return 'tanafaso-3cituzoyra-ew.a.run.app';
        }
        if (Platform.isIOS) {
          // Use your computer's private IP as the following example.
          // return '192.168.2.102:8080';
          return 'tanafaso-3cituzoyra-ew.a.run.app';
        }
        assert(false);
        return "";
      case EndpointRoute.GET_HOME:
        return '/apiHome';
      case EndpointRoute.LOGIN_WITH_APPLE:
        return '/login/apple';
      case EndpointRoute.LOGIN_WITH_FACEBOOK:
        return '/login/facebook';
      case EndpointRoute.LOGIN_WITH_GOOGLE:
        return '/login/google';
      case EndpointRoute.CONNECT_FACEBOOK:
        return '/connect/facebook';
      case EndpointRoute.REGISTER_WITH_EMAIL_V2:
        return '/register/email/v2';
      case EndpointRoute.LOGIN_WITH_EMAIL:
        return '/login/email';
      case EndpointRoute.RESET_PASSWORD:
        return '/reset_password';
      case EndpointRoute.GET_CATEGORIES:
        return '/categories';
      case EndpointRoute.GET_CURRENT_USER_PROFILE:
        return 'users/me/v2';
      case EndpointRoute.DELETE_CURRENT_USER:
        return 'users/me';
      case EndpointRoute.GET_SABEQ:
        return 'users/sabeq';
      case EndpointRoute.GET_USER_BY_ID:
        assert(route.pathVariables.length == 1);
        return 'users/${route.pathVariables[0]}';
      case EndpointRoute.GET_USER_BY_USERNAME:
        assert(route.requestParams.length == 1);
        assert(route.requestParams.keys.first == 'username');
        return '/users/search';
      case EndpointRoute.GET_USER_BY_FACEBOOK_USER_ID:
        assert(route.requestParams.length == 1);
        assert(route.requestParams.keys.first == 'facebook_user_id');
        return '/users/search';
      case EndpointRoute.ADD_TO_PUBLICLY_AVAILABLE_MALES:
        return '/users/publicly_available_males';
      case EndpointRoute.ADD_TO_PUBLICLY_AVAILABLE_FEMALES:
        return '/users/publicly_available_females';
      case EndpointRoute.GET_PUBLICLY_AVAILABLE_USERS:
        return '/users/publicly_available_users';
      case EndpointRoute.GET_PUBLICLY_AVAILABLE_USERS_WITH_PAGE:
        assert(route.requestParams.length == 1);
        assert(route.requestParams.keys.first == 'page_num');
        return '/users/publicly_available_users';
      case EndpointRoute.DELETE_FROM_PUBLICLY_AVAILABLE_USERS:
        return '/users/publicly_available_users';
      case EndpointRoute.SET_NOTIFICATIONS_TOKEN:
        return '/users/notifications/token';
      case EndpointRoute.ADD_FRIEND:
        assert(route.pathVariables.length == 1);
        return '/friends/${route.pathVariables[0]}';
      case EndpointRoute.DELETE_FRIEND:
        assert(route.pathVariables.length == 1);
        return '/friends/${route.pathVariables[0]}';
      case EndpointRoute.GET_FRIENDS:
        return '/friends';
      case EndpointRoute.GET_FRIENDS_LEADERBOARD:
        return '/friends/leaderboard/v2';
      case EndpointRoute.ACCEPT_FRIEND:
        assert(route.pathVariables.length == 1);
        return '/friends/${route.pathVariables[0]}/accept';
      case EndpointRoute.REJECT_FRIEND:
        assert(route.pathVariables.length == 1);
        return '/friends/${route.pathVariables[0]}/reject';
      case EndpointRoute.ADD_GROUP:
        return '/groups';
      case EndpointRoute.GET_GROUP:
        assert(route.pathVariables.length == 1);
        return '/groups/${route.pathVariables[0]}';
      case EndpointRoute.GET_GROUPS:
        return '/groups';
      case EndpointRoute.ADD_GROUP_CHALLENGE:
        return '/challenges';
      case EndpointRoute.ADD_AZKAR_CHALLENGE:
        return '/challenges/friends';
      case EndpointRoute.ADD_MEANING_CHALLENGE:
        return '/challenges/meaning';
      case EndpointRoute.ADD_READING_QURAN_CHALLENGE:
        return '/challenges/reading_quran';
      case EndpointRoute.ADD_MEMORIZATION_CHALLENGE:
        return '/challenges/memorization';
      case EndpointRoute.ADD_CUSTOM_SIMPLE_CHALLENGE:
        return '/challenges/simple';
      case EndpointRoute.FINISH_MEANING_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/finish/meaning/${route.pathVariables[0]}/';
      case EndpointRoute.FINISH_READING_QURAN_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/finish/reading_quran/${route.pathVariables[0]}/';
      case EndpointRoute.FINISH_CUSTOM_SIMPLE_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/finish/simple/${route.pathVariables[0]}/';
      case EndpointRoute.FINISH_GLOBAL_CHALLENGE:
        return '/challenges/finish/global/';
      case EndpointRoute.GET_ALL_CHALLENGES:
        return '/challenges/v2';
      case EndpointRoute.GET_ALL_CHALLENGES_IN_GROUP:
        assert(route.pathVariables.length == 1);
        return '/challenges/groups/${route.pathVariables[0]}/';
      case EndpointRoute.GET_AZKAR_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/${route.pathVariables[0]}';
      case EndpointRoute.GET_GLOBAL_CHALLENGE:
        return '/challenges/global';
      case EndpointRoute.DELETE_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/${route.pathVariables[0]}';
      case EndpointRoute.DELETE_PERSONAL_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/personal/${route.pathVariables[0]}';
      case EndpointRoute.GET_ORIGINAL_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/original/${route.pathVariables[0]}';
      case EndpointRoute.UPDATE_AZKAR_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/${route.pathVariables[0]}';
      case EndpointRoute.FINISH_MEMORIZATION_CHALLENGE_QUESTION:
        assert(route.pathVariables.length == 2);
        return '/challenges/finish/memorization/${route.pathVariables[0]}/${route.pathVariables[1]}';
      case EndpointRoute.UPDATE_PERSONAL_CHALLENGE:
        assert(route.pathVariables.length == 1);
        return '/challenges/personal/${route.pathVariables[0]}';
      case EndpointRoute.GET_PERSONAL_CHALLENGES:
        return '/challenges/personal';
      case EndpointRoute.GET_FINISHED_CHALLENGES_COUNT:
        return '/challenges/finished-challenges-count';
      default:
        print('Route enum is not registered.');
        return "";
    }
  }
}
