import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/views/core_views/friends/all_friends/how_to_add_friends_screen.dart';
import 'package:flutter/material.dart';

class NoFriendsFoundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).noFriendsFound,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HowToAddFriendsScreen())),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context).howToAddNewFriendsQuestion,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
