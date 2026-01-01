import 'dart:io';

import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/status.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/auth/login/login_screen.dart';
import 'package:azkar/views/auth/signup/signup_main_screen.dart';
import 'package:azkar/views/core_views/layout_organizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMainScreen extends StatefulWidget {
  @override
  _AuthMainScreenState createState() => _AuthMainScreenState();
}

class _AuthMainScreenState extends State<AuthMainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSigningInWithGoogle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.repeat();
      bool isSignedIn =
          await ServiceProvider.secureStorageService.userSignedIn();
      if (isSignedIn) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LayoutOrganizer()),
            (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SafeArea(
      child: new Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(8)),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Expanded(
                  child: FittedBox(
                    child: Icon(
                      Icons.directions_run,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16)),
          Expanded(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 16)),
                Text(AppLocalizations.of(context).areYouANewUser,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 4.0, right: 30.0),
                      alignment: Alignment.center,
                      // ignore: deprecated_member_use
                      child: new RawMaterialButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        fillColor: Colors.white,
                        elevation: 2,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpMainScreen()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context).yes,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Column(
                          children: <Widget>[
                            // ignore: deprecated_member_use
                            new RawMaterialButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              fillColor: Colors.white,
                              elevation: 2,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen())),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  AppLocalizations.of(context).no,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Divider(
                    color: Colors.green.shade800,
                    thickness: 2,
                    height: 2,
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: FittedBox(
                              child: googleButton(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: Platform.isIOS,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: FittedBox(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: SignInButton(
                                    Buttons.AppleDark,
                                    text: "Sign in with Apple",
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10.0)),
                                    onPressed: () {
                                      loginWithApple(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }

  Widget googleButton() {
    if (_isSigningInWithGoogle) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(AppLocalizations.of(context).signingIn,
            style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,)),
      );
    }
    if (Platform.isIOS) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SignInButton(
          Buttons.Google,
          text: "Sign in with Google",
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          onPressed: () {
            loginWithGoogle(context);
          },
        ),
      );
    }
    return SignInButton(
      Buttons.Google,
      text: "الدخول باستخدام جوجل",
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(50.0)),
      onPressed: () {
        loginWithGoogle(context);
      },
    );
  }

  loginWithGoogle(BuildContext context) async {
    setState(() {
      _isSigningInWithGoogle = true;
    });
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    String googleIdToken;
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      GoogleSignInAuthentication? authentication =
          await account!.authentication;
      googleIdToken = authentication.idToken!;
    } catch (error) {
      setState(() {
        _isSigningInWithGoogle = false;
      });
      return;
    }

    try {
      await ServiceProvider.authenticationService
          .loginWithGoogle(googleIdToken);
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      setState(() {
        _isSigningInWithGoogle = false;
      });
      return;
    }

    setState(() {
      _isSigningInWithGoogle = false;
    });
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => new LayoutOrganizer()));
  }

  void loginWithApple(BuildContext context) async {
    try {
      await ServiceProvider.authenticationService.loginWithApple();
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      return;
    } on Exception catch (e) {
      print(e);
      SnackBarUtils.showSnackBar(context,
          new Status(Status.AUTHENTICATION_WITH_APPLE_ERROR).errorMessage);
      return;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => new LayoutOrganizer()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
