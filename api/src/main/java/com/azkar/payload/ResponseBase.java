package com.azkar.payload;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
public abstract class ResponseBase<T> {

  T data;
  Status status = new Status(Status.SUCCESS);

  // NOTE: Please always adapt the API clients for any new error code added.
  @Getter
  @NoArgsConstructor
  @Setter
  public static class Status {

    public static final int SUCCESS = 1000000;
    public static final int USER_ALREADY_LOGGED_IN_ERROR = 1;
    public static final int EMAIL_PASSWORD_COMBINATION_ERROR = 2;
    public static final int LOGIN_WITH_EMAIL_ERROR = 3;
    public static final int EMAIL_NOT_VERIFIED_ERROR = 4;
    public static final int USER_ALREADY_REGISTERED_ERROR = 5;
    public static final int USER_ALREADY_REGISTERED_WITH_FACEBOOK = 6;
    public static final int PIN_ALREADY_SENT_TO_USER_ERROR = 7;
    public static final int EMAIL_ALREADY_VERIFIED_ERROR = 8;
    public static final int VERIFICATION_ERROR = 9;
    public static final int AUTHENTICATION_WITH_FACEBOOK_ERROR = 10;
    public static final int SOMEONE_ELSE_ALREADY_CONNECTED_ERROR = 11;
    public static final int AUTHENTICATION_ERROR = 12;
    public static final int GROUP_NOT_FOUND_ERROR = 13;
    public static final int NOT_GROUP_MEMBER_ERROR = 14;
    public static final int CHALLENGE_NOT_FOUND_ERROR = 15;
    public static final int NON_GROUP_MEMBER_ERROR = 16;
    public static final int INCREMENTING_LEFT_REPETITIONS_ERROR = 17;
    public static final int NON_EXISTENT_SUB_CHALLENGE_ERROR = 18;
    public static final int MISSING_OR_DUPLICATED_SUB_CHALLENGE_ERROR = 19;
    public static final int CHALLENGE_EXPIRED_ERROR = 20;
    public static final int REQUIRED_FIELDS_NOT_GIVEN_ERROR = 21;
    public static final int DEFAULT_ERROR = 22;
    public static final int GROUP_INVALID_ERROR = 23;
    public static final int USER_ALREADY_MEMBER_ERROR = 24;
    public static final int USER_NOT_INVITED_ERROR = 25;
    public static final int NOT_MEMBER_IN_GROUP_ERROR = 26;
    public static final int INVITED_USER_INVALID_ERROR = 27;
    public static final int INVITING_USER_IS_NOT_MEMBER_ERROR = 28;
    public static final int INVITED_USER_ALREADY_MEMBER_ERROR = 29;
    public static final int USER_ALREADY_INVITED_ERROR = 30;
    public static final int NOT_MEMBER_ERROR = 31;
    public static final int ERROR_USER_NOT_FOUND = 32;
    public static final int USER_NOT_FOUND_ERROR = 33;
    public static final int FRIENDSHIP_ALREADY_REQUESTED_ERROR = 34;
    public static final int ADD_SELF_ERROR = 35;
    public static final int NO_FRIENDSHIP_ERROR = 36;
    public static final int SEARCH_PARAMETERS_NOT_SPECIFIED = 37;
    public static final int NO_FRIEND_REQUEST_EXIST_ERROR = 38;
    public static final int FRIEND_REQUEST_ALREADY_ACCEPTED_ERROR = 39;
    public static final int PAST_EXPIRY_DATE_ERROR = 40;
    public static final int MALFORMED_SUB_CHALLENGES_ERROR = 41;
    public static final int EMPTY_GROUP_NAME_ERROR = 42;
    public static final int EMAIL_NOT_VALID_ERROR = 43;
    public static final int NAME_EMPTY_ERROR = 44;
    public static final int PASSWORD_CHARACTERS_LESS_THAN_8_ERROR = 45;
    public static final int CHALLENGE_CREATION_DUPLICATE_ZEKR_ERROR = 46;
    public static final int INVALID_RESET_PASSWORD_TOKEN_ERROR = 47;
    public static final int ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR = 48;
    public static final int LESS_THAN_TWO_FRIENDS_ARE_PROVIDED_ERROR = 49;
    public static final int DUPLICATE_FRIEND_IDS_PROVIDED_ERROR = 50;
    public static final int CHALLENGE_HAS_ALREADY_BEEN_FINISHED = 51;
    public static final int TAFSEER_CHALLENGE_INCORRECT_NUMBER_OF_WORDS_ERROR = 52;
    public static final int CANNOT_REMOVE_SABEQ__FROM_FRIENDS_ERROR = 53;
    public static final int STARTING_VERSE_AFTER_ENDING_VERSE_ERROR = 54;
    public static final int USER_NOT_ADDED_TO_PUBLICLY_AVAILABLE_USERS_ERROR = 55;
    public static final int USER_ALREADY_IS_PUBLICLY_AVAILABLE_USER_ERROR = 56;
    public static final int FACEBOOK_RETURNED_NULL_EMAIL_ADDRESS_ERROR = 57;
    public static final int AUTHENTICATION_WITH_GOOGLE_ERROR = 58;
    public static final int MEMORIZATION_CHALLENGE_DIFFICULTY_LEVEL_INVALID_ERROR = 59;
    public static final int MEMORIZATION_CHALLENGE_JUZ_RANGE_INVALID_ERROR = 60;
    public static final int MEMORIZATION_CHALLENGE_NUMBER_OF_QUESTIONS_INVALID_ERROR = 61;
    public static final int MEMORIZATION_QUESTION_HAS_ALREADY_BEEN_FINISHED = 62;
    public static final int AUTHENTICATION_WITH_APPLE_ERROR = 63;
    public static final int CUSTOM_SIMPLE_CHALLENGE_DESCRIPTION_EMPTY_ERROR = 64;
    public static final int MEMORIZATION_CHALLENGE_SURAH_RANGE_INVALID_ERROR = 65;
    public int code;

    public Status(int code) {
      this.code = code;
    }
  }
}
