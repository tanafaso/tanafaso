import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/users/requests/set_notifications_token_request_body.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/features.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/friends/friends_main_screen.dart';
import 'package:azkar/views/core_views/home/home_main_screen.dart';
import 'package:azkar/views/core_views/profile/profile_main_screen.dart';
import 'package:azkar/views/core_views/settings/settings_main_screen.dart';
import 'package:azkar/views/core_views/support/support_screen.dart';
import 'package:clear_all_notifications/clear_all_notifications.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Topic {
  BottomNavigationBarItem bottomNavigationBarItem;
  TopicType topicType;

  Topic({required this.bottomNavigationBarItem, required this.topicType});
}

enum TopicType {
  CHALLENGES,
  FRIENDS,
  PROFILE,
  LIVE_SUPPORT,
  SETTINGS,
}

class LayoutOrganizer extends StatefulWidget {
  final TopicType initiallySelectedTopicType;

  LayoutOrganizer({this.initiallySelectedTopicType = TopicType.CHALLENGES});

  @override
  _LayoutOrganizerState createState() => _LayoutOrganizerState();
}

class _LayoutOrganizerState extends State<LayoutOrganizer>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late String userToken;
  late int _selectedIdx;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ClearAllNotifications.clear();
      ServiceProvider.localNotificationsService
          .configureNextNudgeNotification();
      setState(() {
        ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
      });
    }
  }

  Future<void> getUserToken() async {
    userToken = (await FlutterSecureStorage().read(key: 'jwtToken'))!;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  void sendTokenToDatabase(String token) async {
    try {
      // Send the token to the server.
      await ServiceProvider.usersService.setNotificationsToken(
          SetNotificationsTokenRequestBody(token: token));
    } on ApiException catch (_) {
      SnackBarUtils.showSnackBar(
        context,
        AppLocalizations.of(context)
            .anErrorHappenedWhileSettingUpThisDeviceToReceiveNotifications,
      );

      return;
    }
  }

  initFirebase() async {
    // Get the token each time the application loads.
    String? token = await FirebaseMessaging.instance.getToken();

    print(token);
    // Send initial token to database.
    sendTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(sendTokenToDatabase);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
    });
  }

  @override
  void initState() {
    _selectedIdx = topicToIndex(widget.initiallySelectedTopicType);

    // Clears all active notifications.
    ClearAllNotifications.clear();
    initFirebase();
    ServiceProvider.localNotificationsService.configureNextNudgeNotification();

    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Topic> topics = getTopics(context);
    return FutureBuilder(
      future: getUserToken(),
      builder: (context, AsyncSnapshot snapshot) {
        return Scaffold(
            body: Center(
              child: getWidgetForTopicType(topics[_selectedIdx].topicType),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              items: topics.map((e) => e.bottomNavigationBarItem).toList(),
              selectedItemColor: Colors.green,
              type: BottomNavigationBarType.shifting,
              unselectedItemColor: Colors.black,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              currentIndex: _selectedIdx,
              onTap: _onItemTapped,
              unselectedFontSize: 18,
              selectedFontSize: 20,
              iconSize: 30,
              selectedIconTheme: IconThemeData(size: 35),
            ));
      },
    );
  }

  // ignore: missing_return
  int topicToIndex(TopicType topicType) {
    switch (topicType) {
      case TopicType.LIVE_SUPPORT:
        return 0;
      case TopicType.FRIENDS:
        return 1;
      case TopicType.CHALLENGES:
        return 2;
      case TopicType.PROFILE:
        return 3;
      case TopicType.SETTINGS:
        return 4;
    }
    assert(false);
  }

  List<Topic> getTopics(BuildContext context) {
    return [
      Topic(
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: getFeatureDiscoveryWith(
              mainWidget: Icon(Icons.help_outline),
              featureId: Features.LIVE_SUPPORT_SCREEN,
              iconData: Icons.help_outline,
              title: "صفحة الاستعلامات",
              body:
                  "يمكنك استخدام هذا الزر للانتقال إلى صفحة الاستفسارات حيث يمكنك طرح أي سؤال علينا أو اقتراح إضافة شيء جديد إلى التطبيق وسنقوم بالرد في أقرب وقت ممكن ان شاء الله.",
            ),
            label: "استفسار",
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          topicType: TopicType.LIVE_SUPPORT),
      Topic(
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: getFeatureDiscoveryWith(
              mainWidget: Icon(Icons.contacts_outlined),
              featureId: Features.FRIENDS_SCREEN,
              iconData: Icons.contacts,
              title: "صفحة الأصدقاء",
              body:
                  "يمكنك استخدام هذا الزر للانتقال إلى صفحة الأصدقاء حيث يمكنك رؤية لوحة النتائج بينك وبين كل صديق. يمكنك أيضًا إضافة أصدقاء جدد من هناك.",
            ),
            label: AppLocalizations.of(context).friends,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          topicType: TopicType.FRIENDS),
      Topic(
          bottomNavigationBarItem: BottomNavigationBarItem(
              icon: getFeatureDiscoveryWith(
                mainWidget: Icon(Icons.whatshot_outlined),
                featureId: Features.CHALLENGES_SCREEN,
                iconData: Icons.whatshot_outlined,
                title: "صفحة التحديات",
                body:
                    "يمكنك استخدام هذا الزر للانتقال إلى صفحة التحديات حيث يمكنك رؤية قائمة التحديات التي تم إنشاؤها بينك وبين أصدقائك ويمكنك أيضًا إنشاء التحديات أو نسخها أو حذفها من هناك.",
              ),
              label: AppLocalizations.of(context).theChallenges,
              backgroundColor: Theme.of(context).colorScheme.primary),
          topicType: TopicType.CHALLENGES),
      Topic(
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: getFeatureDiscoveryWith(
              mainWidget: Icon(Icons.account_circle_outlined),
              featureId: Features.PROFILE_SCREEN,
              iconData: Icons.account_circle_outlined,
              title: "الصفحة الشخصية",
              body:
                  "يمكنك استخدام هذا الزر للانتقال إلى صفحة الملف الشخصي حيث يمكنك العثور على اسم المستخدم الخاص بك ونسخه ومشاركته مع الآخرين حتى يتمكنوا من إرسال طلبات صداقة إليك.",
            ),
            label: 'الملف',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          topicType: TopicType.PROFILE),
      Topic(
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: getFeatureDiscoveryWith(
              mainWidget: Icon(Icons.settings_outlined),
              featureId: Features.SETTING_SCREEN,
              iconData: Icons.settings_outlined,
              title: "صفحة الإعدادات",
              body: "يمكنك استخدام هذا الزر للانتقال إلى صفحة الإعدادات.",
            ),
            label: "الإعدادات",
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          topicType: TopicType.SETTINGS),
    ];
  }

  // ignore: missing_return
  Widget getWidgetForTopicType(TopicType topicType) {
    switch (topicType) {
      case TopicType.CHALLENGES:
        return HomeMainScreen();
      case TopicType.FRIENDS:
        return FriendsMainScreen();
      case TopicType.PROFILE:
        return ProfileMainScreen();
      case TopicType.LIVE_SUPPORT:
        return SupportScreen();
      case TopicType.SETTINGS:
        return SettingsMainScreen();
    }
    assert(false);
  }

  Widget getFeatureDiscoveryWith({
    required Widget mainWidget,
    required String featureId,
    required IconData iconData,
    required String title,
    required String body,
  }) {
    return DescribedFeatureOverlay(
      key: Key(featureId),
      featureId: featureId,
      barrierDismissible: false,
      backgroundDismissible: false,
      contentLocation: ContentLocation.above,
      tapTarget: Icon(
        iconData,
        size: 30,
      ),
      // The widget that will be displayed as the tap target.
      description: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    child: Text(
                      title,
                      maxLines: 1,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(8)),
            Row(
              children: [
                Expanded(
                  child: Text(body,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      )),
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      targetColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.black,
      overflowMode: OverflowMode.wrapBackground,
      child: mainWidget,
    );
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }
}
