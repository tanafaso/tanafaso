import 'package:azkar/models/friend.dart';
import 'package:azkar/net/api_exception.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/core_views/home/create_challenge/create_challenge_screen.dart';
import 'package:flutter/material.dart';

typedef OnToggleViewCallback = void Function();
typedef OnFriendDeletedCallback = void Function();

class DetailedFriendListItemWidget extends StatelessWidget {
  final Friend friendshipScore;
  final OnToggleViewCallback toggleViewCallback;
  final OnFriendDeletedCallback onFriendDeletedCallback;

  DetailedFriendListItemWidget({
    required this.friendshipScore,
    required this.toggleViewCallback,
    required this.onFriendDeletedCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 4.0, right: 4.0),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // margin: EdgeInsets.all(0),
        fillColor: Colors.white,
        onPressed: () {
          toggleViewCallback.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${friendshipScore.firstName} ${friendshipScore.lastName}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 4)),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(left: 8)),
                                        Text(
                                          "@" + friendshipScore.username,
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                          top: 8,
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context).yourFriend,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 4)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        friendshipScore.friendTotalScore
                                            .toString(),
                                        style: TextStyle(
                                            color: getColor(), fontSize: 25),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context).you,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 4)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        friendshipScore.userTotalScore
                                            .toString(),
                                        style: TextStyle(
                                          color: getColor(),
                                          fontSize: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 8)),
                        RawMaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            fillColor: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CreateChallengeScreen(
                                        initiallySelectedFriends: [
                                          friendshipScore
                                        ],
                                      )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined),
                                  Padding(padding: EdgeInsets.only(left: 8)),
                                  Text(
                                    AppLocalizations.of(context)
                                        .challengeThisFriend,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            )),
                        Visibility(
                          visible: friendshipScore.username != "sabeq",
                          child: RawMaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              fillColor: Colors.grey,
                              onPressed: () async {
                                bool deleted =
                                    await _showDeleteFriendAlertDialog(
                                            context) ??
                                        false;
                                if (deleted) {
                                  onFriendDeletedCallback.call();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.white,
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 8)),
                                    Text(
                                      "حذف هذا الصديق",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
    );
  }

  Future<bool?> _showDeleteFriendAlertDialog(BuildContext context) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف صديق'),
          content: SingleChildScrollView(
            child: Text('هل تريد حقا حذف هذا الصديق؟'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text(
                'نعم',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                try {
                  await ServiceProvider.usersService
                      .deleteFriend(friendshipScore.userId);
                } on ApiException catch (e) {
                  SnackBarUtils.showSnackBar(
                      context, e.errorStatus.errorMessage);
                }
                Navigator.of(context).pop(/*deleted=*/ true);
              },
            ),
            ElevatedButton(
              child: const Text(
                'لا',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(/*deleted=*/ false);
              },
            ),
          ],
        );
      },
    );
  }

  Color getColor() {
    if (friendshipScore.friendTotalScore > friendshipScore.userTotalScore!) {
      return Colors.red;
    } else if (friendshipScore.friendTotalScore <
        friendshipScore.userTotalScore!) {
      return Colors.green;
    }
    return Colors.yellow.shade700;
  }
}
