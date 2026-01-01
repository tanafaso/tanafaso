import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSnackBar(BuildContext context, String message,
      {Color color = Colors.black,
      Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: duration,
    ));
  }
}
