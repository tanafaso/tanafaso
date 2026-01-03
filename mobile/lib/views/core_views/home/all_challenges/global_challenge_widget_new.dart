import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/global_challenge.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/features.dart';
import 'package:azkar/views/core_views/home/all_challenges/challenge_list_item_loading_widget.dart';
import 'package:azkar/views/core_views/home/all_challenges/challenge_widget_util.dart';
import 'package:azkar/views/core_views/home/do_challenge/do_global_challenge/do_global_challenge_screen.dart';
import 'package:azkar/views/core_views/home/home_main_screen.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

class GlobalChallengeWidget extends StatefulWidget {
  final ReloadHomeMainScreenCallback reloadHomeMainScreenCallback;

  GlobalChallengeWidget({required this.reloadHomeMainScreenCallback});

  @override
  State<GlobalChallengeWidget> createState() => _GlobalChallengeWidgetState();
}

class _GlobalChallengeWidgetState extends State<GlobalChallengeWidget>
    with SingleTickerProviderStateMixin {
  late GlobalChallenge _globalChallenge;
  late AnimationController _controller;

  Future<void> getNeededData() async {
    _globalChallenge =
        await ServiceProvider.challengesService.getGlobalChallenge();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getNeededData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError &&
              _globalChallenge.challenge.challengeType == ChallengeType.AZKAR) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green
                                .withOpacity(0.3 + _controller.value * 0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE8F5E9),
                            Color(0xFFC8E6C9),
                            Color(0xFFA5D6A7),
                          ],
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: RawMaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.all(0),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DoGlobalChallengeScreen(
                                  globalChallenge: _globalChallenge,
                                  reloadHomeMainScreenCallback:
                                      widget.reloadHomeMainScreenCallback,
                                ))),
                    elevation: 0,
                    fillColor: Colors.transparent,
                    child: DescribedFeatureOverlay(
                      key: Key(Features.GLOBAL_CHALLENGE),
                      featureId: Features.GLOBAL_CHALLENGE,
                      overflowMode: OverflowMode.wrapBackground,
                      contentLocation: ContentLocation.below,
                      barrierDismissible: false,
                      backgroundDismissible: false,
                      tapTarget: Icon(Icons.public),
                      title: Center(
                        child: Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                child: Text(
                                    AppLocalizations.of(context)
                                        .globalChallengeFeature,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 25,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      description: Row(
                        children: [
                          Expanded(
                            child: Text(
                                AppLocalizations.of(context)
                                    .globalChallengeFeatureDescription,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                          ),
                        ],
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      targetColor: Colors.white,
                      textColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with globe icon
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.public,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تحدي مشترك',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'مع جميع المستخدمين',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(top: 12)),
                            // Challenge name
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _globalChallenge
                                    .challenge.azkarChallenge!.name!,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            // Motivation text
                            Visibility(
                              visible: (((_globalChallenge.challenge
                                              .azkarChallenge?.motivation ??
                                          "")
                                      .length) !=
                                  0),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: AutoSizeText(
                                  _globalChallenge.challenge.azkarChallenge
                                          ?.motivation ??
                                      "",
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  ),
                                  textAlign: TextAlign.start,
                                  minFontSize: 16,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 12)),
                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Repeatable indicator
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.amber.shade700,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        color: Colors.amber.shade900,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'قابل للتكرار',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Finished count
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          ArabicUtils.englishToArabic(
                                              _globalChallenge.finishedCount
                                                  .toString()),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        Text(
                                          'مشاركات',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 8)),
                                    Icon(
                                      Icons.groups,
                                      color: Colors.green.shade700,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            // Deadline
                            ChallengeWidgetUtil.getDeadlineText(
                                context, _globalChallenge.challenge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return ChallengeListItemLoadingWidget();
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
