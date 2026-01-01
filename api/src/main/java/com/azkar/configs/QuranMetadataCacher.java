package com.azkar.configs;

import com.opencsv.CSVReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.ClassPathResource;

@Configuration
@Getter
@Setter
public class QuranMetadataCacher {

  private static final Logger logger = LoggerFactory.getLogger(QuranMetadataCacher.class);
  @Value("${files.quran-metadata}")
  public String quranMetadataFile;

  // Maps the 1-based index of Ayah to the Ayah's metadata.
  Map<Integer, AyahMetadata> ayahsMetadata;
  // Maps the 1-based index of Surah to the first Ayah in it.
  Map<Integer, Integer> firstAyahsInSurahs;
  // Maps the 1-based index of Juz to the first Ayah in it.
  Map<Integer, Integer> firstAyahsInJuzs;
  // Maps the 1-based index of Rub to the first Ayah in it.
  Map<Integer, Integer> firstAyahsInRubs;

  @Bean
  @Primary
  public QuranMetadataCacher parseQuranMetadataFromFile() {
    QuranMetadataCacher quranMetadataCacher = new QuranMetadataCacher();

    List<LineInQuranMetadataFile> linesInQuranMetadataFile = parseQuranMetadataFile();
    quranMetadataCacher.setAyahsMetadata(buildAyahsMetadata(linesInQuranMetadataFile));
    quranMetadataCacher.setFirstAyahsInSurahs(buildSurahsMetadata(linesInQuranMetadataFile));
    quranMetadataCacher.setFirstAyahsInJuzs(buildJuzsMetadata(linesInQuranMetadataFile));
    quranMetadataCacher.setFirstAyahsInRubs(buildRubsMetadata(linesInQuranMetadataFile));

    return quranMetadataCacher;
  }


  private List<LineInQuranMetadataFile> parseQuranMetadataFile() {
    List<LineInQuranMetadataFile> linesInQuranMetadataFile = new ArrayList<>();
    try {
      CSVReader csvReader =
          new CSVReader(
              new InputStreamReader(new ClassPathResource(quranMetadataFile).getInputStream()));

      boolean readFirstLine = false;
      String[] values;
      while ((values = csvReader.readNext()) != null) {
        if (values.length != 6) {
          throw new IOException(
              "Didn't find exactly 6 columns per row in CSV file: " + quranMetadataFile);
        }
        if (!readFirstLine) {
          readFirstLine = true;
          continue;
        }

        LineInQuranMetadataFile lineInQuranMetadataFile =
            LineInQuranMetadataFile.builder()
                .ayah(Integer.parseInt(values[0]))
                .surah(Integer.parseInt(values[1]))
                .rub(Integer.parseInt(values[2]))
                .juz(Integer.parseInt(values[3]))
                .firstAyahInRub(Integer.parseInt(values[4]))
                .firstAyahInJuz(Integer.parseInt(values[5]))
                .build();
        linesInQuranMetadataFile.add(lineInQuranMetadataFile);
      }

      if (linesInQuranMetadataFile.size() == 0) {
        throw new IOException("Error while parsing file: " + quranMetadataFile);
      }
    } catch (Exception e) {
      logger.error("Can't retrieve Quran: " + e.getMessage());
    }
    return linesInQuranMetadataFile;
  }


  private Map<Integer, Integer> buildRubsMetadata(
      List<LineInQuranMetadataFile> linesInQuranMetadataFile) {
    Map<Integer, Integer> firstAyahInRub = new HashMap<>();

    int currentRub = 1;
    firstAyahInRub.put(1, 1);

    for (LineInQuranMetadataFile lineInQuranMetadataFile : linesInQuranMetadataFile) {
      if (lineInQuranMetadataFile.rub != currentRub) {
        currentRub = lineInQuranMetadataFile.rub;
        firstAyahInRub.put(currentRub, lineInQuranMetadataFile.ayah);
      }
    }

    return firstAyahInRub;
  }

  private Map<Integer, Integer> buildJuzsMetadata(
      List<LineInQuranMetadataFile> linesInQuranMetadataFile) {
    Map<Integer, Integer> firstAyahInJuz = new HashMap<>();

    int currentJuz = 1;
    firstAyahInJuz.put(1, 1);

    for (LineInQuranMetadataFile lineInQuranMetadataFile : linesInQuranMetadataFile) {
      if (lineInQuranMetadataFile.juz != currentJuz) {
        currentJuz = lineInQuranMetadataFile.juz;
        firstAyahInJuz.put(currentJuz, lineInQuranMetadataFile.ayah);
      }
    }

    return firstAyahInJuz;
  }

  private Map<Integer, Integer> buildSurahsMetadata(
      List<LineInQuranMetadataFile> linesInQuranMetadataFile) {
    Map<Integer, Integer> firstAyahInSurah = new HashMap<>();

    int currentSurah = 1;
    firstAyahInSurah.put(1, 1);

    for (LineInQuranMetadataFile lineInQuranMetadataFile : linesInQuranMetadataFile) {
      if (lineInQuranMetadataFile.surah != currentSurah) {
        currentSurah = lineInQuranMetadataFile.surah;
        firstAyahInSurah.put(currentSurah, lineInQuranMetadataFile.ayah);
      }
    }

    return firstAyahInSurah;
  }

  private Map<Integer, AyahMetadata> buildAyahsMetadata(
      List<LineInQuranMetadataFile> linesInQuranMetadataFile) {
    Map<Integer, AyahMetadata> map = new HashMap<>();
    linesInQuranMetadataFile.stream().forEach(lineInQuranMetadataFile ->
        map.put(lineInQuranMetadataFile.getAyah(),
            AyahMetadata.builder()
                .ayah(lineInQuranMetadataFile.getAyah())
                .surah(lineInQuranMetadataFile.getSurah())
                .juz(lineInQuranMetadataFile.getJuz())
                .rub(lineInQuranMetadataFile.getRub())
                .build())
    );
    return map;
  }

  @Getter
  @NoArgsConstructor
  @AllArgsConstructor
  @Setter
  @Builder
  public static class AyahMetadata {

    int ayah;
    int surah;
    int rub;
    int juz;
  }

  @Getter
  @NoArgsConstructor
  @AllArgsConstructor
  @Setter
  @Builder
  public static class LineInQuranMetadataFile {

    int ayah;
    int surah;
    int rub;
    int juz;
    int firstAyahInRub;
    int firstAyahInJuz;
  }
}
