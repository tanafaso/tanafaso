import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/reading_quran_challenge.dart';
import 'package:azkar/utils/quran_utils.dart';
import 'package:flutter/material.dart';

class DoReadingSurahScreen extends StatefulWidget {
  final SurahSubChallenge surahSubChallenge;

  DoReadingSurahScreen({required this.surahSubChallenge});

  @override
  State<DoReadingSurahScreen> createState() => _DoReadingSurahScreenState();
}

class _DoReadingSurahScreenState extends State<DoReadingSurahScreen> {
  int? currentAyah;
  int? startingVerseNumZeroBased;
  int? endingVerseNumZeroBased;

  @override
  void initState() {
    super.initState();

    startingVerseNumZeroBased =
        widget.surahSubChallenge.startingVerseNumber! - 1;
    endingVerseNumZeroBased = widget.surahSubChallenge.endingVerseNumber! - 1;
    currentAyah = startingVerseNumZeroBased;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.surahSubChallenge.surahName!,
          style: TextStyle(
            fontSize: 30,
            fontFamily: Theme.of(context).primaryTextTheme.labelLarge!.fontFamily,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 3 / 5,
                width: MediaQuery.of(context).size.width,
                child: RawMaterialButton(
                  fillColor: Colors.white,
                  onPressed: () {
                    if (currentAyah == endingVerseNumZeroBased) {
                      Navigator.pop(context);
                    }
                    setState(() {
                      currentAyah = currentAyah! + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            minHeight: 10,
                            color: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white,
                            value: (currentAyah! -
                                    startingVerseNumZeroBased! +
                                    1) /
                                (endingVerseNumZeroBased! -
                                    startingVerseNumZeroBased! +
                                    1),
                          ),
                          Flexible(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Text(
                                  QuranUtils.getAyahInSurah(
                                      widget.surahSubChallenge.surahName!,
                                      currentAyah!),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontFamily:
                                        // ignore: deprecated_member_use
                                        Theme.of(context)
                                            // ignore: deprecated_member_use
                                            .primaryTextTheme.labelLarge!
                                            .fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              Row(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: currentAyah != startingVerseNumZeroBased,
                      child: RawMaterialButton(
                          fillColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              currentAyah = currentAyah! - 1;
                            });
                          },
                          child: Icon(Icons.arrow_back_outlined)),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  Expanded(
                    child: RawMaterialButton(
                      fillColor: Colors.white,
                      onPressed: () {
                        if (currentAyah == endingVerseNumZeroBased) {
                          Navigator.pop(context);
                        }
                        setState(() {
                          currentAyah = currentAyah! + 1;
                        });
                      },
                      child: Icon(
                        currentAyah == endingVerseNumZeroBased
                            ? Icons.done_all_outlined
                            : Icons.arrow_forward_outlined,
                        color: currentAyah == endingVerseNumZeroBased
                            ? Colors.green.shade600
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}
