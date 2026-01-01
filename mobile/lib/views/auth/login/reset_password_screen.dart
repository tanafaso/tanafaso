import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _email;
  late ButtonState progressButtonState;

  @override
  void initState() {
    super.initState();

    progressButtonState = ButtonState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).resetPassword),
            ),
            body: Container(
                child: Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: new SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: new Container(
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0 * 3),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16)),
                                          Expanded(
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .anEmailWillBeSentToYouSoThatYouCanResetYourPassword,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                .enterYourEmailAddress,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: new TextFormField(
                                              decoration: new InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(16),
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                                // hintText: AppLocalizations.of(context).enterAUsername,
                                                enabledBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          30.0),
                                                  borderSide: new BorderSide(
                                                      color: Colors.black),
                                                ),
                                                focusedBorder:
                                                    new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          15.0),
                                                  borderSide: new BorderSide(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              onChanged: (String email) {
                                                _email = email;
                                              },
                                              validator: (email) {
                                                RegExp regex = new RegExp(
                                                    '^[\\w-_\\.+]*[\\w-_\\.]\\@'
                                                    '([\\w]+\\.)+[\\w]+[\\w]\$');
                                                if (email == null ||
                                                    regex.stringMatch(email) !=
                                                        email) {
                                                  return AppLocalizations.of(
                                                          context)
                                                      .emailIsInvalid;
                                                }
                                                return null;
                                              },
                                              keyboardType: TextInputType.text,
                                              style: new TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                          ),
                                          getProgressButton(),
                                          Padding(padding: EdgeInsets.all(8)),
                                          Visibility(
                                            visible: progressButtonState ==
                                                ButtonState.success,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding: EdgeInsets.all(8),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(Colors.green
                                                                  .shade400)),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LoginScreen()));
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .login,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))))));
  }

  Widget getProgressButton() {
    return ProgressButton.icon(
      textStyle: TextStyle(
        color: Colors.black,
      ),
      iconedButtons: {
        ButtonState.idle: IconedButton(
            text: AppLocalizations.of(context).send,
            icon: Icon(Icons.add, color: Colors.black),
            color: Theme.of(context).buttonTheme.colorScheme!.primary),
        ButtonState.loading: IconedButton(
            text: AppLocalizations.of(context).sending,
            color: Colors.yellow.shade200),
        ButtonState.fail: IconedButton(
            text: AppLocalizations.of(context).failed,
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: AppLocalizations.of(context).sent,
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      },
      onPressed: onProgressButtonPressed,
      state: progressButtonState,
    );
  }

  void onProgressButtonPressed() {
    switch (progressButtonState) {
      case ButtonState.idle:
        if (_formKey.currentState == null ||
            !_formKey.currentState!.validate()) {
          break;
        }

        setState(() {
          progressButtonState = ButtonState.loading;
        });

        resetEmail();
        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        progressButtonState = ButtonState.idle;
        break;
      case ButtonState.fail:
        progressButtonState = ButtonState.idle;
        break;
    }
    setState(() {
      progressButtonState = progressButtonState;
    });
  }

  void resetEmail() async {
    try {
      await ServiceProvider.authenticationService.resetPassword(_email);
    } on ApiException catch (e) {
      setState(() {
        progressButtonState = ButtonState.fail;
      });
      SnackBarUtils.showSnackBar(
        context,
        '${AppLocalizations.of(context).error}: ${e.errorStatus.errorMessage}',
      );
      return;
    }

    setState(() {
      progressButtonState = ButtonState.success;
    });

    SnackBarUtils.showSnackBar(
      context,
      '${AppLocalizations.of(context).anEmailHasBeenSentToYouPleaseCheckYourInbox}',
      color: Colors.green.shade400,
    );
  }
}
