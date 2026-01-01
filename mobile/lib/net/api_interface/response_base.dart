import 'package:flutter/material.dart';

import 'status.dart';

abstract class ResponseBase {
  Status? error;

  @protected
  setError(Map<String, dynamic> json) {
    if (json['status'] is Map) {
      error = Status((json['status']['code'] ?? Status.API_DEFAULT_ERROR));
    } else if (!json.containsKey('status')){
      error = Status(Status.API_SUCCESS);
    } else {
      error = Status(Status.API_DEFAULT_ERROR);
    }
  }

  void setErrorMessage(int errorCode) {
    error = Status(errorCode);
  }

  String? getErrorMessage() {
    return error?.errorMessage;
  }

  bool hasError() {
    return error == null ? false : error!.code != Status.API_SUCCESS;
  }
}
