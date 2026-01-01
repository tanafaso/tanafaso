import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/group.dart';
import 'package:azkar/models/reading_quran_challenge.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_challenge_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_reading_quran_challenge/do_reading_surah_screen.dart';
import 'package:azkar/views/core_views/home/do_challenge/friends_progress_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class DoReadingQuranChallengeScreen extends StatefulWidget {
  final ReadingQuranChallenge challenge;
  final Group group;

  // Note that some of the challenged users may not be friends.
  final List<String> challengedUsersIds;
  final List<String> challengedUsersFullNames;

  final List<Friend> friendshipScores;

  DoReadingQuranChallengeScreen({
    required this.challenge,
    required this.group,
    required this.challengedUsersIds,
    required this.challengedUsersFullNames,
    required this.friendshipScores,
  });

  @override
  _DoReadingQuranChallengeScreenState createState() =>
      _DoReadingQuranChallengeScreenState();
}

class _DoReadingQuranChallengeScreenState
    extends State<DoReadingQuranChallengeScreen>
    with SingleTickerProviderStateMixin {
  ConfettiController? confettiControler;
  bool? _finishedConfetti;
  ButtonState? _progressButtonState;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    _progressButtonState =
        widget.challenge.finished! ? ButtonState.success : ButtonState.idle;
    _finishedConfetti = false;
    confettiControler =
        ConfettiController(duration: const Duration(seconds: 1));
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.challenge.getName(),
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                    child: Visibility(
                      visible: widget.group != null,
                      child: widget.group == null
                          ? Container()
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 5,
                              ),
                              child: FriendsProgressWidget(
                                challenge: Challenge(
                                    readingQuranChallenge: widget.challenge),
                                challengedUsersIds: widget.challengedUsersIds,
                                challengedUsersFullNames:
                                    widget.challengedUsersFullNames,
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      interactive: true,
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height / 3),
                        child: ListView.separated(
                          controller: _scrollController,
                          separatorBuilder: (BuildContext context, int index) =>
                              Padding(padding: EdgeInsets.all(4)),
                          shrinkWrap: true,
                          itemCount:
                              widget.challenge.surahSubChallenges!.length,
                          itemBuilder: (context, index) {
                            return RawMaterialButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoReadingSurahScreen(
                                    surahSubChallenge: widget
                                        .challenge.surahSubChallenges![index],
                                  ),
                                ),
                              ),
                              fillColor: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 25),
                                            children: [
                                              TextSpan(
                                                  text: widget
                                                      .challenge
                                                      .surahSubChallenges![
                                                          index]
                                                      .surahName,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Theme.of(context)
                                                              .primaryTextTheme.labelLarge!
                                                              .fontFamily,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              TextSpan(text: ' من الآية رقم '),
                                              TextSpan(
                                                  text: ArabicUtils
                                                      .englishToArabic(widget
                                                          .challenge
                                                          .surahSubChallenges![
                                                              index]
                                                          .startingVerseNumber
                                                          .toString()),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              TextSpan(
                                                text: ' إلى الآية رقم ',
                                              ),
                                              TextSpan(
                                                  text: ArabicUtils
                                                      .englishToArabic(widget
                                                          .challenge
                                                          .surahSubChallenges![
                                                              index]
                                                          .endingVerseNumber
                                                          .toString()),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ProgressButton.icon(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              iconedButtons: {
                                ButtonState.idle: IconedButton(
                                    text: "اضغط بعد قراءة الآيات",
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    color: Colors.green.shade300),
                                ButtonState.loading: IconedButton(
                                    text: null, color: Colors.yellow.shade200),
                                ButtonState.fail: IconedButton(
                                    text: AppLocalizations.of(context).failed,
                                    icon:
                                        Icon(Icons.cancel, color: Colors.white),
                                    color: Colors.red.shade300),
                                ButtonState.success: IconedButton(
                                    text:
                                        "وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ",
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    color: Colors.green.shade400)
                              },
                              onPressed: onProgressButtonClicked,
                              state: _progressButtonState,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            getConfettiWidget(),
          ],
        ));
  }

  void onProgressButtonClicked() async {
    if (_progressButtonState == ButtonState.idle) {
      setState(() {
        _progressButtonState = ButtonState.loading;
      });
      try {
        await ServiceProvider.challengesService
            .finishReadingQuranChallenge(widget.challenge.id!);
      } on ApiException catch (e) {
        SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
        return;
      }
      setState(() {
        _progressButtonState = ButtonState.success;
        confettiControler!.addListener(() {
          if (confettiControler!.state == ConfettiControllerState.stopped) {
            onFinishedConfetti();
          }
        });

        confettiControler!.play();
      });
    } else if (_progressButtonState == ButtonState.success) {
      SnackBarUtils.showSnackBar(context, "لقد أنهيت هذا التحدي سابقًا");
    }
  }

  Align getConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        maximumSize: Size(30, 30),
        shouldLoop: false,
        confettiController: confettiControler!,
        blastDirection: pi,
        blastDirectionality: BlastDirectionality.explosive,
        maxBlastForce: 10,
        minBlastForce: 3,
        emissionFrequency: 0.5,
        numberOfParticles: 5,
        gravity: 1,
      ),
    );
  }

  onFinishedConfetti() async {
    // Avoid popping twice if confetti's controller decided to call our listner
    // more than once.
    if (_finishedConfetti!) {
      return;
    }
    _finishedConfetti = true;

    bool ratingRequestShown = false;
    if (Platform.isAndroid && widget.challengedUsersIds.length >= 2) {
      var prefs = await ServiceProvider.cacheManager.getPrefs();
      if (!prefs.containsKey(CacheManager.CACHE_KEY_ASKED_FOR_REVIEW)) {
        prefs.setBool(CacheManager.CACHE_KEY_ASKED_FOR_REVIEW, true);
        ratingRequestShown = true;
        await DoChallengeUtils.showReviewDialog(context);
      }
    }

    if (!ratingRequestShown) {
      await DoChallengeUtils.showFriendsScoreDialog(
          context, widget.friendshipScores, widget.challengedUsersIds);
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    confettiControler!.dispose();
    super.dispose();
  }
}
