package com.azkar.entities;

import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.CustomSimpleChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.MemorizationChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.ArrayList;
import java.util.List;
import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Builder.Default;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "users")
@Builder(toBuilder = true)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User extends EntityBase {

  // Sabeq is a user that is added by default as a friend for all users so that new users can try
  // the application by sending challenges to sabeq and seeing him on the leaderboard and also so
  // that users can use him to create personal challenges.
  public static final String SABEQ_ID = "60d18088076b0b7d53e5a35a";

  @Indexed
  @Id
  private String id;
  private String email;
  @JsonIgnore
  private String encodedPassword;
  @JsonIgnore
  private String notificationsToken;
  // These Challenge instances are not documents in the challenges collection.
  @Deprecated
  @Default
  private List<AzkarChallenge> personalChallenges = new ArrayList<>();
  private int finishedPersonalChallengesCount;
  @Indexed(name = "username_index")
  private String username;
  @NotNull
  private String firstName;
  @NotNull
  private String lastName;
  private UserFacebookData userFacebookData;
  @Deprecated
  @Default
  private List<UserGroup> userGroups = new ArrayList();
  // Every Challenge instance in this list is a user-customized-copy of a Challenge document in
  // the challenges collection.
  // Use azkarChallenges or meaningChallenges instead.
  @Deprecated
  @Default
  private List<AzkarChallenge> userChallenges = new ArrayList();
  @Default
  private List<AzkarChallenge> azkarChallenges = new ArrayList();
  private int finishedAzkarChallengesCount;
  @Default
  private List<MeaningChallenge> meaningChallenges = new ArrayList();
  private int finishedMeaningChallengesCount;
  @Default
  private List<MemorizationChallenge> memorizationChallenges = new ArrayList();
  private int finishedMemorizationChallengesCount;
  @Default
  private List<ReadingQuranChallenge> readingQuranChallenges = new ArrayList();
  private int finishedReadingQuranChallengesCount;
  @Default
  private List<CustomSimpleChallenge> customSimpleChallenges = new ArrayList();
  private int finishedCustomSimpleChallengesCount;
  @JsonIgnore
  @Default
  private String resetPasswordToken = "";
  @JsonIgnore
  private long resetPasswordTokenExpiryTime;
  @JsonIgnore
  @CreatedDate
  private long createdAt;
  @JsonIgnore
  @LastModifiedDate
  private long updatedAt;

  @Builder
  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class UserGroup {

    @NotNull
    private String groupId;
    // Group name can be empty or null in case it is an auto-generated group.
    private String groupName;
    @NotNull
    private String invitingUserId;
    @Default
    @Deprecated
    private int monthScore = 0;
    @Default
    @Deprecated
    private int totalScore = 0;
  }

  @Builder(toBuilder = true)
  @Data
  @AllArgsConstructor
  public static class UserFacebookData {

    @Indexed(name = "user_facebook_data_index")
    String userId;
    String accessToken;
    String email;
    @NotNull
    String firstName;
    @NotNull
    String lastName;
  }
}
