import 'package:azkar/models/friend.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class DoChallengeUtils {
  static Future<void> showFriendsScoreDialog(BuildContext context,
      List<Friend> friendshipScores, List<String> challengeUserIds) async {
    List<Friend> relevantFriendScores = friendshipScores
        .where((friendshipScore) =>
            challengeUserIds.contains(friendshipScore.userId))
        .toList();

    var scrollController = ScrollController();

    await showDialog(
      context: context,
      builder: (_) => Center(
        child: SizedBox(
          width: double.maxFinite,
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'استمر في تحفيز أصدقائك وتحديهم 🔥',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: scrollController,
                      child: ListView.separated(
                          padding: EdgeInsets.all(0),
                          addAutomaticKeepAlives: true,
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                          shrinkWrap: true,
                          itemCount: relevantFriendScores.length,
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            return AnimatedScoreChangeWidget(
                              friendshipScores: relevantFriendScores[index],
                            );
                          }),
                    ),
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Text(
                    '💪',
                    style: TextStyle(fontSize: 25),
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showReviewDialog(BuildContext context) {
    Widget cancelButton = OutlinedButton(
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "لا شكرا",
                maxLines: 1,
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = OutlinedButton(
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "قيم التطبيق",
                maxLines: 1,
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        InAppReview.instance.openStoreListing();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "تقييم التطبيق",
          maxLines: 1,
          style: TextStyle(fontSize: 35),
        ),
      ),
      content: Row(
        children: [
          Expanded(
            child: Text(
              "هل يمكنك تقييم التطبيق إذا كنت تعتقد أنه مفيد؟ 😊",
              style: TextStyle(fontSize: 20),
              maxLines: 4,
            ),
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// A widget that takes and old friendship score and adds one to the current user
// with animation to celebrate progress after finishing a challenge.
class AnimatedScoreChangeWidget extends StatefulWidget {
  final Friend friendshipScores;

  AnimatedScoreChangeWidget({required this.friendshipScores});

  @override
  _AnimatedScoreChangeWidgetState createState() =>
      _AnimatedScoreChangeWidgetState();
}

class _AnimatedScoreChangeWidgetState extends State<AnimatedScoreChangeWidget>
    with AutomaticKeepAliveClientMixin {
  bool? showOldScore;

  @override
  void initState() {
    super.initState();

    showOldScore = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        widget.friendshipScores.userTotalScore =
            widget.friendshipScores.userTotalScore! + 1;
        showOldScore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '${widget.friendshipScores.firstName} ${widget.friendshipScores.lastName}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: AnimatedSwitcher(
                    duration: Duration(seconds: 2),
                    child: showOldScore!
                        ? Text(
                            (widget.friendshipScores.userTotalScore! -
                                    widget.friendshipScores.friendTotalScore)
                                .abs()
                                .toString(),
                            style: TextStyle(
                              color: getColor(),
                            ),
                            key: Key("1"),
                            softWrap: false,
                          )
                        : Text(
                            (widget.friendshipScores.userTotalScore! -
                                    widget.friendshipScores.friendTotalScore)
                                .abs()
                                .toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: getColor(),
                            ),
                            key: Key("2"),
                            softWrap: false,
                          ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 8)),
                AnimatedSwitcher(
                  child: showOldScore!
                      ? getArrowIcon(Key("1"))
                      : getArrowIcon(Key("2")),
                  duration: Duration(seconds: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Icon getArrowIcon(Key key) {
    if (widget.friendshipScores.friendTotalScore >
        widget.friendshipScores.userTotalScore!) {
      return Icon(
        Icons.arrow_downward,
        key: key,
        color: getColor(),
      );
    } else if (widget.friendshipScores.friendTotalScore <
        widget.friendshipScores.userTotalScore!) {
      return Icon(
        Icons.arrow_upward,
        key: key,
        color: getColor(),
      );
    }
    return Icon(
      Icons.done_all,
      key: key,
      color: getColor(),
    );
  }

  Color getColor() {
    if (widget.friendshipScores.friendTotalScore >
        widget.friendshipScores.userTotalScore!) {
      return Colors.red;
    } else if (widget.friendshipScores.friendTotalScore <
        widget.friendshipScores.userTotalScore!) {
      return Colors.green;
    }
    return Colors.yellow.shade700;
  }

  @override
  bool get wantKeepAlive => true;
}
