package com.azkar.configs;

import com.azkar.entities.Zekr;
import com.opencsv.CSVReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import lombok.Getter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.ClassPathResource;

@Configuration
@Getter
public class AzkarCacher {

  private static class UnExpectedZekrException extends RuntimeException {

    public UnExpectedZekrException(String message) {
      super(message);
    }
  }

  private static final Logger logger = LoggerFactory.getLogger(AzkarCacher.class);
  // This ID is preserved for Azkar created by users, so this shouldn't be used by pre-saved
  // Azkar in azkar.csv.
  private static final int CUSTOM_ZEKR_ID = 10_000;
  @Value("${files.azkar}")
  public String azkarFile;
  ArrayList<Zekr> azkar = new ArrayList<>();

  @Bean
  @Primary
  public AzkarCacher parseAzkarFromCsv() {
    AzkarCacher cacher = new AzkarCacher();
    try {
      CSVReader csvReader =
          new CSVReader(new InputStreamReader(new ClassPathResource(azkarFile).getInputStream()));
      String[] values;
      while ((values = csvReader.readNext()) != null) {
        if (values.length != 2) {
          throw new IOException("Didn't find exactly 2 columns per row in CSV file: " + azkarFile);
        }

        if (Integer.parseInt(values[0]) == CUSTOM_ZEKR_ID) {
          throw new UnExpectedZekrException(String.format("Didn't expect a Zekr in azkar.csv with "
              + "ID %d, as this ID is preserved for Azkar created by users.", CUSTOM_ZEKR_ID));
        }

        Zekr zekr = Zekr.builder().id(Integer.parseInt(values[0])).zekr(values[1]).build();
        azkar.add(zekr);
      }

      if (azkar.size() == 0) {
        throw new IOException("Error while parsing file: " + azkarFile);
      }
      cacher.azkar = azkar;
    } catch (Exception e) {
      logger.error("Can't retrieve azkar: " + e.getMessage());
    }
    return cacher;
  }
}
