package com.azkar.repos;

import com.azkar.entities.challenges.MeaningChallenge;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MeaningChallengeRepo extends MongoRepository<MeaningChallenge, String> {

}
