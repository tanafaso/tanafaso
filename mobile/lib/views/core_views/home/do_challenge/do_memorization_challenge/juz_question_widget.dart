import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/choices_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/memorization_challenge_step_done_callback.dart';
import 'package:flutter/material.dart';

class JuzQuestionWidget extends StatefulWidget {
  final Question question;
  final MemorizationChallengeStepDoneCallback callback;
  final ScrollController scrollController;

  JuzQuestionWidget({
    required this.question,
    required this.callback,
    required this.scrollController,
  });

  @override
  _JuzQuestionWidgetState createState() => _JuzQuestionWidgetState();
}

class _JuzQuestionWidgetState extends State<JuzQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      shrinkWrap: true,
      children: [
        Text(
          'اختر الآية الأولى في الجزء',
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
                word: QuranUtils.ayahs[widget.question.firstAyahInJuz! - 1],
                correct: true),
            Choice(
                word: QuranUtils
                    .ayahs[widget.question.wrongFirstAyahInJuzOptions![0] - 1],
                correct: false),
            Choice(
                word: QuranUtils
                    .ayahs[widget.question.wrongFirstAyahInJuzOptions![1] - 1],
                correct: false),
          ],
          onCorrectChoiceSelected: () => widget.callback.call(),
        )
      ],
    );
  }
}
