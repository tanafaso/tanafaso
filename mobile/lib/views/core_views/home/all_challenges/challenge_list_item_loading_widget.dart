import 'package:azkar/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChallengeListItemLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RawMaterialButton(
        onPressed: () {},
        fillColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[500]!,
          highlightColor: Colors.grey[100]!,
          enabled: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Icon(Icons.not_started),
                    Padding(padding: EdgeInsets.only(right: 16)),
                    LineWidget(
                        width: MediaQuery.of(context).size.width * 1 / 3),
                    Padding(padding: EdgeInsets.only(right: 8)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [],
                            ),
                            Text.rich(TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text:
                                        AppLocalizations.of(context).endsAfter,
                                    style: new TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold)),
                                new TextSpan(
                                  text: ' ... ',
                                ),
                              ],
                            )),
                            // getFriendsNames(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                    ),
                    Icon(
                      Icons.group_sharp,
                      color: Colors.green,
                      size: 45,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
 Widget that represents the lines Loading in the widget.
  */
class LineWidget extends StatelessWidget {
  final double width;

  LineWidget({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: MediaQuery.of(context).size.height / 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
        boxShadow: [
          BoxShadow(color: Colors.black, spreadRadius: 0.2),
        ],
      ),
    );
  }
}
