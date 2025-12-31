import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  // ignore: missing_return
  String nudgeIntervalToString(RepeatInterval repeatInterval) {
    switch (repeatInterval) {
      case RepeatInterval.daily:
        return "يومياً";
      case RepeatInterval.weekly:
        return "أسبوعياً";
      case RepeatInterval.everyMinute:
      case RepeatInterval.hourly:
        assert(false);
        return "";
    }
  }

  Future<void> setNudgeInterval(RepeatInterval repeatInterval) async {
    var prefs = await ServiceProvider.cacheManager.getPrefs();
    await prefs.setInt(CacheManager.CACHE_KEY_NUDGE_NOTIFICATIONS_INTERVAL,
        repeatInterval.index);

    configureNextNudgeNotification();
  }

  Future<RepeatInterval> getCurrentNudgeInterval() async {
    var prefs = await ServiceProvider.cacheManager.getPrefs();
    var repeatIntervalIndex;
    try {
      repeatIntervalIndex =
          prefs.getInt(CacheManager.CACHE_KEY_NUDGE_NOTIFICATIONS_INTERVAL) ??
              RepeatInterval.weekly.index;
    } catch (error) {
      repeatIntervalIndex = RepeatInterval.weekly;
    }

    RepeatInterval preferred = RepeatInterval.values.firstWhere(
        (repeatIntervalValue) =>
            repeatIntervalValue.index == repeatIntervalIndex,
        orElse: () => RepeatInterval.weekly);
    return Future.value(preferred);
  }

  void configureNextNudgeNotification() async {
    var flutterLocalNotificationsPlugin =
        await _initLocalNotificationInstance();

    // Cancel all currently scheduled nudge notifications as the user
    // has already opened the app.
    flutterLocalNotificationsPlugin.cancelAll();

    const String channelId = 'التذكير';
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'nudge_channel_id',
      channelId,
      channelDescription: 'إشعارات لتذكيرك بتحدي أصدقائك 😀',
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(''),
    );
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: channelId,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    RepeatInterval preferredRepeatInterval = await getCurrentNudgeInterval();
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'تحدياتك لا غنى عنها 😊',
      'ابدأ بنفسك وكن أنت الذي يدفع عائلاته وأصدقائه إلى ذكر الله بنية طيبة, فهذا يقربك إلى الله ويوطد العلاقات بينك وبين أحبابك 🔥',
      preferredRepeatInterval,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<FlutterLocalNotificationsPlugin>
      _initLocalNotificationInstance() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/notification');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    return flutterLocalNotificationsPlugin;
  }
}
