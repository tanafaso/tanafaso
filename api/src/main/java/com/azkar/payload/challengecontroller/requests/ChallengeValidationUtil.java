package com.azkar.payload.challengecontroller.requests;

import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.exceptions.BadRequestException;
import java.time.Instant;

public class ChallengeValidationUtil {

  public static void validateExpiryDate(long expiryDate) {
    if (expiryDate < Instant.now().getEpochSecond()) {
      throw new BadRequestException(new Status(Status.PAST_EXPIRY_DATE_ERROR));
    }
  }
}
