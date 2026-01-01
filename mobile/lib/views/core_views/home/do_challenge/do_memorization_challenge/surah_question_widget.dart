import 'package:azkar/models/memorization_challenge.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/choices_widget.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_memorization_challenge/memorization_challenge_step_done_callback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SurahQuestionWidget extends StatefulWidget {
  final Question question;
  final MemorizationChallengeStepDoneCallback callback;
  final ScrollController scrollController;

  SurahQuestionWidget({
    required this.question,
    required this.callback,
    required this.scrollController,
  });

  @override
  _SurahQuestionWidgetState createState() => _SurahQuestionWidgetState();
}

class _SurahQuestionWidgetState extends State<SurahQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      shrinkWrap: true,
      children: [
        Text(
          'اختر السورة',
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
                word: QuranUtils
                    .surahNameToVersesCount[widget.question.surah! - 1]['name'],
                correct: true),
            Choice(
                word: QuranUtils.surahNameToVersesCount[
                    widget.question.wrongSurahOptions![0] - 1]['name'],
                correct: false),
            Choice(
                word: QuranUtils.surahNameToVersesCount[
                    widget.question.wrongSurahOptions![1] - 1]['name'],
                correct: false),
          ],
          onCorrectChoiceSelected: () => widget.callback.call(),
        )
      ],
    );
  }
}
