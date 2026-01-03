import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/user.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/utils/snapshot_utils.dart';
import 'package:azkar/views/auth/auth_main_screen.dart';
import 'package:azkar/views/core_views/profile/profile_loading_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ProfileMainScreen extends StatefulWidget {
  @override
  _ProfileMainScreenState createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen> {
  late Future<void> _neededData;
  late User _user;
  late bool isIpad;
  late int _finishedChallengesCount;
  late int _consecutiveDaysStreak;

  Future<void> getNeededData() async {
    isIpad = await _isIpad();

    _user = await ServiceProvider.usersService.getCurrentUser();
    _finishedChallengesCount =
        await ServiceProvider.challengesService.getFinishedChallengesCount();
    _consecutiveDaysStreak =
        await ServiceProvider.challengesService.getConsecutiveDaysStreak();
    print(_user);
  }

  @override
  void initState() {
    super.initState();

    _neededData = getNeededData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FutureBuilder(
              future: _neededData,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    !snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 16),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                      SizedBox(height: 12),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _user.firstName +
                                              " " +
                                              (_user.lastName ?? ""),
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.badge,
                                            color: Colors.grey.shade700,
                                            size: 28,
                                          ),
                                          SizedBox(width: 8),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'كود المستخدم',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28,
                                                  color: Colors.grey.shade700),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  _user.username,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    color: Colors.grey.shade800,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                text: _user.username,
                                              )).then((_) {
                                                SnackBarUtils.showSnackBar(
                                                    context,
                                                    AppLocalizations.of(context)
                                                        .usernameCopiedSuccessfully);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.copy,
                                              size: 28,
                                            ),
                                            tooltip: 'نسخ الكود',
                                          ),
                                          if (!isIpad)
                                            IconButton(
                                              onPressed: () {
                                                Share.share(
                                                    AppLocalizations.of(context)
                                                        .shareMessage(
                                                            _user.username));
                                              },
                                              icon: Icon(
                                                Icons.share,
                                                size: 28,
                                              ),
                                              tooltip: 'مشاركة الكود مع صديق',
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.green.shade400,
                                          Colors.green.shade600
                                        ],
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.local_fire_department,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        SizedBox(height: 6),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'المواظبة',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _consecutiveDaysStreak.toString(),
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'يوم',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.amber.shade400,
                                          Colors.amber.shade700
                                        ],
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        SizedBox(height: 6),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'الإنجازات',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _finishedChallengesCount.toString(),
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'تحدي',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () async {
                                performLogout(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, size: 24),
                                  SizedBox(width: 8),
                                  AutoSizeText(
                                    AppLocalizations.of(context).logout,
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () async {
                                bool deleted =
                                    await _showDeleteUserAlertDialog(context) ??
                                        false;
                                if (deleted) {
                                  await ServiceProvider.secureStorageService
                                      .clear();
                                  await ServiceProvider.cacheManager
                                      .clearPreferences();
                                  SnackBarUtils.showSnackBar(
                                      context, "تم حذف حسابك بنجاح.");
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              new AuthMainScreen()),
                                      (_) => false);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_forever, size: 24),
                                  SizedBox(width: 8),
                                  AutoSizeText(
                                    "مسح الحساب",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(2 * 8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              SnapshotUtils.getErrorWidget(context, snapshot),
                        ),
                        Container(
                          child: ButtonTheme(
                            height: 50,
                            // ignore: deprecated_member_use
                            child: RawMaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              fillColor: Colors.grey,
                              onPressed: () async {
                                performLogout(context);
                              },
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  AppLocalizations.of(context).logout,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ProfileLoadingWidget();
                }
              }),
        ),
      ),
    );
  }

  performLogout(BuildContext context) async {
    await ServiceProvider.secureStorageService.clear();
    await ServiceProvider.secureStorageService.clear();
    await ServiceProvider.cacheManager.clearPreferences();
    SnackBarUtils.showSnackBar(
        context, AppLocalizations.of(context).youHaveLoggedOutSuccessfully);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => new AuthMainScreen()),
        (_) => false);
  }

  Future<bool?> _showDeleteUserAlertDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(' مسح الحساب 😢 '),
          content: SingleChildScrollView(
            child: Text(
                'سنفتقدك. يمكنك إرسال أي شيء تريد تحسينه إلينا على azkar.challenge@gmail.com وسننظر في العمل عليه. هل تريد حقا حذف حسابك؟ 👀'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                try {
                  await ServiceProvider.usersService.deleteCurrentUser();
                } on ApiException catch (e) {
                  SnackBarUtils.showSnackBar(
                      context, e.errorStatus.errorMessage);
                }
                Navigator.of(context).pop(/*deleted=*/ true);
              },
            ),
            TextButton(
              child: const Text(
                'لا',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(/*deleted=*/ false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isIpad() async {
    if (!Platform.isIOS) {
      return false;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if (iosInfo.model.toLowerCase().contains("ipad")) {
      return true;
    }
    return false;
  }
}
