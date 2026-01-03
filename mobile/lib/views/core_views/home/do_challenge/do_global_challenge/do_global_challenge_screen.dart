import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/global_challenge.dart';
import 'package:azkar/models/sub_challenge.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_azkar_challenge/do_azkar_challenge_list_item_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../home_main_screen.dart';

class DoGlobalChallengeScreen extends StatefulWidget {
  final GlobalChallenge globalChallenge;
  final ReloadHomeMainScreenCallback reloadHomeMainScreenCallback;

  DoGlobalChallengeScreen({
    required this.globalChallenge,
    required this.reloadHomeMainScreenCallback,
  });

  @override
  _DoGlobalChallengeScreenState createState() =>
      _DoGlobalChallengeScreenState();
}

class _DoGlobalChallengeScreenState extends State<DoGlobalChallengeScreen>
    with WidgetsBindingObserver {
  late ConfettiController confettiControler;
  late bool _finishedConfetti;
  bool _isInfoCardCollapsed = true;

  @override
  void initState() {
    super.initState();

    List<SubChallenge> finishedSubChallenges = widget
        .globalChallenge.challenge.azkarChallenge!.subChallenges
        .where((subChallenge) => subChallenge.done())
        .toList();
    widget.globalChallenge.challenge.azkarChallenge!.subChallenges
        .removeWhere((subChallenge) => subChallenge.done());
    widget.globalChallenge.challenge.azkarChallenge!.subChallenges
        .addAll(finishedSubChallenges);

    WidgetsBinding.instance.addObserver(this);
    _finishedConfetti = false;
    initConfettiController();
  }

  void initConfettiController() {
    confettiControler =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.globalChallenge.challenge.azkarChallenge!.name ?? "",
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'التقدم',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${ArabicUtils.englishToArabic(widget.globalChallenge.challenge.azkarChallenge!.subChallenges.where((s) => s.done()).length.toString())}/${ArabicUtils.englishToArabic(widget.globalChallenge.challenge.azkarChallenge!.subChallenges.length.toString())}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: widget.globalChallenge.challenge
                                    .azkarChallenge!.subChallenges.isEmpty
                                ? 0
                                : widget.globalChallenge.challenge
                                        .azkarChallenge!.subChallenges
                                        .where((s) => s.done())
                                        .length /
                                    widget.globalChallenge.challenge
                                        .azkarChallenge!.subChallenges.length,
                            backgroundColor: Colors.grey.shade300,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Card(
                      color: Colors.green.shade50,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isInfoCardCollapsed = !_isInfoCardCollapsed;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.public,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      size: 30),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'تحدي مشترك لجميع مستخدمي التطبيق',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Icon(
                                    _isInfoCardCollapsed
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_up,
                                    color: Colors.green.shade800,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!_isInfoCardCollapsed)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 12.0, bottom: 12.0),
                              child: Column(
                                children: [
                                  Text(
                                    'عدد المرات التي تم إنهاء هذا التحدي: ${ArabicUtils.englishToArabic(widget.globalChallenge.finishedCount.toString())} 🎉',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'يمكنك إنهاء هذا التحدي أكثر من مرة!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Visibility(
                                    visible: ((widget.globalChallenge.challenge
                                                .azkarChallenge?.motivation ??
                                            "")
                                        .isNotEmpty),
                                    child: Column(
                                      children: [
                                        Divider(),
                                        Row(
                                          children: [
                                            Icon(Icons.directions_run,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: AutoSizeText(
                                                widget
                                                        .globalChallenge
                                                        .challenge
                                                        .azkarChallenge
                                                        ?.motivation ??
                                                    "",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 20),
                                                maxLines: 3,
                                                minFontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: widget.globalChallenge.challenge
                          .azkarChallenge!.subChallenges.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Padding(padding: EdgeInsets.only(bottom: 4)),
                      itemBuilder: (context, index) {
                        return DoAzkarChallengeListItemWidget(
                          key: UniqueKey(),
                          keepAlive: false,
                          subChallenge: widget.globalChallenge.challenge
                              .azkarChallenge!.subChallenges[index],
                          challenge:
                              widget.globalChallenge.challenge.azkarChallenge!,
                          callback: (SubChallenge newSubChallenge) async {
                            widget.globalChallenge.challenge.azkarChallenge!
                                .subChallenges[index] = newSubChallenge;
                            if (newSubChallenge.done()) {
                              setState(() {
                                widget.globalChallenge.challenge.azkarChallenge!
                                    .subChallenges
                                    .add(newSubChallenge);
                                widget.globalChallenge.challenge.azkarChallenge!
                                    .subChallenges
                                    .removeAt(index);
                              });
                            }

                            if (widget.globalChallenge.challenge.azkarChallenge!
                                .done()) {
                              finishGlobalChallenge();
                              confettiControler.addListener(() {
                                if (confettiControler.state ==
                                    ConfettiControllerState.stopped) {
                                  onFinishedConfetti();
                                }
                              });
                              confettiControler.play();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            getConfettiWidget(),
          ],
        ));
  }

  Future<void> finishGlobalChallenge() async {
    try {
      await ServiceProvider.challengesService.finishGlobalChallenge();
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      Navigator.of(context).pop();
    }
  }

  Align getConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        maximumSize: Size(30, 30),
        shouldLoop: false,
        confettiController: confettiControler,
        blastDirection: pi,
        blastDirectionality: BlastDirectionality.explosive,
        maxBlastForce: 10,
        minBlastForce: 3,
        emissionFrequency: 0.5,
        numberOfParticles: 5,
        gravity: 1,
      ),
    );
  }

  onFinishedConfetti() async {
    // Avoid popping twice if confetti's controller decided to call our listner
    // more than once.
    if (_finishedConfetti) {
      return;
    }
    _finishedConfetti = true;

    await await showDialog(
      context: context,
      builder: (_) => Center(
        child: SizedBox(
          width: double.maxFinite,
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَى 🔥',
                            style: TextStyle(
                              fontFamily: Theme.of(context)
                                  .primaryTextTheme
                                  .labelLarge!
                                  .fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                      children: widget.globalChallenge.finishedCount == 0
                          ? <TextSpan>[
                              new TextSpan(
                                text:
                                    'تهانينا! أنت أول من أنهى تحدي الأذكار المشترك بنجاح! 🎉',
                                style: new TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]
                          : <TextSpan>[
                              new TextSpan(
                                text:
                                    'تهانينا! لقد تم إنهاء هذا التحدي المشترك ',
                                style: new TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold),
                              ),
                              new TextSpan(
                                text: ArabicUtils.englishToArabic(
                                    (widget.globalChallenge.finishedCount + 1)
                                        .toString()),
                                style: new TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
                              ),
                              new TextSpan(
                                text:
                                    ' مرات حتى الآن. يمكنك إنهاء هذا التحدي أكثر من مرة 🎉',
                                style: new TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                    ),
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Text(
                    '💪',
                    style: TextStyle(fontSize: 25),
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                )
              ],
            ),
          ),
        ),
      ),
    );
    widget.reloadHomeMainScreenCallback();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    confettiControler.dispose();
    super.dispose();
  }
}
