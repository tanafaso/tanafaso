import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/challenges/requests/add_memorization_challenge_request_body.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_friend/selected_friends_widget.dart';
import 'package:azkar/views/core_views/layout_organizer.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class CreateMemorizationChallengeScreen extends StatefulWidget {
  final List<Friend> initiallySelectedFriends;
  final int initiallySelectedNumberOfQuestions;
  final int initiallySelectedDifficulty;
  final int initiallySelectedFirstJuz;
  final int initiallySelectedLastJuz;
  final int initiallySelectedFirstSurah;
  final int initiallySelectedLastSurah;

  CreateMemorizationChallengeScreen({
    this.initiallySelectedFriends = const [],
    this.initiallySelectedNumberOfQuestions = 1,
    this.initiallySelectedDifficulty = 1,
    this.initiallySelectedFirstJuz = 28,
    this.initiallySelectedLastJuz = 30,
    this.initiallySelectedFirstSurah = 3,
    this.initiallySelectedLastSurah = 3,
  });

  @override
  _CreateMemorizationChallengeScreenState createState() =>
      _CreateMemorizationChallengeScreenState();
}

enum Mode {
  JUZ_SELECTION,
  SURAH_SELECTION,
}

class _CreateMemorizationChallengeScreenState
    extends State<CreateMemorizationChallengeScreen> {
  late List<Friend> _selectedFriends;
  late ButtonState progressButtonState;
  late int _expiresAfterHoursNum;
  late int _numberOfQuestions;
  late int _difficulty;
  late int _firstJuz;
  late int _lastJuz;
  late int _firstSurah;
  late int _lastSurah;
  late Mode _mode;

  @override
  void initState() {
    super.initState();

    print("hereeeeee");
    print(widget.initiallySelectedFirstJuz);
    if (widget.initiallySelectedFirstJuz != 0) {
      switchToMode(Mode.JUZ_SELECTION);
    } else {
      switchToMode(Mode.SURAH_SELECTION);
    }
    _selectedFriends = widget.initiallySelectedFriends;
    progressButtonState = ButtonState.idle;
    _expiresAfterHoursNum = 24;
    _numberOfQuestions = widget.initiallySelectedNumberOfQuestions;
    _difficulty = widget.initiallySelectedDifficulty;
  }

  void switchToMode(Mode mode) {
    if (mode == Mode.JUZ_SELECTION) {
      _mode = Mode.JUZ_SELECTION;
    } else {
      _mode = Mode.SURAH_SELECTION;
    }
    _firstJuz = max(1, widget.initiallySelectedFirstJuz);
    _lastJuz = max(1, widget.initiallySelectedLastJuz);
    _firstSurah = max(2, widget.initiallySelectedFirstSurah);
    _lastSurah = max(2, widget.initiallySelectedLastSurah);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'اختبار حفظ قرآن',
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
            thickness: 5,
            thumbVisibility: true,
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
                                    child: Icon(Icons.whatshot_rounded),
                                  ),
                                  AutoSizeText(
                                    "تحديد الأختبار في",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_mode == Mode.SURAH_SELECTION) {
                                            switchToMode(Mode.JUZ_SELECTION);
                                          }
                                        });
                                      },
                                      child: Card(
                                        elevation: 2,
                                        color: _mode == Mode.JUZ_SELECTION
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        child: Text(
                                          'أجزاء',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )),
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_mode == Mode.JUZ_SELECTION) {
                                            switchToMode(Mode.SURAH_SELECTION);
                                          }
                                        });
                                      },
                                      child: Card(
                                        elevation: 2,
                                        color: _mode == Mode.SURAH_SELECTION
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        child: Text('سور',
                                            textAlign: TextAlign.center),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _mode == Mode.JUZ_SELECTION
                            ? getJuzSelectionWidget()
                            : getSurahSelectionWidget(),
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
                                    child: Icon(Icons.format_list_numbered),
                                  ),
                                  AutoSizeText(
                                    "عدد الأسئلة",
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
                                          text: 'عدد الأسئلة في التحدي: ',
                                        ),
                                        new TextSpan(
                                            text:
                                                '${ArabicUtils.englishToArabic(_numberOfQuestions.toString())}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            )),
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                              Slider(
                                value: _numberOfQuestions.toDouble(),
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                inactiveColor:
                                    Theme.of(context).colorScheme.primary,
                                min: 1,
                                max: 10,
                                divisions: 10,
                                onChanged: (value) => setState(
                                    () => _numberOfQuestions = value.toInt()),
                                label:
                                    "${ArabicUtils.englishToArabic(_numberOfQuestions.toString())}",
                              ),
                            ],
                          ),
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
                                    child: Icon(Icons.whatshot_rounded),
                                  ),
                                  AutoSizeText(
                                    "صعوبة التحدي",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: getDifficultyDescriptionWidget(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _difficulty = 1;
                                        });
                                      },
                                      child: Card(
                                        elevation: 2,
                                        color: _difficulty == 1
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        child: Text(
                                          'سهل',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )),
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _difficulty = 2;
                                        });
                                      },
                                      child: Card(
                                        elevation: 2,
                                        color: _difficulty == 2
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        child: Text('متوسط',
                                            textAlign: TextAlign.center),
                                      ),
                                    )),
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _difficulty = 3;
                                        });
                                      },
                                      child: Card(
                                        elevation: 2,
                                        color: _difficulty == 3
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        child: Text('صعب',
                                            textAlign: TextAlign.center),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget getDifficultyDescriptionWidget() {
    String description;
    if (_difficulty == 1) {
      description = '''- اسأل عن السورة
- اسأل عن الآية التالية''';
    } else if (_difficulty == 2) {
      description = '''- اسأل عن السورة
- اسأل عن الآية التالية
- اسأل عن الجزء
- إسأل عن الآية السابقة''';
    } else {
      description = '''- اسأل عن السورة
- اسأل عن الآية التالية
- اسأل عن الجزء
- إسأل عن الآية السابقة
- اسأل عن الربع''';
    }

    return Row(
      children: [
        Text(
          description,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget getNotReadyButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ButtonTheme(
        height: 50,
        // ignore: deprecated_member_use
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.grey,
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
      await ServiceProvider.challengesService
          .addMemorizationChallenge(AddMemorizationChallengeRequestBody(
        friendsIds: _selectedFriends.map((friend) => friend.userId).toList(),
        expiryDate: DateTime.now().millisecondsSinceEpoch ~/ 1000 +
            Duration.secondsPerHour * _expiresAfterHoursNum,
        difficulty: _difficulty,
        numberOfQuestions: _numberOfQuestions,
        firstJuz: _mode == Mode.JUZ_SELECTION ? _firstJuz.toInt() : 0,
        lastJuz: _mode == Mode.JUZ_SELECTION ? _lastJuz.toInt() : 0,
        firstSurah: _mode == Mode.SURAH_SELECTION ? _firstSurah.toInt() : 0,
        lastSurah: _mode == Mode.SURAH_SELECTION ? _lastSurah.toInt() : 0,
      ));
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
    if (_mode == Mode.JUZ_SELECTION) {
      if (_firstJuz > _lastJuz) {
        return false;
      }
    } else {
      if (_firstSurah > _lastSurah) {
        return false;
      }
    }
    return true;
  }

  Widget getJuzSelectionWidget() {
    return Card(
      child: Column(children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.pie_chart),
            ),
            AutoSizeText(
              "أجزاء الإختبار",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
              'من',
              textAlign: TextAlign.center,
            )),
            Flexible(
              child: Card(
                elevation: 0,
                child: NumberPicker(
                    zeroPad: true,
                    minValue: 1,
                    maxValue: 30,
                    value: _firstJuz,
                    textStyle: TextStyle(
                      fontSize: 17,
                    ),
                    selectedTextStyle: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textMapper: (num) => ArabicUtils.englishToArabic(num),
                    onChanged: (newValue) {
                      setState(() {
                        _firstJuz = newValue;
                        _lastJuz = max(_lastJuz, _firstJuz);
                      });
                    }),
              ),
            ),
            Flexible(
                child: Text(
              'إلى',
              textAlign: TextAlign.center,
            )),
            Flexible(
              child: NumberPicker(
                  zeroPad: true,
                  minValue: 1,
                  maxValue: 30,
                  value: _lastJuz,
                  textStyle: TextStyle(
                    fontSize: 17,
                  ),
                  selectedTextStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textMapper: (num) => ArabicUtils.englishToArabic(num),
                  onChanged: (newValue) {
                    setState(() {
                      _lastJuz = newValue;
                    });
                  }),
            ),
          ],
        ),
      ]),
    );
  }

  Widget getSurahSelectionWidget() {
    print(_firstSurah);
    print(_lastSurah);
    return Card(
      child: Column(children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.pie_chart),
            ),
            AutoSizeText(
              "سور الإختبار",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
              'من',
              textAlign: TextAlign.center,
            )),
            Flexible(
              child: Card(
                elevation: 0,
                child: NumberPicker(
                    zeroPad: true,
                    minValue: 2,
                    maxValue: 57,
                    value: _firstSurah,
                    textStyle: TextStyle(
                      fontSize: 17,
                    ),
                    selectedTextStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textMapper: (num) => QuranUtils
                        .surahNameToVersesCount[int.parse(num) - 1]['name'],
                    onChanged: (newValue) {
                      setState(() {
                        _firstSurah = newValue;
                        _lastSurah = max(_firstSurah, _lastSurah);
                      });
                    }),
              ),
            ),
            Flexible(
                child: Text(
              'إلى',
              textAlign: TextAlign.center,
            )),
            Flexible(
              child: NumberPicker(
                  zeroPad: true,
                  minValue: 2,
                  maxValue: 57,
                  value: _lastSurah,
                  textStyle: TextStyle(
                    fontSize: 17,
                  ),
                  selectedTextStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textMapper: (num) => QuranUtils
                      .surahNameToVersesCount[int.parse(num) - 1]['name'],
                  onChanged: (newValue) {
                    setState(() {
                      _lastSurah = newValue;
                    });
                  }),
            ),
          ],
        ),
      ]),
    );
  }
}
