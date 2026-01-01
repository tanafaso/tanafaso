package com.azkar.entities.challenges;

import lombok.AllArgsConstructor;
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
@Document(collection = "global_challenges")
public class GlobalChallenge extends ChallengeBase {
  private String azkarChallengeIdRef;

  private int finishedCount;
}
