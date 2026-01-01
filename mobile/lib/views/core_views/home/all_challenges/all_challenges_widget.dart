import 'package:azkar/models/challenge.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/group.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snapshot_utils.dart';
import 'package:azkar/views/core_views/home/all_challenges/challenge_list_item_loading_widget.dart';
import 'package:azkar/views/core_views/home/all_challenges/challenge_list_item_widget.dart';
import 'package:azkar/views/core_views/home/all_challenges/global_challenge_widget.dart';
import 'package:azkar/views/core_views/home/home_main_screen.dart';
import 'package:azkar/views/keys.dart';
import 'package:flutter/material.dart';

class AllChallengesWidget extends StatefulWidget {
  final ReloadHomeMainScreenCallback reloadHomeMainScreenCallback;

  AllChallengesWidget({required this.reloadHomeMainScreenCallback});

  @override
  _AllChallengesWidgetState createState() => _AllChallengesWidgetState();
}

class _AllChallengesWidgetState extends State<AllChallengesWidget> {
  late List<Challenge> challenges;
  late List<Group> groups;
  late List<Friend> friends;

  Future<void> getNeededData() async {
    try {
      await ServiceProvider.homeService.getHomeDataAndCacheIt();
      challenges = await ServiceProvider.challengesService.getAllChallenges();
      groups = await ServiceProvider.groupsService.getGroups();
      friends = await ServiceProvider.usersService.getFriendsLeaderboard();
      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: FutureBuilder<void>(
          future: getNeededData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            List<Widget> children;
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError) {
              return getChallengesListWidget(challenges, groups, friends);
            } else if (snapshot.hasError) {
              children = <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SnapshotUtils.getErrorWidget(context, snapshot),
                )
              ];
            } else {
              children =
                  List.generate(3, (_) => ChallengeListItemLoadingWidget());
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getChallengesListWidget(List<Challenge> challenges, List<Group> groups,
      List<Friend> friendshipScores) {
    if (challenges.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noChallengesFound,
          key: Keys.allChallengesWidgetNoChallengesFoundKey,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () {
        ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
        setState(() {});
        return Future.value();
      },
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: ListView.builder(
          addAutomaticKeepAlives: true,
          // Cache half screen after and half screen before the current screen.
          cacheExtent: MediaQuery.of(context).size.height * 0.5,
          itemCount: challenges.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return GlobalChallengeWidget(
                reloadHomeMainScreenCallback: () {
                  widget.reloadHomeMainScreenCallback();
                },
              );
            }
            Challenge challenge = challenges[index - 1];
            return ChallengeListItemWidget(
              key: Key(challenge.getId()!),
              challenge: challenge,
              group: groups
                  .firstWhere((group) => group.id == challenge.getGroupId()),
              firstChallengeInList: index == 1,
              friendshipScores: friendshipScores,
              reloadHomeMainScreenCallback: () {
                widget.reloadHomeMainScreenCallback();
              },
            );
          },
        ),
      ),
    );
  }
}
