package com.azkar.entities.challenges;

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
@Document(collection = "reading_quran_challenges")
public class ReadingQuranChallenge extends ChallengeBase {

  @NotNull
  private List<SurahSubChallenge> surahSubChallenges;
  private boolean finished = false;

  @Getter
  @Setter
  @NoArgsConstructor
  @AllArgsConstructor
  @Builder(toBuilder = true)
  public static class SurahSubChallenge {

    private String surahName;
    private int startingVerseNumber;
    private int endingVerseNumber;

  }
}
