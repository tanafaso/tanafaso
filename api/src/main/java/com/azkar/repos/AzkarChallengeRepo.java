package com.azkar.repos;

import com.azkar.entities.challenges.AzkarChallenge;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AzkarChallengeRepo extends MongoRepository<AzkarChallenge, String> {

}
