import 'package:azkar/models/friend.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/create_challenge/select_friend/select_friends_screen.dart';
import 'package:flutter/material.dart';

typedef OnSelectedFriendsChanged = void Function(
    List<Friend> newSelectedFriends);

class SelectedFriendsWidget extends StatefulWidget {
  final List<Friend> initiallySelectedFriends;
  final OnSelectedFriendsChanged onSelectedFriendsChanged;
  final ScrollController? scrollController;

  SelectedFriendsWidget({
    this.initiallySelectedFriends = const [],
    required this.onSelectedFriendsChanged,
    this.scrollController,
  });

  @override
  _SelectedFriendsWidgetState createState() => _SelectedFriendsWidgetState();
}

class _SelectedFriendsWidgetState extends State<SelectedFriendsWidget>
    with AutomaticKeepAliveClientMixin {
  late List<Friend> _selectedFriends;

  @override
  void initState() {
    super.initState();

    _selectedFriends = widget.initiallySelectedFriends;
  }

  @override
  Widget build(BuildContext context) {
    // Necessary as documented by AutomaticKeepAliveClientMixin.
    super.build(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.person,
                    size: 25,
                  ),
                ),
                Flexible(child: getTitle()),
                Padding(padding: EdgeInsets.only(left: 16)),
              ],
            ),
            Visibility(
              visible: (_selectedFriends.length ?? 0) != 0,
              maintainSize: false,
              child: getSelectedFriends(),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ButtonStyle(
                    elevation: WidgetStateProperty.resolveWith((states) => 10),
                    shape: WidgetStateProperty.resolveWith((_) =>
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)))),
                onPressed: () async {
                  List<Friend> friends;
                  try {
                    friends = await ServiceProvider.usersService
                        .getFriendsLeaderboard();
                  } on ApiException catch (e) {
                    SnackBarUtils.showSnackBar(
                      context,
                      e.errorStatus.errorMessage,
                    );
                    return;
                  }
                  List<Friend> selectedFriends = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectFriendsScreen(
                        friends: friends,
                      ),
                    ),
                  ) as List<Friend>;

                  setState(() {
                    _selectedFriends =
                        selectedFriends == null ? [] : selectedFriends;
                    widget.onSelectedFriendsChanged(_selectedFriends);
                  });
                },
                child: _getSelectFriendsIcon(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    String text;
    Color color;
    if ((_selectedFriends.length ?? 0) == 0) {
      text = AppLocalizations.of(context).noFriendsSelected;
      color = Colors.pink;
    } else {
      text = AppLocalizations.of(context).selectedFriends;
      color = Colors.black;
    }
    return FittedBox(
      child: Text(
        text,
        style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: color),
      ),
    );
  }

  Widget getSelectedFriends() {
    return SizedBox(
      child: Container(
        margin: EdgeInsets.only(left: 8 * 3.0, right: 8),
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 8),
          child: ListView.separated(
            primary: false,
            controller: widget.scrollController ?? ScrollController(),
            separatorBuilder: (BuildContext context, int index) => Divider(),
            shrinkWrap: true,
            itemCount: _selectedFriends.length,
            itemBuilder: (context, index) {
              return Text(
                '${_selectedFriends[index].firstName} ${_selectedFriends[index].lastName}',
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getSelectFriendsIcon() => (_selectedFriends.length ?? 0) == 0
      ? Icon(Icons.add, color: Theme.of(context).iconTheme.color)
      : Text(
          AppLocalizations.of(context).changeSelectedFriends,
          style: Theme.of(context).textTheme.labelLarge,
        );

  @override
  bool get wantKeepAlive => true;
}
