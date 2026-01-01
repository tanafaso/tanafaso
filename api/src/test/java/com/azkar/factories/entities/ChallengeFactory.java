package com.azkar.factories.entities;

import com.azkar.entities.Zekr;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge.SurahSubChallenge;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import org.bson.types.ObjectId;

public class ChallengeFactory {

  public static final String CHALLENGE_NAME_BASE = "challenge_name";
  public final static String CHALLENGE_MOTIVATION = "challenge_motivation";
  public final static long EXPIRY_DATE_OFFSET = 60 * 60;
  private static int challengesRequested = 0;

  public static SubChallenge azkarSubChallenge1() {
    return SubChallenge.builder()
        .zekr(Zekr.builder().id(1).zekr("zekr").build())
        .repetitions(3)
        .build();
  }

  public static SubChallenge azkarSubChallenge2() {
    return SubChallenge.builder()
        .zekr(Zekr.builder().id(2).zekr("zekr2").build())
        .repetitions(5)
        .build();
  }

  public static SurahSubChallenge quranSubChallenge1() {
    return SurahSubChallenge.builder()
        .surahName("name1")
        .startingVerseNumber(1)
        .endingVerseNumber(3)
        .build();
  }

  public static SurahSubChallenge quranSubChallenge2() {
    return SurahSubChallenge.builder()
        .surahName("name2")
        .startingVerseNumber(3)
        .endingVerseNumber(5)
        .build();
  }

  public static AzkarChallenge getNewChallenge(String groupId) {
    return getNewChallenge(/* namePrefix= */ "", groupId);
  }

  public static AzkarChallenge getNewChallenge(String namePrefix, String groupId) {
    long expiryDate = Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET;
    String challengeFullName = namePrefix + CHALLENGE_NAME_BASE + ++challengesRequested;
    return AzkarChallenge.builder()
        .id(challengeFullName)
        .name(challengeFullName)
        .motivation(CHALLENGE_MOTIVATION)
        .expiryDate(expiryDate)
        .subChallenges(ImmutableList.of(azkarSubChallenge1(), azkarSubChallenge2()))
        .groupId(groupId)
        .build();
  }

  public static ReadingQuranChallenge getNewReadingChallenge(String groupId) {
    long expiryDate = Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET;
    return ReadingQuranChallenge.builder()
        .id(new ObjectId().toString())
        .expiryDate(expiryDate)
        .surahSubChallenges(ImmutableList.of(quranSubChallenge1(), quranSubChallenge2()))
        .groupId(groupId)
        .build();
  }
}
