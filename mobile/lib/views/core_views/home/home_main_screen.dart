import 'dart:io';

import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/features.dart';
import 'package:azkar/views/core_views/home/all_challenges/all_challenges_widget.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_challenge_screen.dart';
import 'package:azkar/views/core_views/home/user_progress/user_progress_widget.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeMainScreen extends StatefulWidget {

  @override
  _HomeMainScreenState createState() => _HomeMainScreenState();
}

typedef ReloadHomeMainScreenCallback = void Function();

class _HomeMainScreenState extends State<HomeMainScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) async {
      FeatureDiscovery.discoverFeatures(
        context,
        // Feature ids for every feature that we want to showcase in order.
        [
          Features.ADD_CHALLENGE,
          Features.GLOBAL_CHALLENGE,
          Features.CLONE_AND_DELETE,
          Features.CHALLENGES_SCREEN,
          Features.FRIENDS_SCREEN,
          Features.PROFILE_SCREEN,
          Features.LIVE_SUPPORT_SCREEN,
          Features.SETTING_SCREEN,
          Features.SABEQ_INTRODUCTION,
          Features.ADD_FRIEND,
          Features.SHARE_USERNAME,
        ],
      );

      SharedPreferences sharedPreferences =
          await ServiceProvider.cacheManager.getPrefs();
      if (Platform.isAndroid &&
          !sharedPreferences
              .containsKey(CacheManager.CACHE_KEY_ASKED_FOR_NOTIFICATIONS_PERMISSION)) {
        await Permission.notification.request();

        await sharedPreferences.setBool(
            CacheManager.CACHE_KEY_ASKED_FOR_NOTIFICATIONS_PERMISSION, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
          children: [
            UserProgressWidget(),
            Flexible(
              child: AllChallengesWidget(
                reloadHomeMainScreenCallback: () {
                  setState(() {});
                },
              ),
            ),
          ],
        )),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DescribedFeatureOverlay(
                key: Key(Features.ADD_CHALLENGE),
                featureId: Features.ADD_CHALLENGE,
                barrierDismissible: false,
                backgroundDismissible: false,
                contentLocation: ContentLocation.above,
                tapTarget: Icon(
                  Icons.create,
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
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "أضف تحدي",
                                maxLines: 1,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'اضغط هذا الزر لتحدي صديق أو لتحدي صديقك الافتراضي سابق.',
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                targetColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.black,
                overflowMode: OverflowMode.wrapBackground,
                child: FloatingActionButton.extended(
                    heroTag: "addFloatingButton",
                    label: Icon(
                      Icons.create,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateChallengeScreen()));
                    }),
              )
            ]));
  }
}
