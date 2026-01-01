package com.azkar.payload;

import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.exceptions.BadRequestException;
import java.util.Arrays;
import java.util.Objects;

public abstract class RequestBodyBase {

  public static void checkNotNull(Object... arguments) throws BadRequestException {
    if (Arrays.stream(arguments).anyMatch(Objects::isNull)) {
      throw new BadRequestException(new Status(Status.REQUIRED_FIELDS_NOT_GIVEN_ERROR));
    }
  }

  public abstract void validate() throws BadRequestException;
}
