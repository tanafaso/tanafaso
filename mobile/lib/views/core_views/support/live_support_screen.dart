import 'dart:convert';

import 'package:azkar/net/api_caller.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:crisp/crisp.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class LiveSupportScreen extends StatefulWidget {
  @override
  _LiveSupportScreenState createState() => _LiveSupportScreenState();
}

class _LiveSupportScreenState extends State<LiveSupportScreen>
    with SingleTickerProviderStateMixin {
  late CrispMain crispMain;

  AnimationController? _loadingAnimationController;

  @override
  void initState() {
    super.initState();

    _loadingAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _loadingAnimationController!.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String _userId = await ServiceProvider.usersService.getCurrentUserId();
      String _userFullName =
          await ServiceProvider.usersService.getCurrentUserFullName();
      String _userEmail =
          await ServiceProvider.usersService.getCurrentUserEmail();

      crispMain = CrispMain(
        websiteId: '49ccee9e-e5a5-4319-bd8d-f5eb37df0f0b',
        userToken: sha512.convert(utf8.encode(_userId)).toString(),
      );

      crispMain.register(
        user: CrispUser(
          nickname: _userFullName,
          email: _userEmail,
        ),
      );

      crispMain.setSessionData({
        "app_version": ApiCaller.API_VERSION,
      });

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return crispMain == null
        ? SafeArea(
            child: Center(
              child: RotationTransition(
                child: Image.asset('assets/images/logo.png'),
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_loadingAnimationController!),
              ),
            ),
          )
        : SafeArea(
            child: CrispView(
              crispMain: crispMain,
            ),
          );
  }

  @override
  void dispose() {
    _loadingAnimationController!.dispose();
    super.dispose();
  }
}
