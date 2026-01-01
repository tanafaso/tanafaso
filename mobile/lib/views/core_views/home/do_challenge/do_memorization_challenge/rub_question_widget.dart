import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/choices_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/memorization_challenge_step_done_callback.dart';
import 'package:flutter/material.dart';

class RubQuestionWidget extends StatefulWidget {
  final Question question;
  final MemorizationChallengeStepDoneCallback onStepDone;
  final ScrollController scrollController;

  RubQuestionWidget({
    required this.question,
    required this.onStepDone,
    required this.scrollController,
  });

  @override
  _RubQuestionWidgetState createState() => _RubQuestionWidgetState();
}

class _RubQuestionWidgetState extends State<RubQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      shrinkWrap: true,
      children: [
        Text(
          'اختر الآية الأولى في الربع',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        ChoicesWidget(
          scrollController: widget.scrollController,
          choices: [
            Choice(
                word: QuranUtils.ayahs[widget.question.firstAyahInRub! - 1],
                correct: true),
            Choice(
                word: QuranUtils
                    .ayahs[widget.question.wrongFirstAyahInRubOptions![0] - 1],
                correct: false),
            Choice(
                word: QuranUtils
                    .ayahs[widget.question.wrongFirstAyahInRubOptions![1] - 1],
                correct: false),
          ],
          onCorrectChoiceSelected: () => widget.onStepDone.call(),
        )
      ],
    );
  }
}
