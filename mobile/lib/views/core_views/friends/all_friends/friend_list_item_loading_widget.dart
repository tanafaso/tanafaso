import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FriendListItemLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 2.0, right: 2.0),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () {},
        fillColor: Colors.white,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[500]!,
          highlightColor: Colors.grey[100]!,
          enabled: true,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height / 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    LineWidget(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: 8)),
                        Icon(
                          Icons.arrow_upward,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
