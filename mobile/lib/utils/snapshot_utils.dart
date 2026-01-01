import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/status.dart';
import 'package:flutter/material.dart';

class SnapshotUtils {
  static Widget getErrorWidget(
      BuildContext context, AsyncSnapshot<void> snapshot) {
    String error;
    if (snapshot.error is ApiException) {
      error = (snapshot.error as ApiException).errorStatus.errorMessage;
    } else {
      error = Status.getDefaultApiErrorStatus().errorMessage;
    }
    return Text(
      error,
      textAlign: TextAlign.center,
    );
  }
}
