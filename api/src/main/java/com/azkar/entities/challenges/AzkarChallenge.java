package com.azkar.entities.challenges;

import com.azkar.entities.Zekr;
import java.util.List;
import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.springframework.data.mongodb.core.mapping.Document;

@SuperBuilder(toBuilder = true)
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Document(collection = "challenges")
public class AzkarChallenge extends ChallengeBase {

  /**
   * Personal challenges are represented the same way as normal challenges. One difference is that
   * personal challenges are not saved in a particular group. The solution here is to not get rid of
   * the NonNull annotation over the groupId to make sure that we can get the group for every
   * in-group-challenge. To leave the NonNull annotation we have to provide group IDs also for
   * personal challenges. NOTE: This is not used anymore after introducing Sabeq.
   */
  @Deprecated
  public static final String PERSONAL_CHALLENGES_NON_EXISTING_GROUP_ID
      = "non-existing-personal-challenge-group-id";

  private String motivation;
  @NotNull
  private String name;
  @NotNull
  private List<SubChallenge> subChallenges;

  public boolean finished() {
    return !subChallenges.stream().anyMatch(subChallenge -> subChallenge.repetitions != 0);
  }

  @Getter
  @Setter
  @NoArgsConstructor
  @AllArgsConstructor
  @Builder(toBuilder = true)
  public static class SubChallenge {

    private Zekr zekr;
    // Note: This field may have two meanings depending on the context of this SubChallenge. If
    // it is part of a generic Challenge that is saved in the ChallengeRepo then this field means
    // the number of the original repetitions entered on creation. If this is part of the user
    // copy of challenges then it means how many repetitions are left for this zekr for this user.
    private int repetitions;

  }
}
