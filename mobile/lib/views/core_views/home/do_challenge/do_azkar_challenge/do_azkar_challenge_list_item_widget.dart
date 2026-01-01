import 'package:azkar/models/azkar_challenge.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:flutter/material.dart';

typedef SubChallengeChangedCallback = void Function(
    SubChallenge newSubChallenge);

class DoAzkarChallengeListItemWidget extends StatefulWidget {
  final SubChallenge subChallenge;
  final SubChallengeChangedCallback callback;

  // Only use to check if the challenge is expired, since other data may change
  // and will not be consistent.
  final AzkarChallenge challenge;

  final bool keepAlive;

  DoAzkarChallengeListItemWidget({
    required Key key,
    required this.keepAlive,
    required this.subChallenge,
    required this.callback,
    required this.challenge,
  }) : super(key: key);

  @override
  _DoAzkarChallengeListItemWidgetState createState() =>
      _DoAzkarChallengeListItemWidgetState();
}

class _DoAzkarChallengeListItemWidgetState
    extends State<DoAzkarChallengeListItemWidget>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Color? buttonColor;
  late int initialRepetitions;

  @override
  void initState() {
    super.initState();
    initialRepetitions = widget.subChallenge.repetitions;
  }

  @override
  Widget build(BuildContext context) {
    // Necessary as documented by AutomaticKeepAliveClientMixin.
    super.build(context);

    // Can't be called in initState
    if (buttonColor == null) {
      buttonColor = widget.subChallenge.done()
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).buttonTheme.colorScheme!.primary;
    }

    return RawMaterialButton(
      onPressed: () {
        if (widget.subChallenge.done()) {
          return;
        }
        if (widget.challenge.deadlinePassed()) {
          SnackBarUtils.showSnackBar(
            context,
            AppLocalizations.of(context)
                .theDeadlineHasAlreadyPassedForThisChallenge,
          );
          return;
        }
        setState(() {
          widget.subChallenge.repetitions -= 1;
          if (widget.subChallenge.repetitions == 0) {
            buttonColor = Theme.of(context).colorScheme.primary;
          }
          widget.callback.call(widget.subChallenge);
        });
      },
      fillColor: buttonColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.subChallenge.zekr.zekr!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontFamily:
                    // ignore: deprecated_member_use
                    Theme.of(context).primaryTextTheme.labelLarge!.fontFamily,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: getRepetitionsTextConditionally(),
          ),
          LinearProgressIndicator(
            minHeight: 10,
            // Reversed them. This is just a hack as I am afraid that
            // widget.subChallenge.repetitions maybe zero at some point.
            color: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            value: initialRepetitions == 0
                ? 0
                : widget.subChallenge.repetitions.toDouble() /
                    initialRepetitions.toDouble(),
          ),
        ],
      ),
    );
  }

  Widget getRepetitionsTextConditionally() {
    if (widget.subChallenge.repetitions == 0) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.done_outline),
          ),
          Text(
            AppLocalizations.of(context).youHaveFinishedReadingIt,
          ),
        ],
      );
    }

    return Text(
      '${AppLocalizations.of(context).theRemainingRepetitions}: ${ArabicUtils.englishToArabic(widget.subChallenge.repetitions.toString())}',
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
