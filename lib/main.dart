// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:azkar/firebase_options.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/views/landing_widget.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData rootCert = await rootBundle.load('assets/gts-root-r1.crt');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(rootCert.buffer.asUint8List());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xffcef5ce),
    statusBarColor: Color(0xffcef5ce),
  ));
  if (QuranUtils.ayahs.isEmpty) {
    String quran = await rootBundle.loadString('assets/quran.txt');
    QuranUtils.ayahs = quran.split("\n");
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _landingWidget;
  late String _azkarAndQuranFontFamily;
  late String _nonAzkarAndNonQuranFontFamily;
  late FirebaseApp _firebaseApp;

  Future<void> asyncInitialization(BuildContext context) async {
    try {
      _firebaseApp = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      print(e);
    }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'challenges_and_friend_requests', // id
      'تحديات الاصدقاء وطلبات الصداقه', // title
      description:
          'اخطارات بخصوص تحديات الاصدقاء وطلبات الصداقه.', // description
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _azkarAndQuranFontFamily =
        await ServiceProvider.fontService.getPreferredAzkarAndQuranFontFamily();
    _nonAzkarAndNonQuranFontFamily = await ServiceProvider.fontService
        .getPreferredNonAzkarAndNonQuranFontFamily();
  }

  @override
  void initState() {
    super.initState();

    ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: asyncInitialization(context),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            if (_landingWidget == null) {
              _landingWidget = getMaterialAppWithBody(LandingWidget(), true);
            }
            return _landingWidget!;
          } else if (snapshot.hasError) {
            if (_landingWidget == null) {
              _landingWidget = getMaterialAppWithBody(LandingWidget(), false);
            }
            return _landingWidget!;
          } else {
            // TODO(omorsi): Show loader
            return getMaterialAppWithBody(
                Container(
                  child: Center(
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                false);
          }
        });
  }

  Widget getMaterialAppWithBody(Widget body, bool lateInitializationDone) {
    return FeatureDiscovery(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context).title,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ar', ''),
        ],
        home: Scaffold(
          body: body,
        ),
        theme: ThemeData(
          primaryColor: Color(0xffcef6ce),
          colorScheme: ColorScheme(
            primary: Color(0xffcef5ce),
            secondary: Colors.white,
            surface: Colors.white,
            error: Colors.red.shade600,
            onPrimary: Color(0xffcef5ce),
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onError: Colors.red.shade600,
            brightness: Brightness.light,
          ),
          buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
            primary: Colors.white,
          )),
          scaffoldBackgroundColor: Color(0xffcef5ce),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.white, foregroundColor: Colors.black),
          cardTheme: CardTheme(elevation: 10),
          iconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(
            displayLarge: TextStyle(
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              color: Colors.black,
            ),
            displaySmall: TextStyle(
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              color: Colors.black,
            ),
            titleMedium: TextStyle(
              color: Colors.black,
            ),
            titleSmall: TextStyle(
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              color: Colors.black,
            ),
            labelLarge: TextStyle(
              color: Colors.black,
            ),
          ),
          primaryTextTheme: TextTheme(
            displayLarge: TextStyle(
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              color: Colors.black,
            ),
            displaySmall: TextStyle(
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              color: Colors.black,
            ),
            titleMedium: TextStyle(
              color: Colors.black,
            ),
            titleSmall: TextStyle(
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              color: Colors.black,
            ),
            labelLarge: TextStyle(
              color: Colors.black,
              fontFamily:
                  lateInitializationDone ? _azkarAndQuranFontFamily : 'arabic',
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.black),
              overlayColor: WidgetStateProperty.all(Colors.black),
              side: WidgetStateProperty.all(BorderSide(color: Colors.black)),
            ),
          ),
          indicatorColor: Colors.white,
          tabBarTheme: TabBarTheme(
            labelColor: Color(0xffcef5ce),
          ),
          fontFamily: lateInitializationDone
              ? _nonAzkarAndNonQuranFontFamily
              : 'arabic',
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xffcef5ce),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontFamily: lateInitializationDone
                  ? _nonAzkarAndNonQuranFontFamily
                  : 'arabic',
            ),
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: Colors.black,
            inactiveTrackColor: Colors.grey,
            thumbColor: Colors.black,
            overlayColor: Colors.black,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20
            ),
          ),
        ),
      ),
    );
  }
}
