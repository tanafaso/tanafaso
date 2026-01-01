import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/models/challenge.dart';
import 'package:flutter/material.dart';

class FriendsProgressWidget extends StatefulWidget {
  final Challenge challenge;
  final List<String> challengedUsersIds;
  final List<String> challengedUsersFullNames;
  final int fontSize;
  final int iconSize;

  FriendsProgressWidget({
    required this.challenge,
    required this.challengedUsersIds,
    required this.challengedUsersFullNames,
    this.fontSize = 25,
    this.iconSize = 25,
  });

  @override
  _FriendsProgressWidgetState createState() => _FriendsProgressWidgetState();
}

class _FriendsProgressWidgetState extends State<FriendsProgressWidget> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView.separated(
          padding: EdgeInsets.all(0),
          separatorBuilder: (BuildContext context, int index) => Divider(),
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: widget.challengedUsersIds.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: getFriendProgressOnChallengeIcon(
                      widget.challengedUsersIds[index]),
                ),
                Flexible(
                  child: AutoSizeText(
                    widget.challengedUsersFullNames[index],
                    style: TextStyle(
                      fontSize: widget.fontSize.toDouble(),
                    ),
                    maxLines: 1,
                  ),
                ),
                Visibility(
                  visible: widget.challengedUsersIds[index] ==
                      widget.challenge.creatingUserId(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.create,
                      size: widget.iconSize.toDouble(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getFriendProgressOnChallengeIcon(String userId) {
    if (widget.challenge
        .getUsersFinishedIds()
        .any((userFinished) => userFinished == userId)) {
      return Icon(
        Icons.done_outline,
        size: widget.iconSize.toDouble(),
        color: Colors.green,
      );
    }

    if (widget.challenge.deadlinePassed()) {
      return Icon(
        Icons.error_outline,
        size: widget.iconSize.toDouble(),
        color: Colors.red,
      );
    }

    return Icon(
      Icons.not_started,
      size: widget.iconSize.toDouble(),
      color: Colors.yellow.shade600,
    );
  }
}
