import 'dart:math';

import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/models/zekr.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:flutter/material.dart';

typedef OnZekrRepetitionsChangedCallback = void Function(
    SubChallenge newSubChallenge);

class ZekrWidget extends StatefulWidget {
  final Zekr zekr;
  final bool visible;
  final OnZekrRepetitionsChangedCallback onRepetitionsChangedCallback;

  ZekrWidget({
    required this.visible,
    required this.zekr,
    required this.onRepetitionsChangedCallback,
  });

  @override
  ZekrWidgetState createState() => ZekrWidgetState();
}

// The state is public here to be accessed only by the parent widget (i.e. SelectZekrScreen).
class ZekrWidgetState extends State<ZekrWidget>
    with AutomaticKeepAliveClientMixin {
  bool _selected = false;
  int _repetitions = 0;

  @override
  Widget build(BuildContext context) {
    // Necessary as documented by AutomaticKeepAliveClientMixin.
    super.build(context);

    return Visibility(
      visible: widget.visible,
      maintainSize: false,
      child: GestureDetector(
        onTap: () {
          // That's a dirty way of unfocusing the search bar in the parent widget
          // when its children widgets are clicked.
          FocusScope.of(context).unfocus();
          onSelected();
        },
        child: Card(
          margin: EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: _selected ? Colors.green.shade300 : Colors.white,
              width: 5,
            )),
            child: Container(
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IntrinsicHeight(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Text(
                                          widget.zekr.zekr!,
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: Theme.of(context)
                                                .primaryTextTheme.labelLarge!
                                                .fontFamily,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _selected,
                      maintainSize: false,
                      child: Container(
                        child: Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        ArabicUtils.englishToArabic("10"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  add(10);
                                },
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        ArabicUtils.englishToArabic("1"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  add(1);
                                },
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).repetitions,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 8)),
                                    Text(
                                      ArabicUtils.englishToArabic(
                                          _repetitions.toString()),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      ArabicUtils.englishToArabic("1"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                )),
                                onTap: () {
                                  subtract(1);
                                },
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.remove,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        ArabicUtils.englishToArabic("10"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  subtract(10);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void add(int repetitions) {
    setState(() {
      _repetitions = min(1000, repetitions + _repetitions);
      onRepetitionsChanged();
    });
  }

  void subtract(int repetitions) {
    setState(() {
      _repetitions = max(0, _repetitions - repetitions);
      if (_repetitions == 0) {
        _selected = false;
      }
      onRepetitionsChanged();
    });
  }

  void onSelected() {
    setState(() {
      _selected = true;
      _repetitions = max(_repetitions, 1);
    });
    onRepetitionsChanged();
  }

  void onRepetitionsChanged() {
    // That's a dirty way of unfocusing the search bar in the parent widget
    // when its children widgets are clicked.
    FocusScope.of(context).unfocus();

    widget.onRepetitionsChangedCallback(
        SubChallenge(zekr: widget.zekr, repetitions: _repetitions));
  }

  @override
  bool get wantKeepAlive => true;
}
