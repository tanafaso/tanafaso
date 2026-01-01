package com.azkar.configs;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.EnableMongoAuditing;

@Configuration
@EnableMongoAuditing
public class MongoConfig {

  @Value("${DATABASE_URI}")
  private String databaseUri;

  @Bean
  public MongoClient createMongoClient() {
    return MongoClients.create(MongoClientSettings.builder()
        .applyConnectionString(new ConnectionString(databaseUri))
        .applyToConnectionPoolSettings(builder ->
            builder
                .minSize(2)
                .maxWaitTime(10, TimeUnit.SECONDS)
                .maxConnectionLifeTime(5, TimeUnit.MINUTES)
                .build()
        )
        .applyToSocketSettings(builder ->
            builder.connectTimeout(10, TimeUnit.SECONDS)
                .readTimeout(10, TimeUnit.SECONDS)
        )
        .retryWrites(true)
        .build()
    );
  }
}