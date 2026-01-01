import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/juz_question_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/next_ayah_question_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/previous_ayah_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/rub_question_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/surah_question_widget.dart';
import 'package:flutter/material.dart';

typedef QuestionFinishedCallback = void Function();
typedef QuestionExpandedCallback = void Function();

class DoMemorizationChallengeListItemWidget extends StatefulWidget {
  final Question question;
  final QuestionFinishedCallback onQuestionDoneCallback;
  final QuestionExpandedCallback onQuestionExpandedCallback;

  // Only use to check if the challenge is expired, since other data may change
  // and will not be consistent.
  final MemorizationChallenge challenge;
  final ScrollController scrollController;

  DoMemorizationChallengeListItemWidget({
    required Key key,
    required this.question,
    required this.onQuestionDoneCallback,
    required this.onQuestionExpandedCallback,
    required this.challenge,
    required this.scrollController,
  }) : super(key: key);

  @override
  _DoMemorizationChallengeListItemWidgetState createState() =>
      _DoMemorizationChallengeListItemWidgetState();
}

enum Step {
  SURAH_QUESTION,
  NEXT_AYAH_QUESTION,
  JUZ_QUESTION,
  PREVIOUS_AYAH_QUESTION,
  RUB_QUESTION,
  DONE,
}

int stepToOrder(Step step) {
  switch (step) {
    case Step.SURAH_QUESTION:
      return 0;
    case Step.NEXT_AYAH_QUESTION:
      return 1;
    case Step.JUZ_QUESTION:
      return 2;
    case Step.PREVIOUS_AYAH_QUESTION:
      return 3;
    case Step.RUB_QUESTION:
      return 4;
    case Step.DONE:
      return 5;
  }
  assert(false);
  return 0;
}

Step orderToStep(int order) {
  switch (order) {
    case 0:
      return Step.SURAH_QUESTION;
    case 1:
      return Step.NEXT_AYAH_QUESTION;
    case 2:
      return Step.JUZ_QUESTION;
    case 3:
      return Step.PREVIOUS_AYAH_QUESTION;
    case 4:
      return Step.RUB_QUESTION;
    case 5:
      return Step.DONE;
  }
  assert(false);
  return Step.SURAH_QUESTION;
}

Step nextStep(Step step) {
  return orderToStep(stepToOrder(step) + 1);
}

class _DoMemorizationChallengeListItemWidgetState
    extends State<DoMemorizationChallengeListItemWidget> {
  bool? _tileExpanded;
  Step? _currentStep;

  @override
  void initState() {
    super.initState();

    _tileExpanded = false;
    _currentStep = widget.question.finished! ? Step.DONE : Step.SURAH_QUESTION;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionTile(
        title: Row(
          children: [
            getIcon(),
            Padding(padding: EdgeInsets.only(right: 8)),
            Text(
              'سؤال ',
              style: TextStyle(fontSize: 30),
            ),
            Text(
                ArabicUtils.englishToArabic(
                    (widget.question.number! + 1).toString()),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        initiallyExpanded: false,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        collapsedBackgroundColor: Theme.of(context).colorScheme.secondary,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedTextColor: Colors.black,
        collapsedIconColor: Colors.black,
        trailing: Icon(
          _tileExpanded! ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: 30,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _tileExpanded = expanded;
          });

          widget.onQuestionExpandedCallback.call();
        },
        children: [
          Column(
            children: [
              Text(
                QuranUtils.ayahs[widget.question.ayah! - 1],
                style: TextStyle(
                  fontSize: 25,
                  // ignore: deprecated_member_use
                  fontFamily:
                      // ignore: deprecated_member_use
                      Theme.of(context).primaryTextTheme.labelLarge!.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(child: getCurrentStepQuestionWidget()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getCurrentStepQuestionWidget() {
    switch (_currentStep) {
      case Step.SURAH_QUESTION:
        return SurahQuestionWidget(
          question: widget.question,
          callback: onStepDone,
          scrollController: widget.scrollController,
        );
      case Step.NEXT_AYAH_QUESTION:
        return NextAyahQuestionWidget(
          question: widget.question,
          onStepDone: onStepDone,
          scrollController: widget.scrollController,
        );
      case Step.JUZ_QUESTION:
        return JuzQuestionWidget(
          question: widget.question,
          callback: onStepDone,
          scrollController: widget.scrollController,
        );
      case Step.PREVIOUS_AYAH_QUESTION:
        return PreviousAyahQuestionWidget(
          question: widget.question,
          onStepDone: onStepDone,
          scrollController: widget.scrollController,
        );
      case Step.RUB_QUESTION:
        return RubQuestionWidget(
          question: widget.question,
          onStepDone: onStepDone,
          scrollController: widget.scrollController,
        );
      case Step.DONE:
        return Container();
      case null:
        return Container();
    }

    assert(false);
    return Card(
      color: Colors.grey,
    );
  }

  void onStepDone() {
    setState(() {
      if (widget.challenge.difficulty == 1 &&
          _currentStep == Step.NEXT_AYAH_QUESTION) {
        _currentStep = Step.DONE;
      } else if (widget.challenge.difficulty == 2 &&
          _currentStep == Step.PREVIOUS_AYAH_QUESTION) {
        _currentStep = Step.DONE;
      } else {
        _currentStep = nextStep(_currentStep!);
      }
      if (_currentStep == Step.DONE) {
        widget.question.finished = true;
        widget.onQuestionDoneCallback.call();
      }
    });
  }

  Widget getIcon() {
    if (widget.question.finished!) {
      return Icon(
        Icons.done_outline,
        color: Colors.green,
        size: 30,
      );
    }
    if (Challenge(memorizationChallenge: widget.challenge).deadlinePassed()) {
      return Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 30,
      );
    }
    return Icon(
      Icons.not_started,
      color: Colors.yellow,
      size: 30,
    );
  }
}
