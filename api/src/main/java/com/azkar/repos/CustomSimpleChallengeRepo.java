package com.azkar.repos;

import com.azkar.entities.challenges.CustomSimpleChallenge;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomSimpleChallengeRepo extends
    MongoRepository<CustomSimpleChallenge, String> {

}
