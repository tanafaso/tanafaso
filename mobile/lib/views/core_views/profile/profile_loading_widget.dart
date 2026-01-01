import 'package:auto_size_text/auto_size_text.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: LineWidget(width: 10),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(top: 8 * 3.0)),
                  RawMaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.white,
                    onPressed: () {},
                    // elevation: 15,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'كود المستخدم',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: LineWidget(width: 5),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTapDown: (_) {},
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      size: 25,
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 8)),
                                    LineWidget(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: true,
                                child: Expanded(
                                  child: GestureDetector(
                                    onTapDown: (_) {},
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.share,
                                            size: 25,
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8)),
                                          LineWidget(width: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(10)),
              Container(
                child: ButtonTheme(
                  height: 50,
                  // ignore: deprecated_member_use
                  child: RawMaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.grey,
                    onPressed: () async {},
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AutoSizeText(
                        AppLocalizations.of(context).logout,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(10)),
              Container(
                child: ButtonTheme(
                  height: 50,
                  // ignore: deprecated_member_use
                  child: RawMaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.red.shade600,
                    onPressed: () async {},
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AutoSizeText(
                        "مسح الحساب",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                  ),
                ),
              ),
            ],
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
