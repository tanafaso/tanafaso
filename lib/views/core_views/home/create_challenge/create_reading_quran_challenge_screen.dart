import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/reading_quran_challenge.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_reading_quran_challenge_request_body.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_friend/selected_friends_widget.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_surahs/selected_surahs_widget.dart';
import 'package:azkar/views/core_views/layout_organizer.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class CreateReadingQuranChallengeScreen extends StatefulWidget {
  final List<Friend> initiallySelectedFriends;
  final List<SurahSubChallenge> initiallySelectedSurahSubChallenges;

  CreateReadingQuranChallengeScreen({
    this.initiallySelectedFriends = const [],
    this.initiallySelectedSurahSubChallenges = const [],
  });

  @override
  _CreateReadingQuranChallengeScreenState createState() =>
      _CreateReadingQuranChallengeScreenState();
}

class _CreateReadingQuranChallengeScreenState
    extends State<CreateReadingQuranChallengeScreen> {
  late List<Friend> _selectedFriends;
  late List<SurahSubChallenge> _selectedSurahSubChallenges;
  late ButtonState progressButtonState;
  late int _expiresAfterHoursNum;

  @override
  void initState() {
    _selectedFriends = widget.initiallySelectedFriends;
    _selectedSurahSubChallenges = widget.initiallySelectedSurahSubChallenges;
    progressButtonState = ButtonState.idle;
    _expiresAfterHoursNum = 24;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'قراءة قرآن',
          style: TextStyle(fontSize: 30),
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      children: [
                        SelectedFriendsWidget(
                          initiallySelectedFriends:
                              widget.initiallySelectedFriends,
                          onSelectedFriendsChanged: (newFriends) {
                            setState(() {
                              _selectedFriends = newFriends;
                            });
                          },
                        ),
                        SelectedSurahsWidget(
                          initiallySelectedSurahs: _selectedSurahSubChallenges,
                          onSelectedSurahsChanged: (newSurahSubChallenges) {
                            setState(() {
                              _selectedSurahSubChallenges =
                                  newSurahSubChallenges;
                            });
                          },
                        ),
                        Card(
                          child: Column(
                            children: [
                              Row(
                                children: [
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
                                    child: Icon(Icons.date_range),
                                  ),
                                  AutoSizeText(
                                    AppLocalizations.of(context).deadline,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AutoSizeText.rich(TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: new TextStyle(
                                          color: Colors.black, fontSize: 20),
                                      children: <TextSpan>[
                                        new TextSpan(
                                          text: 'التحدي ينتهي بعد',
                                        ),
                                        new TextSpan(
                                            text:
                                                '  ${ArabicUtils.englishToArabic(_expiresAfterHoursNum.toString())}  ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            )),
                                        new TextSpan(
                                          text: 'ساعات.',
                                        ),
                                      ],
                                    )),
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
        // ignore: deprecated_member_use
        child: ElevatedButton(
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

    try {
      await ServiceProvider.challengesService.addReadingQuranChallenge(
          AddReadingQuranChallengeRequestBody(
              friendsIds:
                  _selectedFriends.map((friend) => friend.userId).toList(),
              readingQuranChallenge: ReadingQuranChallenge(
                expiryDate: DateTime.now().millisecondsSinceEpoch ~/ 1000 +
                    Duration.secondsPerHour * _expiresAfterHoursNum,
                surahSubChallenges: _selectedSurahSubChallenges,
              )));
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
    if ((_selectedSurahSubChallenges.length ?? 0) == 0) {
      return false;
    }

    return true;
  }
}
