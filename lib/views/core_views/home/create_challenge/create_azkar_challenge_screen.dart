import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_azkar_challenge_in_group_request.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_azkar_challenge_request_body.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_azkar/selected_azkar_widget.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_friend/selected_friends_widget.dart';
import 'package:azkar/views/core_views/layout_organizer.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

// ignore: must_be_immutable
class CreateAzkarChallengeScreen extends StatefulWidget {
  List<Friend> initiallySelectedFriends;
  List<SubChallenge> initiallySelectedSubChallenges;
  String initiallyChosenName;
  String initiallyChosenMotivation;

  CreateAzkarChallengeScreen({
    this.initiallySelectedFriends = const [],
    this.initiallySelectedSubChallenges = const [],
    this.initiallyChosenName = "",
    this.initiallyChosenMotivation = "",
  });

  @override
  _CreateAzkarChallengeScreenState createState() =>
      _CreateAzkarChallengeScreenState();
}

class _CreateAzkarChallengeScreenState
    extends State<CreateAzkarChallengeScreen> {
  late TextEditingController _challengeNameController;
  late String _lastChallengeName = '';
  late TextEditingController _motivationController;
  late List<SubChallenge> _subChallenges;
  late bool _subChallengesValid;
  late List<Friend> _selectedFriends;
  late ButtonState progressButtonState;
  late int _expiresAfterHoursNum;
  late ScrollController pageScrollController;

  initChallengeNameController() {
    _lastChallengeName = widget.initiallyChosenName;
    _challengeNameController =
        TextEditingController(text: widget.initiallyChosenName);
    _challengeNameController.addListener(() {
      if (_lastChallengeName == _challengeNameController.value.text) {
        return;
      }
      _lastChallengeName = _challengeNameController.value.text;
      validateChallengeName(true);
      setState(() {});
    });
  }

  bool validateChallengeName(bool showWarning) {
    final String newChallengeName = _challengeNameController.value.text;
    if (newChallengeName.isEmpty) {
      if (showWarning) {
        SnackBarUtils.showSnackBar(
          context,
          AppLocalizations.of(context).nameShouldNotBeEmpty,
        );
      }
      return false;
    }
    return true;
  }

  bool validateMotivation() {
    final String motivation = _motivationController.value.text;
    // Note: Characters function is used here so as to count the actual number
    // of runes and not only the number of UTF-16 code points, because our
    // use-case with arabic language, there are some letters with tashkeel that
    // can only be represented in UTF-8 in 4 bytes.
    if (motivation.characters.length > 200) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    initChallengeNameController();
    _subChallenges = widget.initiallySelectedSubChallenges;
    _motivationController =
        TextEditingController(text: widget.initiallyChosenMotivation);
    _subChallengesValid = _subChallenges.length > 0;
    _selectedFriends = widget.initiallySelectedFriends;
    progressButtonState = ButtonState.idle;
    _expiresAfterHoursNum = 24;

    pageScrollController = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            child: Text(
          "قراءة أذكار",
          style: TextStyle(fontSize: 30),
        )),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: Center(
            child: Container(
          child: Scrollbar(
            controller: pageScrollController,
            interactive: false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      controller: pageScrollController,
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          '*',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 17),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.drive_file_rename_outline,
                                          size: 25,
                                        ),
                                      ),
                                      FittedBox(
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .challengeName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Tooltip(
                                          message: AppLocalizations.of(context)
                                              .writeANameWithWhichYouCanDistinguishTheChallenge,
                                          child: Icon(
                                            Icons.info_outline,
                                            color: Colors.grey,
                                            size: 25,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  maxLength: 20,
                                  showCursor: true,
                                  cursorColor: Colors.black,
                                  maxLines: 1,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  controller: _challengeNameController,
                                  decoration: new InputDecoration(
                                    enabledBorder: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                      borderSide:
                                          new BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(15.0),
                                      borderSide:
                                          new BorderSide(color: Colors.black),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 0.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SelectedFriendsWidget(
                          scrollController: pageScrollController,
                          initiallySelectedFriends:
                              widget.initiallySelectedFriends,
                          onSelectedFriendsChanged: (newFriends) {
                            setState(() {
                              _selectedFriends = newFriends;
                            });
                          },
                        ),
                        SelectedAzkarWidget(
                          onSelectedAzkarChangedCallback: (newSubChallenges) {
                            setState(() {
                              _subChallenges = newSubChallenges;
                            });
                          },
                          onSelectedAzkarValidityChangedCallback:
                              (subChallengesValid) {
                            setState(() {
                              _subChallengesValid = subChallengesValid;
                            });
                          },
                          initiallySelectedSubChallenges: _subChallenges,
                        ),
                        Card(
                          child: Column(
                            children: [
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    '*',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 17),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.date_range,
                                    size: 25,
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    AppLocalizations.of(context).deadline,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text.rich(
                                            TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: new TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 25),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                  text: 'التحدي ينتهي بعد',
                                                ),
                                                new TextSpan(
                                                    text:
                                                        '  ${ArabicUtils.englishToArabic(_expiresAfterHoursNum.toString())}  ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                    )),
                                                new TextSpan(
                                                  text: 'ساعات.',
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Slider(
                                value: _expiresAfterHoursNum.toDouble(),
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                inactiveColor:
                                    Theme.of(context).colorScheme.primary,
                                min: 1,
                                max: 24,
                                divisions: 24,
                                onChanged: (value) => setState(() =>
                                    _expiresAfterHoursNum = value.toInt()),
                                label: "$_expiresAfterHoursNum",
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.directions_run,
                                        size: 25,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 8)),
                                      Row(
                                        children: [
                                          FittedBox(
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .theMotivationMessage,
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8)),
                                        ],
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                      )),
                                      Tooltip(
                                        message: AppLocalizations.of(context)
                                            .writeSomethingToMotivateYourFriendToSayTheZekr,
                                        child: Icon(
                                          Icons.info_outline,
                                          color: Colors.grey,
                                          size: 25,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  maxLength: 200,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  showCursor: true,
                                  cursorColor: Colors.black,
                                  decoration: new InputDecoration(
                                    enabledBorder: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                      borderSide:
                                          new BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(15.0),
                                      borderSide:
                                          new BorderSide(color: Colors.black),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 0.0),
                                    ),
                                  ),
                                  controller: _motivationController,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 8),
                          child: !readyToFinishChallenge(false)
                              ? getNotReadyButton()
                              : getReadyButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget getNotReadyButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ButtonTheme(
        height: 50,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey),
          ),
          onPressed: () async => onCreatePressed(),
          child: Center(
              child: Text(
            AppLocalizations.of(context).addNotReady,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

  Widget getReadyButton() {
    return ProgressButton.icon(
      textStyle: TextStyle(
        color: Colors.black,
      ),
      iconedButtons: {
        ButtonState.idle: IconedButton(
            // text: AppLocalizations.of(context).add,
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 30,
            ),
            color: Colors.green.shade300),
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

        onCreatePressed();
        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        break;
      case ButtonState.fail:
        progressButtonState = ButtonState.idle;
        break;
    }
    setState(() {
      progressButtonState = progressButtonState;
    });
  }

  onCreatePressed() async {
    if (!readyToFinishChallenge(true)) {
      SnackBarUtils.showSnackBar(
        context,
        AppLocalizations.of(context).pleaseFillUpAllTheCellsProperly,
      );
      return;
    }

    bool challengingOneFriend = (_selectedFriends.length ?? 0) == 1;
    final String? groupId =
        challengingOneFriend ? _selectedFriends[0].groupId : null;

    AzkarChallenge challenge = AzkarChallenge(
      groupId: groupId,
      motivation: _motivationController.value.text,
      name: _challengeNameController.value.text,
      expiryDate: DateTime.now().millisecondsSinceEpoch ~/ 1000 +
          Duration.secondsPerHour * _expiresAfterHoursNum,
      subChallenges: _subChallenges,
    );

    try {
      if (challengingOneFriend) {
        await ServiceProvider.challengesService.addGroupChallenge(
            AddAzkarChallengeInGroupRequest(challenge: challenge));
      } else {
        await ServiceProvider.challengesService.addAzkarChallenge(
            AddAzkarChallengeRequestBody(
                challenge: challenge,
                friendsIds:
                    _selectedFriends.map((friend) => friend.userId).toList()));
      }
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(
        context,
        e.errorStatus.errorMessage,
      );
      setState(() {
        progressButtonState = ButtonState.fail;
      });
      return;
    }

    setState(() {
      progressButtonState = ButtonState.success;
    });

    SnackBarUtils.showSnackBar(
      context,
      AppLocalizations.of(context).challengeHasBeenAddedSuccessfully,
      color: Colors.green.shade400,
    );
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => LayoutOrganizer(
                  initiallySelectedTopicType: TopicType.CHALLENGES,
                )),
        (_) => false);
  }

  bool readyToFinishChallenge(bool showWarnings) {
    if ((_selectedFriends.length ?? 0) == 0) {
      return false;
    }
    if (_subChallenges.length == 0) {
      return false;
    }

    if (!validateMotivation()) {
      return false;
    }

    if (!validateChallengeName(showWarnings)) {
      return false;
    }

    if (!_subChallengesValid) {
      return false;
    }

    return true;
  }
}
