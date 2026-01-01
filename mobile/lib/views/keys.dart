import 'package:flutter/material.dart';

/// Holds widgets keys.
class Keys {
  // Keys for widgets used in auth_main_screen.dart
  static final GlobalKey authMainScreenSignUpText =
      new GlobalKey(debugLabel: 'authMainScreenSignUpText');
  static final GlobalKey authMainScreenSignUpButton =
      new GlobalKey(debugLabel: 'authMainScreenSignUpButton');
  static final GlobalKey authMainScreenLoginText =
      new GlobalKey(debugLabel: 'authMainScreenLoginText');
  static final GlobalKey authMainScreenLoginButton =
      new GlobalKey(debugLabel: 'authMainScreenLoginButton');
  static final GlobalKey authMainScreenFacebookText =
      new GlobalKey(debugLabel: 'authMainScreenFacebookText');
  static final GlobalKey authMainScreenFacebookButton =
      new GlobalKey(debugLabel: 'authMainScreenFacebookButton');

  // Keys for widgets used in sign_up_main_screen.dart
  static final GlobalKey signUpMainScreen =
      new GlobalKey(debugLabel: 'signUpMainScreen');

  // Keys for widgets used in login_screen.dart
  static final GlobalKey<ScaffoldState> loginScreen =
      GlobalKey(debugLabel: 'loginScreen');

  // Keys for widgets used in all_friends_widget.dart
  static final GlobalKey allFriendsWidgetListKey =
      new GlobalKey(debugLabel: 'allFriendsWidgetListKey');

  // Keys for widgets used in all_challenges_widget.dart
  static final GlobalKey allChallengesWidgetNoChallengesFoundKey =
      new GlobalKey(debugLabel: 'allChallengesWidgetNoChallengesFoundKey');
  static final GlobalKey allChallengesWidgetListKey =
      new GlobalKey(debugLabel: 'allChallengesWidgetListKey');
}
