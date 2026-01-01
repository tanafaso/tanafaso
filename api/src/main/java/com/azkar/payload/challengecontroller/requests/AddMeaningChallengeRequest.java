package com.azkar.payload.challengecontroller.requests;

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
public class AddMeaningChallengeRequest extends RequestBodyBase {

  private List<String> friendsIds;
  private long expiryDate;
  private Integer numberOfWords;


  @Override
  public void validate() throws BadRequestException {
    ChallengeValidationUtil.validateExpiryDate(expiryDate);
    validateFriendIds();
    validateNumberOfWords();
  }

  private void validateFriendIds() {
    if (new HashSet<>(friendsIds).size() != friendsIds.size()) {
      throw new BadRequestException(new Status(Status.DUPLICATE_FRIEND_IDS_PROVIDED_ERROR));
    }
  }

  private void validateNumberOfWords() {
    if (numberOfWords == null) {
      // Default is 3.
      return;
    }
    if (numberOfWords.intValue() < 3 || numberOfWords.intValue() > 9) {
      throw new BadRequestException(
          new Status(Status.TAFSEER_CHALLENGE_INCORRECT_NUMBER_OF_WORDS_ERROR));
    }
  }
}
