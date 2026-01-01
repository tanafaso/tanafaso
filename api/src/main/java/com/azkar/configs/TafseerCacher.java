package com.azkar.configs;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.ClassPathResource;

@Configuration
@Getter
public class TafseerCacher {

  private static final Logger logger = LoggerFactory.getLogger(TafseerCacher.class);
  @Value("${files.tafseer}")
  public String tafseerFile;
  ArrayList<WordMeaningPair> wordMeaningPairs;

  @Lazy(value = false)
  @Bean
  @Primary
  public TafseerCacher parseTafseerFromFile() {
    TafseerCacher cacher = new TafseerCacher();
    cacher.wordMeaningPairs = new ArrayList<>();
    try {
      BufferedReader reader =
          new BufferedReader(
              new InputStreamReader(new ClassPathResource(tafseerFile).getInputStream()));
      String line;
      while ((line = reader.readLine()) != null) {
        String[] values = line.split(":");
        if (values.length < 2) {
          throw new IOException("Didn't find a word-meaning pair in : " + tafseerFile);
        }

        // Merge all sentences for meaning in one string.
        for (int i = 2; i < values.length; i++) {
          values[1] += values[i];
        }

        WordMeaningPair wordMeaningPair = WordMeaningPair.builder()
            .word(values[0])
            .meaning(values[1])
            .build();
        cacher.wordMeaningPairs.add(wordMeaningPair);
      }

      if (cacher.wordMeaningPairs.size() == 0) {
        throw new IOException("Error while parsing file: " + tafseerFile);
      }
    } catch (Exception e) {
      logger.error("Can't retrieve tafseer", e);
    }
    return cacher;
  }

  @Builder
  @Data
  public static class WordMeaningPair {

    String word;
    String meaning;
  }
}
