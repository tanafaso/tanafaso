import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/friend.dart';
import 'package:azkar/models/user.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/features.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/utils/snapshot_utils.dart';
import 'package:azkar/views/core_views/friends/add_friend/add_friend_screen.dart';
import 'package:azkar/views/core_views/friends/all_friends/all_friends_widget.dart';
import 'package:azkar/views/core_views/friends/all_friends/friend_list_item_loading_widget.dart';
import 'package:azkar/views/core_views/friends/friend_requests/friend_requests_widget.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FriendsMainScreen extends StatefulWidget {
  @override
  _FriendsMainScreenState createState() => _FriendsMainScreenState();
}

class _FriendsMainScreenState extends State<FriendsMainScreen>
    with TickerProviderStateMixin {
  late UniqueKey allFriendsTabKey;
  late UniqueKey friendRequestsTabKey;

  late List<Tab> friendsTabs;
  late TabController _tabController;
  late bool _addExpanded;

  late List<Friend> _friendshipScores;
  late List<Friend> _pendingFriends;

  late Future<void> _neededData;

  late int _tabIndex;

  late bool isIpad;

  @override
  void initState() {
    super.initState();
    _addExpanded = false;

    allFriendsTabKey = UniqueKey();
    friendRequestsTabKey = UniqueKey();

    _friendshipScores = [];
    _pendingFriends = [];

    _neededData = getNeededData();

    _tabIndex = 0;
  }

  Future<void> getNeededData() async {
    try {
      isIpad = await _isIpad();

      await ServiceProvider.homeService.getHomeDataAndCacheIt();
      _friendshipScores =
          await ServiceProvider.usersService.getFriendsLeaderboard();
      _friendshipScores = _friendshipScores
          .where((friendshipScore) => !friendshipScore.pending)
          .toList();

      List<Friend> friendship =
          await ServiceProvider.usersService.getFriendsLeaderboard();
      _pendingFriends = friendship.where((friend) => friend.pending).toList();
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
    }
  }

  Widget getAllFriendsTabTitle() {
    return AutoSizeText.rich(TextSpan(
      // Note: Styles for TextSpans must be explicitly defined.
      // Child text spans will inherit styles from parent
      style: new TextStyle(color: Colors.black, fontSize: 15),
      children: <TextSpan>[
        new TextSpan(
            text: 'الأصدقاء',
            style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(
          text: ' ',
        ),
        new TextSpan(
            text: '(${_friendshipScores.length.toString()})',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  Widget getFriendRequestsTabTitle() {
    return AutoSizeText.rich(TextSpan(
      // Note: Styles for TextSpans must be explicitly defined.
      // Child text spans will inherit styles from parent
      style: new TextStyle(color: Colors.black, fontSize: 15),
      children: <TextSpan>[
        new TextSpan(
            text: 'طلبات صداقة',
            style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(
          text: ' ',
        ),
        new TextSpan(
            text: '(${_pendingFriends.length.toString()})',
            style: TextStyle(
                color:
                    _pendingFriends.length == 0 ? Colors.black : Colors.green,
                fontWeight: FontWeight.bold)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<void>(
        future: _neededData,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          List<Widget> children;
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            friendsTabs = <Tab>[
              Tab(
                key: allFriendsTabKey,
                child: getAllFriendsTabTitle(),
              ),
              Tab(
                key: friendRequestsTabKey,
                child: getFriendRequestsTabTitle(),
              )
            ];

            _tabController = TabController(
                vsync: this,
                length: friendsTabs.length,
                initialIndex: _tabIndex);
            _tabController.addListener(() {
              setState(() {
                _tabIndex = _tabController.index;
              });
            });
            return getMainWidget();
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
            children = List.generate(5, (_) => FriendListItemLoadingWidget());
          }
          // Add space for the top tap.
          children.insert(
            0,
            Container(
              height: MediaQuery.of(context).size.height / 11,
            ),
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }

  Widget getMainWidget() {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            controller: _tabController,
            tabs: friendsTabs,
            // indicatorColor: Theme.of(context).colorScheme.primary,
            // overlayColor: MaterialStateProperty<Color>().resolve((states) -> Theme.of(context).colorScheme.primary),
          )),
      body: TabBarView(
        controller: _tabController,
        children: friendsTabs.map((Tab tab) {
          if (tab.key == allFriendsTabKey) {
            return AllFriendsWidget(
              friendshipScores: _friendshipScores,
              onRefreshRequested: () {
                setState(() {
                  _neededData = getNeededData();
                });
              },
            );
          } else if (tab.key == friendRequestsTabKey) {
            return FriendRequestsWidget(
              pendingFriends: _pendingFriends,
              onFriendRequestResolvedCallback: () {
                setState(() {
                  _neededData = getNeededData();
                });
              },
            );
          } else {
            assert(false);
            return Container();
          }
        }).toList(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: _addExpanded && !isIpad,
            maintainSize: false,
            maintainState: false,
            child: DescribedFeatureOverlay(
                key: Key(Features.SHARE_USERNAME),
                featureId: Features.SHARE_USERNAME,
                barrierDismissible: false,
                backgroundDismissible: false,
                contentLocation: ContentLocation.above,
                tapTarget: Icon(
                  Icons.share,
                  size: 25,
                ),
                // The widget that will be displayed as the tap target.
                description: Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              child: Text(
                                AppLocalizations.of(context).shareUsernameTitle,
                                maxLines: 1,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                                AppLocalizations.of(context)
                                    .shareUsernameExplanation,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                targetColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.black,
                overflowMode: OverflowMode.wrapBackground,
                child: FloatingActionButton.extended(
                  heroTag: "shareWithFriend",
                  icon: Icon(
                    Icons.share,
                    size: 25,
                  ),
                  label: Text(
                    AppLocalizations.of(context).shareWithFriend,
                    style: TextStyle(fontSize: 25),
                  ),
                  onPressed: () async {
                    User currentUser;
                    try {
                      currentUser =
                          await ServiceProvider.usersService.getCurrentUser();
                    } on ApiException catch (e) {
                      SnackBarUtils.showSnackBar(
                        context,
                        '${AppLocalizations.of(context).error}: ${e.errorStatus.errorMessage}',
                      );
                      return;
                    }
                    Share.share(AppLocalizations.of(context)
                        .shareMessage(currentUser.username));
                  },
                )),
          ),
          Visibility(
              visible: _addExpanded,
              maintainSize: false,
              child: Padding(padding: EdgeInsets.only(bottom: 8.0))),
          Visibility(
            visible: _addExpanded,
            maintainSize: false,
            child: FloatingActionButton.extended(
                heroTag: "addFriend",
                icon: Icon(
                  Icons.add,
                  size: 25,
                ),
                label: Text(
                  AppLocalizations.of(context).addFriend,
                  style: TextStyle(fontSize: 25),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddFriendScreen()));
                }),
          ),
          Visibility(
            visible: !_addExpanded,
            maintainSize: false,
            child: DescribedFeatureOverlay(
                key: Key(Features.ADD_FRIEND),
                featureId: Features.ADD_FRIEND,
                barrierDismissible: false,
                backgroundDismissible: false,
                contentLocation: ContentLocation.above,
                tapTarget: Icon(
                  Icons.add,
                  size: 30,
                ),
                // The widget that will be displayed as the tap target.
                description: Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "إضافة صديق",
                                maxLines: 1,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "اضغط هنا لإضافة صديق جديد أو لمشاركة اسم المستخدم الخاص بك مع صديق أو للعثور على صديق من خلال التطبيق.",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                targetColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.black,
                overflowMode: OverflowMode.wrapBackground,
                child: FloatingActionButton.extended(
                    heroTag: "addFloatingButton",
                    label: Icon(
                      Icons.add,
                      size: 25,
                    ),
                    onPressed: () {
                      setState(() {
                        _addExpanded = true;
                      });
                    })),
          ),
          Visibility(
              visible: _addExpanded,
              maintainSize: false,
              child: Padding(padding: EdgeInsets.only(bottom: 8.0))),
          Visibility(
            visible: _addExpanded,
            maintainSize: false,
            child: FloatingActionButton.extended(
                heroTag: "minimizeAddFriendButtons",
                label: Icon(Icons.close_outlined),
                onPressed: () {
                  setState(() {
                    _addExpanded = false;
                  });
                }),
          ),
        ],
      ),
    );
  }

  Future<bool> _isIpad() async {
    if (!Platform.isIOS) {
      return false;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    if (iosInfo.model.toLowerCase().contains("ipad")) {
      return true;
    }
    return false;
  }
}
