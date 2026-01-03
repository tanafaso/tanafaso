import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/arabic_utils.dart';
import 'package:azkar/utils/snapshot_utils.dart';
import 'package:azkar/views/core_views/home/user_progress/user_progress_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:odometer/odometer.dart';

class UserProgressWidget extends StatefulWidget {
  UserProgressWidget();

  @override
  State<UserProgressWidget> createState() => _UserProgressWidgetState();
}

class _UserProgressWidgetState extends State<UserProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<OdometerNumber> finishedCountAnimation;
  late Animation<OdometerNumber> consecutiveDaysAnimation;

  Future<void> getNeededData() async {
    try {
      int finishedCount =
          await ServiceProvider.challengesService.getFinishedChallengesCount();
      int consecutiveDays =
          await ServiceProvider.challengesService.getConsecutiveDaysStreak();
      finishedCountAnimation = OdometerTween(
              begin: OdometerNumber(0), end: OdometerNumber(finishedCount))
          .animate(
        CurvedAnimation(curve: Curves.easeIn, parent: animationController),
      );
      consecutiveDaysAnimation = OdometerTween(
              begin: OdometerNumber(0), end: OdometerNumber(consecutiveDays))
          .animate(
        CurvedAnimation(curve: Curves.easeIn, parent: animationController),
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  void initState() {
    animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    animationController.reset();
    return FutureBuilder(
        future: getNeededData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            animationController.forward();

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600
                            ],
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'المواظبة',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AnimatedBuilder(
                                animation: consecutiveDaysAnimation,
                                builder: (context, child) {
                                  return Text(
                                    ArabicUtils.englishToArabic(
                                        consecutiveDaysAnimation.value.number
                                            .toString()),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'يوم',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.orange.shade300,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'الإنجازات',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AnimatedBuilder(
                                animation: finishedCountAnimation,
                                builder: (context, child) {
                                  return Text(
                                    ArabicUtils.englishToArabic(
                                        finishedCountAnimation.value.number
                                            .toString()),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تحدي',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return (snapshot.error is ApiException)
                ? Container()
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(2 * 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                SnapshotUtils.getErrorWidget(context, snapshot),
                          ),
                        ],
                      ),
                    ),
                  );
          } else {
            return UserProgressLoadingWidget();
          }
        });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
