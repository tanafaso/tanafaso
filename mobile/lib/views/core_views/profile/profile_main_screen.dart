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

  Future<void> getNeededData() async {
    isIpad = await _isIpad();

    _user = await ServiceProvider.usersService.getCurrentUser();
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
                              Row(
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _user.firstName +
                                            " " +
                                            (_user.lastName ?? ""),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 45,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 8 * 3.0)),
                              RawMaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                fillColor: Colors.white,
                                onPressed: () {},
                                // elevation: 15,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'كود المستخدم',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 35),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                _user.username,
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 8)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTapDown: (_) {
                                              Clipboard.setData(ClipboardData(
                                                text: _user.username,
                                              )).then((_) {
                                                SnackBarUtils.showSnackBar(
                                                    context,
                                                    AppLocalizations.of(context)
                                                        .usernameCopiedSuccessfully);
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.copy,
                                                  size: 25,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8)),
                                                AutoSizeText(
                                                  'نسخ الكود',
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Visibility(
                                            visible: !isIpad,
                                            child: Expanded(
                                              child: GestureDetector(
                                                onTapDown: (_) {
                                                  Share.share(
                                                      AppLocalizations.of(
                                                              context)
                                                          .shareMessage(
                                                              _user.username));
                                                },
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.share,
                                                        size: 25,
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8)),
                                                      AutoSizeText(
                                                        'مشاركة الكود مع صديق',
                                                        style: TextStyle(
                                                          fontSize: 25,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(10)),
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
                          Padding(padding: EdgeInsets.all(10)),
                          Container(
                            child: ButtonTheme(
                              height: 50,
                              // ignore: deprecated_member_use
                              child: RawMaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                fillColor: Colors.red.shade600,
                                onPressed: () async {
                                  bool deleted =
                                      await _showDeleteUserAlertDialog(
                                              context) ??
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
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AutoSizeText(
                                    "مسح الحساب",
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
