package com.azkar.services;

import com.azkar.configs.AsyncConfig;
import com.azkar.entities.User;
import com.azkar.repos.UserRepo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class ChallengesCleanerService {

  private static final Logger logger = LoggerFactory.getLogger(ChallengesCleanerService.class);

  private static final int MAX_USER_CHALLENGES_WITH_SAME_TYPE = 10;

  @Autowired
  private UserRepo userRepo;

  @Async(AsyncConfig.POST_CONTROLLERS_TASK_EXECUTOR)
  public void cleanOldUserChallengesAsync(User user) {

    logger.info("[Old Challenges Deletion] Starting for user: {}. Challenges "
            + "counts before deletion: "
            + "(azkar: {}, reading: {}, meaning: {}, memorization: {})",
        user.getUsername(),
        user.getAzkarChallenges().size(),
        user.getReadingQuranChallenges().size(),
        user.getMeaningChallenges().size(),
        user.getMemorizationChallenges().size());

    user.setAzkarChallenges(user.getAzkarChallenges().subList(
        Math.max(0, user.getAzkarChallenges().size() - MAX_USER_CHALLENGES_WITH_SAME_TYPE),
        user.getAzkarChallenges().size()));

    user.setReadingQuranChallenges(user.getReadingQuranChallenges().subList(
        Math.max(0, user.getReadingQuranChallenges().size() - MAX_USER_CHALLENGES_WITH_SAME_TYPE),
        user.getReadingQuranChallenges().size()));

    user.setMeaningChallenges(user.getMeaningChallenges().subList(
        Math.max(0, user.getMeaningChallenges().size() - MAX_USER_CHALLENGES_WITH_SAME_TYPE),
        user.getMeaningChallenges().size()));

    user.setMemorizationChallenges(user.getMemorizationChallenges().subList(
        Math.max(0, user.getMemorizationChallenges().size() - MAX_USER_CHALLENGES_WITH_SAME_TYPE),
        user.getMemorizationChallenges().size()));
    userRepo.save(user);

    logger.info("[Old Challenges Deletion] finished for user: {}. Challenges "
            + "counts after deletion: "
            + "(azkar: {}, reading: {}, meaning: {}, memorization: {})",
        user.getUsername(),
        user.getAzkarChallenges().size(),
        user.getReadingQuranChallenges().size(),
        user.getMeaningChallenges().size(),
        user.getMemorizationChallenges().size());
  }
}
