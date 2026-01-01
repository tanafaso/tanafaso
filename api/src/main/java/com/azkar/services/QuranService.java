package com.azkar.services;

import com.azkar.configs.QuranMetadataCacher;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class QuranService {

  private static final Logger logger = LoggerFactory.getLogger(QuranService.class);

  private static final int LAST_AYAH_IN_QURAN = 6236;
  private static final int LAST_JUZ_IN_QURAN = 30;
  private static final int LAST_RUB_IN_QURAN = 240;
  private static final int LAST_SURAH_IN_QURAN = 114;
  private static final int MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS = 50;

  @Autowired
  QuranMetadataCacher quranMetadataCacher;

  public int getFirstAyahInJuz(int juz) {
    return quranMetadataCacher.getFirstAyahsInJuzs().get(juz);
  }

  public int getLastAyahInJuz(int juz) {
    return juz == LAST_JUZ_IN_QURAN ? LAST_AYAH_IN_QURAN :
        quranMetadataCacher.getFirstAyahsInJuzs().get(juz + 1) - 1;
  }


  public int getRandomAyahInJuz(int juz) {
    int firstAyahInJuz = getFirstAyahInJuz(juz);
    int lastAyahInJuz = getLastAyahInJuz(juz);

    // Don't consider the first 3 or the last 3 Ayahs in Juz while choosing a random one to avoid
    // corner cases.
    return getRandomNumberInRange(firstAyahInJuz + 3, lastAyahInJuz - 3);
  }

  public int getFirstAyahInSurah(int surah) {
    return quranMetadataCacher.getFirstAyahsInSurahs().get(surah);
  }

  public int getLastAyahInSurah(int surah) {
    return surah == LAST_SURAH_IN_QURAN ? LAST_AYAH_IN_QURAN :
        quranMetadataCacher.getFirstAyahsInSurahs().get(surah + 1) - 1;
  }


  public int getRandomJuzInRange(int firstJuzInclusive, int lastJuzInclusive) {
    return getRandomNumberInRange(firstJuzInclusive, lastJuzInclusive);
  }

  public int getRandomAyahInSurahRange(int firstSurah, int lastSurah) {
    int firstAyah = getFirstAyahInSurah(firstSurah);
    int lastAyah = getLastAyahInSurah(lastSurah);

    // Don't consider the first 3 or the last 3 Ayahs in Juz while choosing a random one to avoid
    // corner cases.
    return getRandomNumberInRange(firstAyah + 3, lastAyah - 3);
  }

  public List<Integer> getRandomTwoWrongPreviousAyahs(int ayah) {
    int juz = quranMetadataCacher.getAyahsMetadata().get(ayah).getJuz();
    int firstToChooseFrom = Math.max(1, Math.min(ayah - 5, getFirstAyahInJuz(juz)));
    int lastToChooseFrom = ayah - 2;

    int firstWrongOption = getRandomNumberInRange(firstToChooseFrom, lastToChooseFrom);
    Optional<Integer> secondWrongOption = Optional.empty();
    for (int i = 0; i < MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS; i++) {
      int randomWrongOption = getRandomNumberInRange(firstToChooseFrom, lastToChooseFrom);
      if (randomWrongOption != firstWrongOption) {
        secondWrongOption = Optional.of(randomWrongOption);
        break;
      }
    }
    if (!secondWrongOption.isPresent()) {
      logger.error("Couldn't generate two random wrong previous ayahs for ayah: {} after {} "
          + "trials", ayah, MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS);
      List<Integer> ayahs = new ArrayList<>();
      ayahs.add(firstWrongOption);
      ayahs.add(firstWrongOption);
      return ayahs;
    }

    List<Integer> ayahs = new ArrayList<>();
    ayahs.add(firstWrongOption);
    ayahs.add(secondWrongOption.get());
    return ayahs;
  }

  public List<Integer> getRandomTwoWrongNextAyahs(int ayah) {
    int juz = quranMetadataCacher.getAyahsMetadata().get(ayah).getJuz();
    int firstToChooseFrom = ayah + 2;
    int lastToChooseFrom = Math.min(LAST_AYAH_IN_QURAN, Math.max(ayah + 5, getLastAyahInJuz(juz)));

    int firstWrongOption = getRandomNumberInRange(firstToChooseFrom, lastToChooseFrom);
    Optional<Integer> secondWrongOption = Optional.empty();
    for (int i = 0; i < MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS; i++) {
      int randomWrongOption = getRandomNumberInRange(firstToChooseFrom, lastToChooseFrom);
      if (randomWrongOption != firstWrongOption) {
        secondWrongOption = Optional.of(randomWrongOption);
        break;
      }
    }
    if (!secondWrongOption.isPresent()) {
      logger.error("Couldn't generate two random wrong next ayahs for ayah: {} after {} "
          + "trials", ayah, MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS);
      List<Integer> ayahs = new ArrayList<>();
      ayahs.add(firstWrongOption);
      ayahs.add(firstWrongOption);
      return ayahs;
    }

    List<Integer> ayahs = new ArrayList<>();
    ayahs.add(firstWrongOption);
    ayahs.add(secondWrongOption.get());
    return ayahs;
  }

  public List<Integer> getRandomTwoWrongFirstAyahsInRub(int rub) {
    List<Integer> candidateWrongAyahs = new ArrayList<>();
    for (int i = Math.max(1, rub - 3); i <= Math.min(LAST_RUB_IN_QURAN, rub + 3); i++) {
      if (i != rub) {
        candidateWrongAyahs.add(getFirstAyahInRub(i));
      }
    }

    int firstWrongOptionIndex = getRandomNumberInRange(0, candidateWrongAyahs.size() - 1);
    Optional<Integer> secondWrongOptionIndex = Optional.empty();
    for (int i = 0; i < MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS; i++) {
      int randomWrongOption = getRandomNumberInRange(0, candidateWrongAyahs.size() - 1);
      if (randomWrongOption != firstWrongOptionIndex) {
        secondWrongOptionIndex = Optional.of(randomWrongOption);
        break;
      }
    }
    if (!secondWrongOptionIndex.isPresent()) {
      logger.error("Couldn't generate two random wrong first ayahs in rub for ayah: {} after {} "
          + "trials", rub, MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS);
      List<Integer> ayahs = new ArrayList<>();
      ayahs.add(candidateWrongAyahs.get(firstWrongOptionIndex));
      ayahs.add(candidateWrongAyahs.get(firstWrongOptionIndex));
      return ayahs;
    }

    List<Integer> ayahs = new ArrayList<>();
    ayahs.add(candidateWrongAyahs.get(firstWrongOptionIndex));
    ayahs.add(candidateWrongAyahs.get(secondWrongOptionIndex.get()));
    return ayahs;
  }

  public List<Integer> getRandomTwoWrongFirstAyahsInJuz(int juz) {
    List<Integer> candidateWrongAyahs = new ArrayList<>();
    for (int i = Math.max(1, juz - 3); i <= Math.min(LAST_JUZ_IN_QURAN, juz + 3); i++) {
      if (i != juz) {
        candidateWrongAyahs.add(getFirstAyahInJuz(i));
      }
    }

    int firstWrongOptionIndex = getRandomNumberInRange(0, candidateWrongAyahs.size() - 1);
    Optional<Integer> secondWrongOptionIndex = Optional.empty();
    for (int i = 0; i < MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS; i++) {
      int randomWrongOption = getRandomNumberInRange(0, candidateWrongAyahs.size() - 1);
      if (randomWrongOption != firstWrongOptionIndex) {
        secondWrongOptionIndex = Optional.of(randomWrongOption);
        break;
      }
    }
    if (!secondWrongOptionIndex.isPresent()) {
      logger.error("Couldn't generate two random wrong first ayahs in juz for ayah: {} after {} "
          + "trials", juz, MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS);
      List<Integer> ayahs = new ArrayList<>();
      ayahs.add(candidateWrongAyahs.get(firstWrongOptionIndex));
      ayahs.add(candidateWrongAyahs.get(firstWrongOptionIndex));
      return ayahs;
    }

    List<Integer> ayahs = new ArrayList<>();
    ayahs.add(candidateWrongAyahs.get(firstWrongOptionIndex));
    ayahs.add(candidateWrongAyahs.get(secondWrongOptionIndex.get()));
    return ayahs;
  }

  public List<Integer> getRandomTwoWrongSurahsOfAyah(int ayah) {
    int surah = getSurahOfAyah(ayah);
    List<Integer> candidateWrongSurahs = new ArrayList<>();
    for (int i = Math.max(1, surah - 3); i <= Math.min(LAST_SURAH_IN_QURAN, surah + 3); i++) {
      if (i != surah) {
        candidateWrongSurahs.add(i);
      }
    }

    int firstWrongOptionIndex = getRandomNumberInRange(0, candidateWrongSurahs.size() - 1);
    Optional<Integer> secondWrongOptionIndex = Optional.empty();
    for (int i = 0; i < MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS; i++) {
      int randomWrongOption = getRandomNumberInRange(0, candidateWrongSurahs.size() - 1);
      if (randomWrongOption != firstWrongOptionIndex) {
        secondWrongOptionIndex = Optional.of(randomWrongOption);
        break;
      }
    }
    if (!secondWrongOptionIndex.isPresent()) {
      logger.error("Couldn't generate two random wrong surahs for ayah: {} after {} "
          + "trials", ayah, MAXIMUM_TRIALS_FOR_FINDING_WRONG_OPTIONS);
      List<Integer> surahs = new ArrayList<>();
      surahs.add(candidateWrongSurahs.get(firstWrongOptionIndex));
      surahs.add(candidateWrongSurahs.get(firstWrongOptionIndex));
      return surahs;
    }

    List<Integer> surahs = new ArrayList<>();
    surahs.add(candidateWrongSurahs.get(firstWrongOptionIndex));
    surahs.add(candidateWrongSurahs.get(secondWrongOptionIndex.get()));
    return surahs;
  }

  public int getRubOfAya(int ayah) {
    return quranMetadataCacher.getAyahsMetadata().get(ayah).getRub();
  }

  public int getJuzOfAya(int ayah) {
    return quranMetadataCacher.getAyahsMetadata().get(ayah).getJuz();
  }

  public int getFirstAyahInRub(int rub) {
    return quranMetadataCacher.getFirstAyahsInRubs().get(rub);
  }

  public int getSurahOfAyah(int ayah) {
    return quranMetadataCacher.getAyahsMetadata().get(ayah).getSurah();
  }

  private int getRandomNumberInRange(int startInclusive, int endInclusive) {
    Random random = new Random();
    return random.nextInt(endInclusive - startInclusive + 1) + startInclusive;
  }
}
