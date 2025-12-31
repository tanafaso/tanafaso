import 'package:azkar/models/challenge.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:flutter/material.dart';

class ChallengeWidgetUtil {
  static Widget getDeadlineText(BuildContext context, Challenge challenge) {
    if (challenge.deadlinePassed()) {
      return Text(
        "انتهى التحدي",
        style: new TextStyle(
          color: Colors.grey.shade700,
          // fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      );
    }

    int daysLeft = challenge.daysLeft();
    if (daysLeft != 0) {
      return Text.rich(TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: AppLocalizations.of(context).endsAfter,
              style: new TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          new TextSpan(
            text:
            ' ${ArabicUtils.englishToArabic(challenge.daysLeft().toString())} ',
          ),
          new TextSpan(
            text: AppLocalizations.of(context).day,
          )
        ],
      ));
    }

    int hoursLeft = challenge.hoursLeft();
    if (hoursLeft != 0) {
      return Text.rich(TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: AppLocalizations.of(context).endsAfter,
              style: new TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          new TextSpan(
            text:
            ' ${ArabicUtils.englishToArabic(challenge.hoursLeft().toString())} ',
          ),
          new TextSpan(
            text: AppLocalizations.of(context).hour,
          )
        ],
      ));
    }

    int minutesLeft = challenge.minutesLeft();
    if (minutesLeft == 0) {
      return Text.rich(TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: AppLocalizations.of(context).endsAfterLessThan,
              style: new TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          new TextSpan(
            text: ' ١ ',
          ),
          new TextSpan(
            text: AppLocalizations.of(context).minute,
          )
        ],
      ));
    }
    return Text.rich(TextSpan(
      style: TextStyle(
        color: Colors.black,
        fontSize: 25,
      ),
      children: <TextSpan>[
        new TextSpan(
            text: AppLocalizations.of(context).endsAfter,
            style: new TextStyle(
                color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
        new TextSpan(
          text: ' ${ArabicUtils.englishToArabic(minutesLeft.toString())} ',
        ),
        new TextSpan(
          text: AppLocalizations.of(context).minute,
        )
      ],
    ));
  }
}