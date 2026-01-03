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
                padding: const EdgeInsets.only(bottom: 4),
                child: RawMaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(0),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoGlobalChallengeScreen(
                                globalChallenge: _globalChallenge,
                                reloadHomeMainScreenCallback:
                                    widget.reloadHomeMainScreenCallback,
                              ))),
                  elevation: 3.0,
                  fillColor: Colors.white,
                  child: DescribedFeatureOverlay(
                    key: Key(Features.GLOBAL_CHALLENGE),
                    featureId: Features.GLOBAL_CHALLENGE,
                    overflowMode: OverflowMode.wrapBackground,
                    contentLocation: ContentLocation.below,
                    barrierDismissible: false,
                    backgroundDismissible: false,
                    tapTarget: Icon(Icons.public),
                    // The widget that will be displayed as the tap target.
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
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.public, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'تحدي مشترك لجميع المستخدمين',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Padding(padding: EdgeInsets.only(right: 8)),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _globalChallenge
                                        .challenge.azkarChallenge!.name!,
                                    style: TextStyle(fontSize: 35),
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(right: 8)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Visibility(
                            visible: (((_globalChallenge.challenge
                                            .azkarChallenge?.motivation ??
                                        "")
                                    .length) !=
                                0),
                            child: AutoSizeText(
                              _globalChallenge
                                      .challenge.azkarChallenge?.motivation ??
                                  "",
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 3,
                              style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.start,
                              minFontSize: 25,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      size: 25,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'أُنهي ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      ArabicUtils.englishToArabic(
                                          _globalChallenge.finishedCount
                                              .toString()),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      ' مرة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'يمكن إنهاؤه أكثر من مرة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                      size: 20),
                                  SizedBox(width: 6),
                                  ChallengeWidgetUtil.getDeadlineText(
                                      context, _globalChallenge.challenge),
                                ],
                              ),
                            ))
                      ],
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
