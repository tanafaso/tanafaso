import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/friends/add_friend/find_friends/find_friends_screen.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _friendUsername;
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            AppLocalizations.of(context).inviteFriends,
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Container(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 8, top: 8.0),
                                child: Icon(
                                  Icons.drive_file_rename_outline,
                                  size: 25,
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(right: 8)),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AutoSizeText(
                                  AppLocalizations.of(context).enterAUsername,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                  maxFontSize: 25,
                                  minFontSize: 2,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 4 / 5,
                              child: AutoSizeText(
                                AppLocalizations.of(context)
                                    .yourFriendCanFindHisUserCodeOnHisProfilePage,
                                textAlign: TextAlign.right,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: new TextFormField(
                              decoration: new InputDecoration(
                                contentPadding: EdgeInsets.all(16),
                                hintStyle: TextStyle(color: Colors.grey),
                                // hintText: AppLocalizations.of(context).enterAUsername,
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
                              showCursor: true,
                              cursorColor: Colors.black,
                              onChanged: (String username) {
                                _friendUsername = username;
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .usernameShouldNotBeEmpty;
                                }
                                if (val.contains(" ")) {
                                  return AppLocalizations.of(context)
                                      .usernameShouldHaveNoSpaces;
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          Align(
                            child: buildTextWithIcon(),
                            alignment: Alignment.center,
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.search_sharp,
                                        size: 25,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 8)),
                                      FittedBox(
                                        child: Text(
                                          "ابحث عن أصدقاء",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          4 /
                                          5,
                                      child: AutoSizeText(
                                        "ابحث عن المستخدمين الذين قبلوا إضافتهم إلى قائمة مرئية للآخرين وأرسل لهم طلبات صداقة.",
                                        textAlign: TextAlign.right,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(padding: EdgeInsets.only(top: 8)),
                                  ProgressButton.icon(
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    iconedButtons: {
                                      ButtonState.idle: IconedButton(
                                          text: "ابحث",
                                          icon: Icon(Icons.search,
                                              color: Colors.black),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      ButtonState.success: IconedButton(
                                          text: "ابحث",
                                          icon: Icon(Icons.search,
                                              color: Colors.black),
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .primary),
                                      ButtonState.loading: IconedButton(
                                          text: "ابحث",
                                          icon: Icon(Icons.search,
                                              color: Colors.black),
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .primary),
                                      ButtonState.fail: IconedButton(
                                          text: "ابحث",
                                          icon: Icon(Icons.search,
                                              color: Colors.black),
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .primary),
                                    },
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                FindFriendsScreen()),
                                      );
                                    },
                                    state: ButtonState.idle,
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 8)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextWithIcon() {
    return ProgressButton.icon(
      textStyle: TextStyle(
        color: Colors.black,
      ),
      iconedButtons: {
        ButtonState.idle: IconedButton(
            text: AppLocalizations.of(context).invite,
            icon: Icon(Icons.add, color: Colors.black),
            color: Theme.of(context).colorScheme.primary),
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
      onPressed: onPressedIconWithText,
      state: stateTextWithIcon,
    );
  }

  void onPressedIconWithText() {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        if (_formKey.currentState == null ||
            !_formKey.currentState!.validate()) {
          break;
        }

        setState(() {
          stateTextWithIcon = ButtonState.loading;
        });

        addFriend();
        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(() {
      stateTextWithIcon = stateTextWithIcon;
    });
  }

  void addFriend() async {
    try {
      await ServiceProvider.usersService.addFriendWithUsername(_friendUsername);
    } on ApiException catch (e) {
      setState(() {
        stateTextWithIcon = ButtonState.fail;
      });
      SnackBarUtils.showSnackBar(
        context,
        '${AppLocalizations.of(context).error}: ${e.errorStatus.errorMessage}',
      );
      return;
    }

    setState(() {
      stateTextWithIcon = ButtonState.success;
    });

    SnackBarUtils.showSnackBar(
      context,
      '${AppLocalizations.of(context).anInvitationHasBeenSentTo} $_friendUsername',
    );
  }
}
