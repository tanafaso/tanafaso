import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/authentication/requests/email_registration_request_body.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/auth/login/login_screen.dart';
import 'package:azkar/views/keys.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class SignUpMainScreen extends StatefulWidget {
  @override
  _SignUpMainScreenState createState() {
    _SignUpMainScreenState state = new _SignUpMainScreenState();
    return state;
  }
}

class _SignUpMainScreenState extends State<SignUpMainScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  late String _firstName;
  late String _lastName;
  late String _email;
  late String _password;
  late bool _passwordObscure = true;
  late bool _repeatedPasswordObscure = true;
  late FocusNode lastNameFocus;
  late FocusNode emailFocus;
  late FocusNode passwordFocus;
  late FocusNode repeatedPasswordFocus;
  late String _confirmedPassword;
  late String _errorMessage;
  late ButtonState progressButtonState;

  @override
  void initState() {
    super.initState();

    lastNameFocus = new FocusNode();
    emailFocus = new FocusNode();
    passwordFocus = new FocusNode();
    repeatedPasswordFocus = new FocusNode();
    _firstName = "";
    _lastName = "";
    _email = "";
    _password = "";
    _confirmedPassword = "";
    _errorMessage = "";
    progressButtonState = ButtonState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: Keys.signUpMainScreen,
        appBar: AppBar(
          title: Text("إنشاء حساب"),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Form(
          key: _signUpFormKey,
          child: new Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 4 * 8.0)),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: new Text(
                              AppLocalizations.of(context).firstName,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 10.0),
                      alignment: Alignment.center,
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              autofocus: true,
                              showCursor: true,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                focusedBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                              ),
                              onChanged: (name) => _firstName = name,
                              onEditingComplete: () =>
                                  lastNameFocus.requestFocus(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 24.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: new Text(
                              AppLocalizations.of(context).lastName,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 10.0),
                      alignment: Alignment.center,
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              focusNode: lastNameFocus,
                              showCursor: true,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                focusedBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                              ),
                              onChanged: (name) => _lastName = name,
                              onEditingComplete: () =>
                                  emailFocus.requestFocus(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 24.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: new Text(
                              AppLocalizations.of(context).email,
                              style: TextStyle(
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 10.0),
                      alignment: Alignment.center,
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              textAlign: TextAlign.left,
                              focusNode: emailFocus,
                              showCursor: true,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                focusedBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                border: InputBorder.none,
                                hintText: 'email@example.com',
                              ),
                              onChanged: (email) => _email = email.trim(),
                              onEditingComplete: () =>
                                  passwordFocus.requestFocus(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 24.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: new Text(
                            AppLocalizations.of(context).password,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                        Expanded(child: Padding(padding: EdgeInsets.all(0))),
                        GestureDetector(
                          onTap: () {
                            setState(
                                () => _passwordObscure = !_passwordObscure);
                          },
                          child: const Padding(
                              padding: const EdgeInsets.only(left: 8 * 3.0),
                              child: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.grey,
                                size: 30,
                              )),
                        ),
                      ],
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 10.0),
                      alignment: Alignment.center,
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              obscureText: _passwordObscure,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              showCursor: true,
                              cursorColor: Colors.black,
                              focusNode: passwordFocus,
                              decoration: InputDecoration(
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                focusedBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (password) => _password = password.trim(),
                              onEditingComplete: () =>
                                  repeatedPasswordFocus.requestFocus(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 24.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: new Text(
                            AppLocalizations.of(context).confirmPassword,
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(0),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _repeatedPasswordObscure =
                                !_repeatedPasswordObscure);
                          },
                          child: const Padding(
                              padding: const EdgeInsets.only(left: 8 * 3.0),
                              child: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.grey,
                                size: 30,
                              )),
                        ),
                      ],
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 10.0),
                      alignment: Alignment.center,
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              obscureText: _repeatedPasswordObscure,
                              focusNode: repeatedPasswordFocus,
                              showCursor: true,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                              onChanged: (password) =>
                                  _confirmedPassword = password,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                                focusedBorder: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 24.0,
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Row(
                            children: [
                              new Text(
                                AppLocalizations.of(context)
                                    .alreadyHaveAnAccount,
                                style: TextStyle(fontSize: 14.0),
                                textAlign: TextAlign.end,
                              ),
                              const SizedBox(width: 8),
                              // ignore: deprecated_member_use
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              new LoginScreen()));
                                },
                                child: Text(
                                  AppLocalizations.of(context).login,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 8)),
                    Visibility(
                      visible: _errorMessage.length > 0,
                      maintainSize: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 15),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 16.0, bottom: 10),
                      alignment: Alignment.center,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            // ignore: deprecated_member_use
                            child: getProgressButton(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ))),
      ),
    );
  }

  void performSignUp() async {
    try {
      await ServiceProvider.authenticationService
          .signUp(new EmailRegistrationRequestBody(
        email: _email,
        password: _password,
        firstName: _firstName,
        lastName: _lastName,
      ));

      SnackBarUtils.showSnackBar(
        context,
        'لقد أرسلنا لك رسالة بريد إلكتروني للتحقق. يرجى التحقق من البريد الوارد الخاص بك.',
        color: Colors.green.shade400,
        duration: Duration(seconds: 4),
      );

      setState(() {
        progressButtonState = ButtonState.success;
      });
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      setState(() {
        progressButtonState = ButtonState.fail;
      });
    }
  }

  Widget getProgressButton() {
    return ProgressButton.icon(
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 25,
      ),
      iconedButtons: {
        ButtonState.idle: IconedButton(
            text: AppLocalizations.of(context).signUp,
            icon: Icon(Icons.login, color: Colors.black),
            color: Theme.of(context).buttonTheme.colorScheme!.primary),
        ButtonState.loading: IconedButton(
            text: AppLocalizations.of(context).sending,
            color: Colors.yellow.shade200),
        ButtonState.fail: IconedButton(
            text: AppLocalizations.of(context).failed,
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: AppLocalizations.of(context).login,
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      },
      onPressed: onProgressButtonClicked,
      state: progressButtonState,
    );
  }

  void onProgressButtonClicked() {
    switch (progressButtonState) {
      case ButtonState.idle:
        setState(() {
          progressButtonState = ButtonState.loading;
        });

        _errorMessage = "";
        validateRegistrationInfo();
        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()));
        break;
      case ButtonState.fail:
        progressButtonState = ButtonState.idle;
        break;
    }
    setState(() {
      progressButtonState = progressButtonState;
    });
  }

  void validateRegistrationInfo() {
    if (_firstName.length < 2) {
      setState(() {
        progressButtonState = ButtonState.fail;
        _errorMessage =
            AppLocalizations.of(context).nameShouldBeOfAtLeast2Letters;
      });
      return;
    }
    if (_lastName.length < 2) {
      setState(() {
        progressButtonState = ButtonState.fail;
        _errorMessage =
            AppLocalizations.of(context).nameShouldBeOfAtLeast2Letters;
      });
      return;
    }

    RegExp regex = new RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (regex.stringMatch(_email) != _email) {
      setState(() {
        progressButtonState = ButtonState.fail;
        _errorMessage = AppLocalizations.of(context).emailIsInvalid;
      });
      return;
    }

    if (_password.length < 8) {
      setState(() {
        progressButtonState = ButtonState.fail;
        _errorMessage =
            AppLocalizations.of(context).passwordShouldBeOfAtLeast8Characters;
      });
      return;
    }

    if (_confirmedPassword != _password) {
      setState(() {
        progressButtonState = ButtonState.fail;
        _errorMessage = AppLocalizations.of(context).passwordsDidNotMatch;
      });
      return;
    }

    performSignUp();
  }
}
