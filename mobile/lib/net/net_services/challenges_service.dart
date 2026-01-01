import 'dart:convert';
import 'dart:math';

import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/global_challenge.dart';
import 'package:azkar/net/api_caller.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_azkar_challenge_in_group_request.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_azkar_challenge_request_body.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_custom_simple_challenge_request_body.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_meaning_challenge_request_body.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_memorization_challenge_request_body.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_reading_quran_challenge_request_body.dart';
import 'package:azkar/net/api_interface/challenges/requests/update_azkar_challenge_request_body.dart';
import 'package:azkar/net/api_interface/challenges/responses/add_azkar_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/add_meaning_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/add_memorization_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/add_reading_quran_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/add_simple_custom_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/delete_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/finish_custom_simple_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/finish_global_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/finish_meaning_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/finish_memorization_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/finish_reading_quran_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/get_azkar_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/get_challenges_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/get_finished_challenges_count_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/get_global_challenge_response.dart';
import 'package:azkar/net/api_interface/challenges/responses/update_azkar_challenge_response.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChallengesService {
  Future<void> addGroupChallenge(
      AddAzkarChallengeInGroupRequest requestBody) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.post(
        route: Endpoint(endpointRoute: EndpointRoute.ADD_GROUP_CHALLENGE),
        requestBody: requestBody);

    var response = AddAzkarChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addAzkarChallenge(
      AddAzkarChallengeRequestBody requestBody) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.post(
        route: Endpoint(endpointRoute: EndpointRoute.ADD_AZKAR_CHALLENGE),
        requestBody: requestBody);

    var response = AddAzkarChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addMeaningChallenge(
      AddMeaningChallengeRequestBody requestBody) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.post(
        route: Endpoint(endpointRoute: EndpointRoute.ADD_MEANING_CHALLENGE),
        requestBody: requestBody);

    var response = AddMeaningChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addReadingQuranChallenge(
      AddReadingQuranChallengeRequestBody requestBody) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.post(
        route:
            Endpoint(endpointRoute: EndpointRoute.ADD_READING_QURAN_CHALLENGE),
        requestBody: requestBody);

    var response = AddReadingQuranChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addMemorizationChallenge(
      AddMemorizationChallengeRequestBody requestBody) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.post(
        route:
            Endpoint(endpointRoute: EndpointRoute.ADD_MEMORIZATION_CHALLENGE),
        requestBody: requestBody);

    var response = AddMemorizationChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> addCustomSimpleChallenge(
      AddCustomSimpleChallengeRequestBody requestBody) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.post(
        route:
            Endpoint(endpointRoute: EndpointRoute.ADD_CUSTOM_SIMPLE_CHALLENGE),
        requestBody: requestBody);

    var response = AddCustomSimpleChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<void> finishMeaningChallenge(String id) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.FINISH_MEANING_CHALLENGE,
            pathVariables: [id]));

    var response = FinishMeaningChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    await _updateStreakDataAfterFinishingChallenge();
  }

  Future<void> finishReadingQuranChallenge(String id) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.FINISH_READING_QURAN_CHALLENGE,
            pathVariables: [id]));

    var response = FinishReadingQuranChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    await _updateStreakDataAfterFinishingChallenge();
  }

  Future<void> finishCustomSimpleChallenge(String id) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.FINISH_CUSTOM_SIMPLE_CHALLENGE,
            pathVariables: [id]));

    var response = FinishCustomSimpleChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    await _updateStreakDataAfterFinishingChallenge();
  }

  Future<void> finishGlobalChallenge() async {
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(endpointRoute: EndpointRoute.FINISH_GLOBAL_CHALLENGE));

    var response = FinishGlobalChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    await _updateStreakDataAfterFinishingChallenge();
  }

  Future<List<Challenge>> getAllChallenges() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_CHALLENGES.toString();

    if (prefs.containsKey(key)) {
      return GetChallengesResponse.fromJson(jsonDecode(prefs.getString(key)!))
          .challenges!;
    }

    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(endpointRoute: EndpointRoute.GET_ALL_CHALLENGES));
    String responseBody = utf8.decode(httpResponse.bodyBytes);
    var response = GetChallengesResponse.fromJson(jsonDecode(responseBody));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    prefs.setString(key, responseBody);
    return response.challenges!;
  }

  Future<AzkarChallenge> getAzkarChallenge(String challengeId) async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_AZKAR_CHALLENGE,
            pathVariables: [challengeId]));
    var response = GetAzkarChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.challenge!;
  }

  Future<GlobalChallenge> getGlobalChallenge() async {
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(endpointRoute: EndpointRoute.GET_GLOBAL_CHALLENGE));
    var response = GetGlobalChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    return response.challenge;
  }

  Future<void> deleteChallenge(String challengeId) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.delete(
        route: Endpoint(
            endpointRoute: EndpointRoute.DELETE_CHALLENGE,
            pathVariables: [challengeId]));
    var response = DeleteChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
  }

  Future<AzkarChallenge> getOriginalChallenge(String challengeId) async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_ORIGINAL_CHALLENGE_PREFIX.toString() +
        challengeId;
    if (prefs.containsKey(key)) {
      return AzkarChallenge.fromJson(json.decode(prefs.getString(key)!));
    }
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_ORIGINAL_CHALLENGE,
            pathVariables: [challengeId]));
    var response = GetAzkarChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    prefs.setString(key, json.encode(response.challenge!.toJson()));
    return response.challenge!;
  }

  Future<void> updateAzkarChallenge(AzkarChallenge challenge) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    UpdateAzkarChallengeRequestBody requestBody =
        UpdateAzkarChallengeRequestBody(challenge: challenge);
    http.Response httpResponse = await ApiCaller.put(
        route: Endpoint(
            endpointRoute: EndpointRoute.UPDATE_AZKAR_CHALLENGE,
            pathVariables: [challenge.id!]),
        requestBody: requestBody);
    var response = UpdateAzkarChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    if (challenge.done()) {
      await _updateStreakDataAfterFinishingChallenge();
    }
  }

  Future<void> finishMemorizationChallengeQuestion(
      String challengeId, int questionId) async {
    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();

    http.Response httpResponse = await ApiCaller.put(
      route: Endpoint(
          endpointRoute: EndpointRoute.FINISH_MEMORIZATION_CHALLENGE_QUESTION,
          pathVariables: [
            challengeId,
            questionId.toString(),
          ]),
    );
    var response = FinishMemorizationChallengeResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }

    await _updateStreakDataAfterFinishingChallenge();
  }

  Future<int> getFinishedChallengesCount() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String key = CacheManager.CACHE_KEY_FINISHED_CHALLENGES_COUNT.toString();
    if (prefs.containsKey(key)) {
      return prefs.getInt(key)!;
    }
    http.Response httpResponse = await ApiCaller.get(
        route: Endpoint(
            endpointRoute: EndpointRoute.GET_FINISHED_CHALLENGES_COUNT));

    var response = GetFinishedChallengesCountResponse.fromJson(
        jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    if (response.hasError()) {
      throw new ApiException(response.error!);
    }
    prefs.setInt(key, response.finishedChallengesCount!);
    return response.finishedChallengesCount!;
  }

  Future<int> getConsecutiveDaysStreak() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();

    String lastFinishedDateKey =
        CacheManager.CACHE_KEY_LAST_FINISHED_CHALLENGE_DATE;
    String daysStreaksKey =
        CacheManager.CACHE_KEY_LASTLY_INCREMENTED_CONSECUTIVE_DAYS_STREAK;
    if (!prefs.containsKey(daysStreaksKey) ||
        !prefs.containsKey(lastFinishedDateKey)) {
      // Let's never show 0 to the user :)
      return 1;
    }

    int daysDifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt(lastFinishedDateKey)!))
        .inDays;
    int daysStreakWas = prefs.getInt(daysStreaksKey)!;
    return max(1, daysStreakWas - max(0, daysDifference - 1));
  }

  Future<void> _updateStreakDataAfterFinishingChallenge() async {
    SharedPreferences prefs = await ServiceProvider.cacheManager.getPrefs();
    String lastFinishedDateKey =
        CacheManager.CACHE_KEY_LAST_FINISHED_CHALLENGE_DATE;
    String daysStreaksKey =
        CacheManager.CACHE_KEY_LASTLY_INCREMENTED_CONSECUTIVE_DAYS_STREAK;
    DateTime now = DateTime.now();

    if (!prefs.containsKey(lastFinishedDateKey)) {
      await prefs.setInt(lastFinishedDateKey, now.millisecondsSinceEpoch);
      // 2 because the least number we show users is 1 and now the user has
      // finished one challenge so they deserve more than 1.
      await prefs.setInt(daysStreaksKey, 2);
      return;
    }

    DateTime lastFinishedChallengeDate =
        DateTime.fromMillisecondsSinceEpoch(prefs.getInt(lastFinishedDateKey)!);
    bool sameDay = _isSameDay(lastFinishedChallengeDate, now);

    if (!sameDay) {
      int daysDifference = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt(lastFinishedDateKey)!))
          .inDays;
      int daysStreakWas = prefs.getInt(daysStreaksKey)!;
      await prefs.setInt(daysStreaksKey,
          max(2, 1 + daysStreakWas - max(0, daysDifference - 1)));
    }

    await prefs.setInt(
        lastFinishedDateKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool _isSameDay(DateTime time1, DateTime time2) {
    return time1.day == time2.day &&
        time1.month == time2.month &&
        time1.year == time2.year;
  }
}
