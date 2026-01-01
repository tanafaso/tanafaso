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
public class AddMemorizationChallengeRequest extends RequestBodyBase {

  private static int MINIMUM_DIFFICULTY_LEVEL = 1;
  private static int MAXIMUM_DIFFICULTY_LEVEL = 3;
  private static int MINIMUM_NUMBER_OF_QUESTIONS = 1;
  private static int MAXIMUM_NUMBER_OF_QUESTIONS = 10;
  private static int MINIMUM_JUZ_NUM = 1;
  private static int MAXIMUM_JUZ_NUM = 30;

  private static int MINIMUM_SURAH_NUM = 2;
  private static int MAXIMUM_SURAH_NUM = 57;
  private List<String> friendsIds;
  private long expiryDate;

  private int difficulty;
  private int firstJuz;
  private int lastJuz;
  private int firstSurah;
  private int lastSurah;
  private int numberOfQuestions;

  @Override
  public void validate() throws BadRequestException {
    ChallengeValidationUtil.validateExpiryDate(expiryDate);
    validateFriendIds();
    validateDifficulty();
    validateNumberOfQuestions();
    // Either Juz range or Surah range should be specified
    if (firstJuz == 0 && lastJuz == 0) {
      validateSurahs();
    } else if (firstSurah == 0 && lastSurah == 0) {
      validateJuzs();
    }
  }

  private void validateFriendIds() {
    if (new HashSet<>(friendsIds).size() != friendsIds.size()) {
      throw new BadRequestException(new Status(Status.DUPLICATE_FRIEND_IDS_PROVIDED_ERROR));
    }
  }

  private void validateDifficulty() {
    if (difficulty > MAXIMUM_DIFFICULTY_LEVEL || difficulty < MINIMUM_DIFFICULTY_LEVEL) {
      throw new BadRequestException(
          new Status(Status.MEMORIZATION_CHALLENGE_DIFFICULTY_LEVEL_INVALID_ERROR));
    }
  }

  private void validateJuzs() {
    if (firstJuz > lastJuz || firstJuz < MINIMUM_JUZ_NUM || lastJuz > MAXIMUM_JUZ_NUM) {
      throw new BadRequestException(
          new Status(Status.MEMORIZATION_CHALLENGE_JUZ_RANGE_INVALID_ERROR));
    }
  }

  private void validateSurahs() {
    if (firstSurah > lastSurah || firstSurah < MINIMUM_SURAH_NUM || lastSurah > MAXIMUM_SURAH_NUM) {
      throw new BadRequestException(
          new Status(Status.MEMORIZATION_CHALLENGE_SURAH_RANGE_INVALID_ERROR));
    }
  }

  private void validateNumberOfQuestions() {
    if (numberOfQuestions < MINIMUM_NUMBER_OF_QUESTIONS
        || numberOfQuestions > MAXIMUM_NUMBER_OF_QUESTIONS) {
      throw new BadRequestException(
          new Status(Status.MEMORIZATION_CHALLENGE_NUMBER_OF_QUESTIONS_INVALID_ERROR));
    }
  }
}
