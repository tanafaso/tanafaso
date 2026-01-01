package com.azkar.payload.authenticationcontroller.requests;

import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.exceptions.BadRequestException;

public class EmailAuthenticationRequestBodyUtil {

  public static final int MINIMUM_PASSWORD_CHARACTERS = 8;

  // For more information regarding the regex used for email validation, please refer to:
  // https://www.tutorialspoint.com/validate-email-address-in-java
  public static void validateEmail(String email) throws BadRequestException {
    String regex = "^[\\w-_\\.+]*[\\w-_\\.]\\@([\\w]+\\.)+[\\w]+[\\w]$";
    if (!email.matches(regex)) {
      throw new BadRequestException(new Status(Status.EMAIL_NOT_VALID_ERROR));
    }
  }

  public static void validatePassword(String password) throws BadRequestException {
    if (password.length() < MINIMUM_PASSWORD_CHARACTERS) {
      throw new BadRequestException(new Status(Status.PASSWORD_CHARACTERS_LESS_THAN_8_ERROR));
    }
  }

  public static void validateName(String name) throws BadRequestException {
    if (name.isEmpty()) {
      throw new BadRequestException(new Status(Status.NAME_EMPTY_ERROR));
    }
  }
}
