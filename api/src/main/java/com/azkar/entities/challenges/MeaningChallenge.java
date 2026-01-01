package com.azkar.entities.challenges;

import java.util.List;
import javax.validation.constraints.NotNull;
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
@Document(collection = "meaning_challenges")
public class MeaningChallenge extends ChallengeBase {

  @NotNull
  private List<String> words;
  @NotNull
  private List<String> meanings;
  private boolean finished = false;

}
