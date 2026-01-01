import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  // This design assumes that we will at most need to hash 1000 different
  // categories of information.
  static const String CACHE_KEY_CURRENT_USER_ID = "000";
  static const String CACHE_KEY_USER_FULL_NAME_PREFIX = "001";
  static const String CACHE_KEY_GROUP_ID_PREFIX = "002";
  static const String CACHE_KEY_ORIGINAL_CHALLENGE_PREFIX = "003";
  static const String CACHE_KEY_SABEQ = "004";
  static const String CACHE_KEY_ASKED_FOR_REVIEW = "005";
  static const String CACHE_KEY_CURRENT_USER_FULL_NAME = "006";
  static const String CACHE_KEY_CURRENT_USER_EMAIL = "007";
  static const String CACHE_KEY_CHALLENGES = "008";
  static const String CACHE_KEY_GROUPS = "009";
  static const String CACHE_KEY_FRIENDS_LEADERBOARD = "010";
  static const String CACHE_KEY_CURRENT_USER = "011";
  static const String CACHE_KEY_FRIENDS = "012";
  static const String CACHE_KEY_FINISHED_CHALLENGES_COUNT = "013";
  static const String CACHE_KEY_NUDGE_NOTIFICATIONS_INTERVAL = "014";
  static const String CACHE_KEY_AZKAR_AND_QURAN_FONT_FAMILY = "015";
  static const String CACHE_KEY_NON_AZKAR_AND_NON_QURAN_FONT_FAMILY = "016";
  // This key is true if Flutter Secure Storage deleteAll() function is
  // called once if the device is android. This is to fix the freezing
  // issue that happens after app update as per
  // https://github.com/mogol/flutter_secure_storage/issues/53#issuecomment-503297858.
  static const String CACHE_KEY_CLEARED_SECURE_STORAGE_ANDROID = "017";
  static const String CACHE_KEY_LASTLY_INCREMENTED_CONSECUTIVE_DAYS_STREAK =
      "018";
  // Saved in milliseconds since epoch
  static const String CACHE_KEY_LAST_FINISHED_CHALLENGE_DATE = "019";
  static const String CACHE_KEY_ASKED_FOR_NOTIFICATIONS_PERMISSION = "020";

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<SharedPreferences> getPrefs() async {
    return await _prefs;
  }

  // This removes all data that are cached and changes frequently like
  // challenges or friends scores. This will be called in the following
  // event types.
  // 1- In app changes that will lead to a need for reloading data (e.g.
  // adding a new challenge).
  // 2- Receiving a firebase notification.
  // 3- When starting the application.
  void invalidateFrequentlyChangingData() async {
    _prefs.then((prefs) {
      prefs.remove(CACHE_KEY_CHALLENGES);
      prefs.remove(CACHE_KEY_GROUPS);
      prefs.remove(CACHE_KEY_FRIENDS_LEADERBOARD);
      prefs.remove(CACHE_KEY_CURRENT_USER);
      prefs.remove(CACHE_KEY_FRIENDS);
      prefs.remove(CACHE_KEY_FINISHED_CHALLENGES_COUNT);
    });
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await _prefs;
    await prefs.clear();
  }
}
