package com.azkar.payload.exceptions;

import com.azkar.payload.ResponseBase.Status;

public class BadRequestException extends RuntimeException {

  public Status error;

  public BadRequestException(Status status) {
    super("Bad Request");
    this.error = status;
  }
}
