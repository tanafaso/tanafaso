import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
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
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'المواظبة',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            // ignore: missing_required_param
                            child: SlideOdometerTransition(
                              letterWidth: 30,
                              odometerAnimation: consecutiveDaysAnimation,
                              numberTextStyle: const TextStyle(
                                fontSize: 45,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 16)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'الإنجازات',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: SlideOdometerTransition(
                              letterWidth: 30,
                              odometerAnimation: finishedCountAnimation,
                              numberTextStyle: const TextStyle(
                                fontSize: 45,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
