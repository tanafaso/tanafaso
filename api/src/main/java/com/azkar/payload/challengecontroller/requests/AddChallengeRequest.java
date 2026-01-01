package com.azkar.payload.challengecontroller.requests;

import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.exceptions.BadRequestException;
import java.util.HashSet;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Deprecated
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder(toBuilder = true)
public class AddChallengeRequest extends RequestBodyBase {

  protected AzkarChallenge challenge;

  @Override
  public void validate() throws BadRequestException {
    checkNotNull(
        challenge.getName(),
        challenge.getSubChallenges(),
        challenge.getGroupId());

    validateExpiryDate();
    validateSubChallenges();
  }

  protected void validateExpiryDate() {
    if (challenge.expired()) {
      throw new BadRequestException(new Status(Status.PAST_EXPIRY_DATE_ERROR));
    }
  }

  protected void validateSubChallenges() {
    challenge.getSubChallenges().forEach(subChallenges -> {
      if (subChallenges.getRepetitions() <= 0) {
        throw new BadRequestException(new Status(Status.MALFORMED_SUB_CHALLENGES_ERROR));
      }
    });

    HashSet<Integer> foundAzkar = new HashSet<>();
    for (SubChallenge subChallenge : challenge.getSubChallenges()) {
      if (foundAzkar.contains(subChallenge.getZekr().getId())) {
        throw new BadRequestException(new Status(Status.CHALLENGE_CREATION_DUPLICATE_ZEKR_ERROR));
      }
      foundAzkar.add(subChallenge.getZekr().getId());
    }
  }
}