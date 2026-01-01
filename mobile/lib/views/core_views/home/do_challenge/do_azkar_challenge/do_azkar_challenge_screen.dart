import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/group.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/cache_manager.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_azkar_challenge/do_azkar_challenge_list_item_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_challenge_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/friends_progress_widget.dart';
import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class DoAzkarChallengeScreen extends StatefulWidget {
  final AzkarChallenge challenge;
  final Group group;

  // Note that some of the challenged users may not be friends.
  final List<String> challengedUsersIds;
  final List<String> challengedUsersFullNames;

  final List<Friend> friendshipScores;

  DoAzkarChallengeScreen({
    required this.challenge,
    required this.group,
    required this.challengedUsersIds,
    required this.challengedUsersFullNames,
    required this.friendshipScores,
  });

  @override
  _DoAzkarChallengeScreenState createState() => _DoAzkarChallengeScreenState();
}

class _DoAzkarChallengeScreenState extends State<DoAzkarChallengeScreen>
    with WidgetsBindingObserver {
  late ConfettiController confettiControler;
  late bool _finishedConfetti;
  late bool _friendsTileExpanded;
  late List<int> _lastUpdatedRepetitionsList;

  @override
  void initState() {
    super.initState();

    List<SubChallenge> finishedSubChallenges = widget.challenge.subChallenges
        .where((subChallenge) => subChallenge.done())
        .toList();
    widget.challenge.subChallenges
        .removeWhere((subChallenge) => subChallenge.done());
    widget.challenge.subChallenges.addAll(finishedSubChallenges);

    WidgetsBinding.instance.addObserver(this);
    _finishedConfetti = false;
    _friendsTileExpanded = true;
    updateLastUpdatedRepetitions();
    initConfettiController();
  }

  void initConfettiController() {
    confettiControler =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.challenge.name ?? "",
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ExpansionTile(
                        key: GlobalKey(debugLabel: 'friends_tile_key'),
                        title: Text(
                          "الأصدقاء",
                          style: TextStyle(
                              fontSize: _friendsTileExpanded ? 25 : 20,
                              fontWeight: FontWeight.bold),
                        ),
                        initiallyExpanded: _friendsTileExpanded,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        collapsedBackgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        collapsedTextColor: Colors.black,
                        collapsedIconColor: Colors.black,
                        trailing: Icon(
                          _friendsTileExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 30,
                        ),
                        onExpansionChanged: (bool expanded) {
                          setState(() => _friendsTileExpanded = expanded);
                        },
                        children: [
                          Column(
                            children: [
                              Visibility(
                                visible: widget.group != null,
                                child: widget.group == null
                                    ? Container()
                                    : SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                5,
                                          ),
                                          child: FriendsProgressWidget(
                                            challenge: Challenge(
                                                azkarChallenge:
                                                    widget.challenge),
                                            challengedUsersIds:
                                                widget.challengedUsersIds,
                                            challengedUsersFullNames:
                                                widget.challengedUsersFullNames,
                                          ),
                                        ),
                                      ),
                              ),
                              Visibility(
                                child: Divider(),
                                visible: (((widget.challenge.motivation ?? "")
                                        .length) !=
                                    0),
                              ),
                              Visibility(
                                visible: (((widget.challenge.motivation ?? "")
                                        .length) !=
                                    0),
                                maintainSize: false,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.directions_run),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                3 /
                                                4,
                                        child: AutoSizeText(
                                          widget.challenge.motivation ?? "",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(fontSize: 25),
                                          maxLines: 4,
                                          minFontSize: 18,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: getSubChallenges()),
                ],
              ),
            ),
            getConfettiWidget(),
          ],
        ));
  }

  Align getConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        maximumSize: Size(30, 30),
        shouldLoop: false,
        confettiController: confettiControler,
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

  Widget getSubChallenges() {
    return ListView.separated(
      padding: EdgeInsets.all(4),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: widget.challenge.subChallenges.length,
      addAutomaticKeepAlives: true,
      separatorBuilder: (BuildContext context, int index) =>
          Padding(padding: EdgeInsets.only(bottom: 4)),
      itemBuilder: (context, index) {
        return DoAzkarChallengeListItemWidget(
          key: UniqueKey(),
          keepAlive: true,
          subChallenge: widget.challenge.subChallenges[index],
          challenge: widget.challenge,
          callback: (SubChallenge newSubChallenge) async {
            widget.challenge.subChallenges[index] = newSubChallenge;
            if (newSubChallenge.done()) {
              setState(() {
                _friendsTileExpanded = false;
                widget.challenge.subChallenges.add(newSubChallenge);
                widget.challenge.subChallenges.removeAt(index);
              });
            }

            if (widget.challenge.done()) {
              updateAzkarChallenge();
              confettiControler.addListener(() {
                if (confettiControler.state ==
                    ConfettiControllerState.stopped) {
                  onFinishedConfetti();
                }
              });
              confettiControler.play();
            }
          },
        );
      },
    );
  }

  onFinishedConfetti() async {
    // Avoid popping twice if confetti's controller decided to call our listner
    // more than once.
    if (_finishedConfetti) {
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

  updateAzkarChallenge() async {
    if (!ListEquality().equals(_lastUpdatedRepetitionsList,
        widget.challenge.subChallenges.map((e) => e.repetitions).toList())) {
      updateLastUpdatedRepetitions();
      try {
        await ServiceProvider.challengesService
            .updateAzkarChallenge(widget.challenge);
      } on ApiException catch (e) {
        SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      }
    }
  }

  @override
  void deactivate() {
    updateAzkarChallenge();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    updateAzkarChallenge();
    confettiControler.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    updateAzkarChallenge();
  }

  updateLastUpdatedRepetitions() {
    _lastUpdatedRepetitionsList = [];
    for (SubChallenge subChallenge in widget.challenge.subChallenges) {
      _lastUpdatedRepetitionsList.add(subChallenge.repetitions);
    }
  }
}
