package com.azkar.crons;

import com.azkar.entities.User;
import com.azkar.repos.UserRepo;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

@Component
public class ChallengesCleaner implements ApplicationRunner {

  private static final Logger logger = LoggerFactory.getLogger(ChallengesCleaner.class);
  private static final int USERS_BATCH_SIZE = 100;

  @Autowired
  private UserRepo userRepo;

  @Autowired
  private ApplicationContext appContext;

  @Value("${job-mode}")
  public boolean jobMode;

  // Run every while to clean old challenges. Note that although after every challenge creation
  // done by a certain user, we clean the old challenges for this user, that's not enough because
  // we don't clean for all other users who are also part of that challenge.
  @Override
  public void run(ApplicationArguments args) throws Exception {
    if (!jobMode) {
      logger.info("[Challenges cleaner] skipping as the application is not running in job mode");
      return;
    }

    logger.info("[Challenges cleaner] started!");

    long numberOfUsers = userRepo.count();
    logger.info("[Challenges cleaner] number of users to be processed: {}", numberOfUsers);
    logger.info("[Challenges cleaner] users will be processed in batches of {}", USERS_BATCH_SIZE);

    long numberOfBatches = (numberOfUsers + USERS_BATCH_SIZE - 1) / USERS_BATCH_SIZE;
    logger.info("[Challenges cleaner] number of batches to be processed: {}", numberOfBatches);

    AtomicInteger cleanedChallenges = new AtomicInteger();
    for (int batch = 0; batch < numberOfBatches; batch++) {
      Page<User> page = userRepo.findAll(PageRequest.of(batch, USERS_BATCH_SIZE));
      List<User> modifiedUsers = page.get().map(user -> {
        int userChallengesBeforeCleaning =
            user.getAzkarChallenges().size() + user.getReadingQuranChallenges().size()
                + user.getMeaningChallenges().size() + user.getMemorizationChallenges().size();

        user.setAzkarChallenges(user.getAzkarChallenges().subList(
            Math.max(0, user.getAzkarChallenges().size() - 30),
            user.getAzkarChallenges().size()));

        user.setReadingQuranChallenges(user.getReadingQuranChallenges().subList(
            Math.max(0, user.getReadingQuranChallenges().size() - 30),
            user.getReadingQuranChallenges().size()));

        user.setMeaningChallenges(user.getMeaningChallenges().subList(
            Math.max(0, user.getMeaningChallenges().size() - 30),
            user.getMeaningChallenges().size()));

        user.setMemorizationChallenges(user.getMemorizationChallenges().subList(
            Math.max(0, user.getMemorizationChallenges().size() - 30),
            user.getMemorizationChallenges().size()));

        int userChallengesAfterCleaning =
            user.getAzkarChallenges().size() + user.getReadingQuranChallenges().size()
                + user.getMeaningChallenges().size() + user.getMemorizationChallenges().size();

        if (userChallengesBeforeCleaning != userChallengesAfterCleaning) {
          logger.info("[Challenges cleaner] cleaned {} challenges for user {}",
              userChallengesBeforeCleaning - userChallengesAfterCleaning, user.getId());
        }
        cleanedChallenges.addAndGet((userChallengesBeforeCleaning - userChallengesAfterCleaning));
        return user;
      }).collect(Collectors.toList());

      userRepo.saveAll(modifiedUsers);

      logger.info("[Challenges cleaner] processed {}/{} batches", batch + 1, numberOfBatches);
    }

    logger.info("[Challenges cleaner] finished! Cleaned {} challenges", cleanedChallenges);

    SpringApplication.exit(appContext, () -> 0);
  }
}