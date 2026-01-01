package com.azkar.configs;

import com.azkar.entities.Category;
import com.azkar.entities.Zekr;
import com.opencsv.CSVReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import lombok.Getter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.ClassPathResource;

@Getter
@Configuration
public class CategoriesCacher {

  private static final Logger logger = LoggerFactory.getLogger(CategoriesCacher.class);
  @Value("${files.categories}")
  public String categoriesFile;
  @Autowired
  AzkarCacher azkarCacher;
  List<Category> categories = new ArrayList<>();

  @Bean
  @Lazy(value = false)
  @Primary
  public CategoriesCacher parseCategoriesFromCsv() {
    CategoriesCacher categoriesCacher = new CategoriesCacher();

    HashMap<Integer, Zekr> zekrIdToZekr = getAzkar();

    try {
      CSVReader csvReader =
          new CSVReader(
              new InputStreamReader(new ClassPathResource(categoriesFile).getInputStream()));
      String[] values;
      while ((values = csvReader.readNext()) != null) {
        if (values.length < 2) {
          throw new IOException(
              "Found less than 2 columns per row in CSV file: " + categoriesFile);
        }

        List<Zekr> azkarInCategory = new ArrayList<>();
        for (int i = 2; i < values.length; i++) {
          azkarInCategory.add(zekrIdToZekr.get(Integer.parseInt(values[i])));
        }

        Category category =
            Category.builder().id(Integer.parseInt(values[0])).name(values[1])
                .azkar(azkarInCategory).build();
        categories.add(category);
      }

      if (categories.size() == 0) {
        throw new IOException("Error while parsing file: " + categoriesFile);
      }
      categoriesCacher.categories = categories;
    } catch (Exception e) {
      logger.error("Can't retrieve categories: " + e.getMessage());
    }

    return categoriesCacher;
  }

  private HashMap<Integer, Zekr> getAzkar() {
    List<Zekr> azkar = azkarCacher.getAzkar();

    HashMap<Integer, Zekr> zekrIdToZekr = new HashMap<>();
    for (Zekr zekr : azkar) {
      zekrIdToZekr.put(zekr.getId(), zekr);
    }
    return zekrIdToZekr;
  }
}
