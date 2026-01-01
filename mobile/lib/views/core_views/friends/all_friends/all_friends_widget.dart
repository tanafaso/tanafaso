import 'package:azkar/models/friend.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/views/core_views/friends/all_friends/friend_list_item_widget.dart';
import 'package:azkar/views/core_views/friends/all_friends/no_friends_found_widget.dart';
import 'package:azkar/views/keys.dart';
import 'package:flutter/material.dart';

typedef OnRefreshRequested = void Function();

class AllFriendsWidget extends StatefulWidget {
  final List<Friend> friendshipScores;
  final OnRefreshRequested onRefreshRequested;

  AllFriendsWidget(
      {required this.friendshipScores, required this.onRefreshRequested});

  @override
  _AllFriendsWidgetState createState() => _AllFriendsWidgetState();
}

class _AllFriendsWidgetState extends State<AllFriendsWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.friendshipScores.isEmpty) {
      return NoFriendsFoundWidget();
    }

    return RefreshIndicator(
      onRefresh: () {
        ServiceProvider.cacheManager.invalidateFrequentlyChangingData();
        // Just to force parents to reload.
        widget.onRefreshRequested();
        return Future.value();
      },
      color: Colors.black,
      child: ListView.builder(
        key: Keys.allFriendsWidgetListKey,
        itemCount: widget.friendshipScores.length,
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return FriendListItemWidget(
            friendshipScores: widget.friendshipScores[index],
            onFriendDeletedCallback: () {
              widget.onRefreshRequested();
            },
          );
        },
      ),
    );
  }
}
