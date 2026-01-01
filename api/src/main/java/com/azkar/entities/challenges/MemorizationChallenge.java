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
@Document(collection = "memorization_challenges")
public class MemorizationChallenge extends ChallengeBase {

  @NotNull
  private List<Question> questions;
  @NotNull
  private int difficulty;
  @NotNull
  private int firstJuz;
  @NotNull
  private int lastJuz;
  @NotNull
  private int firstSurah;
  @NotNull
  private int lastSurah;

  public boolean finished() {
    return !questions.stream().anyMatch(question -> !question.isFinished());
  }

  @Getter
  @Setter
  @NoArgsConstructor
  @AllArgsConstructor
  @Builder(toBuilder = true)
  public static class Question {

    @NotNull
    private int number;
    @NotNull
    private int juz;
    @NotNull
    private int ayah;
    @NotNull
    private int surah;
    @NotNull
    private int firstAyahInRub;
    @NotNull
    private int firstAyahInJuz;
    @NotNull
    @NotNull
    private List<Integer> wrongPreviousAyahOptions;
    @NotNull
    private List<Integer> wrongNextAyahOptions;
    @NotNull
    private List<Integer> wrongFirstAyahInRubOptions;
    @NotNull
    private List<Integer> wrongFirstAyahInJuzOptions;
    @NotNull
    private List<Integer> wrongSurahOptions;
    private boolean finished = false;
  }
}
