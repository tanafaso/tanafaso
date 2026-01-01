import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/reading_quran_challenge.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:flutter/material.dart';

class SelectSurahScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<QuranSurah> quranSurahs = QuranUtils.getSortedQuranSuras();

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "اختر سورة",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: quranSurahs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: RawMaterialButton(
                fillColor: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText.rich(TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 25),
                          children: [
                            TextSpan(
                                text: ArabicUtils.englishToArabic(
                                    (index + 1).toString())),
                            TextSpan(text: '. '),
                            TextSpan(
                                text: quranSurahs[index].name,
                                style: TextStyle(
                                  fontFamily: Theme.of(context)
                                      .primaryTextTheme
                                      .labelLarge!
                                      .fontFamily,
                                )),
                          ],
                        )),
                        AutoSizeText.rich(
                          TextSpan(
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 20),
                            children: [
                              TextSpan(text: 'آياتها'),
                              TextSpan(text: ' '),
                              TextSpan(
                                  text: ArabicUtils.englishToArabic(
                                      quranSurahs[index]
                                          .versesCount
                                          .toString())),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                onPressed: () async {
                  SurahSubChallenge selectedSubChallenge = await showDialog(
                      context: context,
                      builder: (context) {
                        int firstAyah = 1;
                        int lastAyah = quranSurahs[index].versesCount;
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            actions: [],
                            content: IntrinsicHeight(
                              child: Center(
                                child: Column(
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 25),
                                        children: [
                                          TextSpan(
                                              text:
                                                  'سوف تتحدى أصدقائك أن يقرؤوا'),
                                          TextSpan(text: ' '),
                                          TextSpan(text: 'سورة'),
                                          TextSpan(text: ' '),
                                          TextSpan(
                                              text: quranSurahs[index].name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: Theme.of(context)
                                                      .primaryTextTheme
                                                      .labelLarge!
                                                      .fontFamily,
                                                  fontSize: 30,
                                                  color: Colors.black)),
                                          TextSpan(
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 25),
                                            children: [
                                              TextSpan(text: ' من الآية رقم '),
                                              TextSpan(
                                                  text: ArabicUtils.englishToArabic(
                                                      firstAyah.toString()),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.black)),
                                              TextSpan(
                                                text: ' إلى الآية رقم ',
                                              ),
                                              TextSpan(
                                                  text: ArabicUtils.englishToArabic(
                                                      lastAyah.toString()),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.black)),
                                            ],
                                          )
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    RangeSlider(
                                      values: RangeValues(firstAyah.toDouble(),
                                          lastAyah.toDouble()),
                                      min: 1,
                                      max: quranSurahs[index].versesCount * 1.0,
                                      divisions: quranSurahs[index].versesCount,
                                      onChanged: (RangeValues newRange) =>
                                          setState(() {
                                        firstAyah =
                                            newRange.start.round().toInt();
                                        lastAyah = newRange.end.round().toInt();
                                      }),
                                      labels: RangeLabels(
                                          ArabicUtils.englishToArabic(
                                              firstAyah.toString()),
                                          ArabicUtils.englishToArabic(
                                              lastAyah.toString())),
                                    ),
                                    RawMaterialButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context,
                                            SurahSubChallenge(
                                              surahName:
                                                  quranSurahs[index].name,
                                              startingVerseNumber: firstAyah,
                                              endingVerseNumber: lastAyah,
                                            ));
                                      },
                                      elevation: 2.0,
                                      fillColor: Colors.white,
                                      child: Text(
                                        '👍',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      });
                  Navigator.pop(context, selectedSubChallenge);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
