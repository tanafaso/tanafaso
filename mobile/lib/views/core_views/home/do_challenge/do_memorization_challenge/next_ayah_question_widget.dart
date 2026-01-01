import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/choices_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/memorization_challenge_step_done_callback.dart';
import 'package:flutter/material.dart';

class NextAyahQuestionWidget extends StatefulWidget {
  final Question question;
  final MemorizationChallengeStepDoneCallback onStepDone;
  final ScrollController scrollController;

  NextAyahQuestionWidget({
    required this.question,
    required this.onStepDone,
    required this.scrollController,
  });

  @override
  _NextAyahQuestionWidgetState createState() => _NextAyahQuestionWidgetState();
}

class _NextAyahQuestionWidgetState extends State<NextAyahQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      shrinkWrap: true,
      children: [
        Text(
          'اختر الآية التالية',
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
                word: QuranUtils.ayahs[widget.question.ayah! + 1 - 1],
                correct: true),
            Choice(
                word: QuranUtils
                    .ayahs[widget.question.wrongNextAyahOptions![0] - 1],
                correct: false),
            Choice(
                word: QuranUtils
                    .ayahs[widget.question.wrongNextAyahOptions![1] - 1],
                correct: false),
          ],
          onCorrectChoiceSelected: () => widget.onStepDone.call(),
        )
      ],
    );
  }
}
