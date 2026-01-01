package com.azkar.payload.challengecontroller.requests;

import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.payload.RequestBodyBase;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.exceptions.BadRequestException;
import java.util.HashSet;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder(toBuilder = true)
public class AddAzkarChallengeRequest extends RequestBodyBase {

  protected AzkarChallenge challenge;
  private List<String> friendsIds;

  @Builder(builderMethodName = "AddFriendsChallengeRequestBuilder")
  public AddAzkarChallengeRequest(List<String> friendsIds, AzkarChallenge challenge) {
    this.challenge = challenge;
    this.friendsIds = friendsIds;
  }

  @Override
  public void validate() throws BadRequestException {
    ChallengeValidationUtil.validateExpiryDate(challenge.getExpiryDate());

    // NOTE: The challenge group ID can be null in this case as the group will be auto-generated.
    checkNotNull(challenge.getName(), challenge.getSubChallenges());

    validateFriendIds();
    validateSubChallenges();
  }

  private void validateFriendIds() {
    if (new HashSet<>(friendsIds).size() != friendsIds.size()) {
      throw new BadRequestException(new Status(Status.DUPLICATE_FRIEND_IDS_PROVIDED_ERROR));
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
