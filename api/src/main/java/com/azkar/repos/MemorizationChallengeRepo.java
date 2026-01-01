package com.azkar.repos;

import com.azkar.entities.challenges.MemorizationChallenge;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemorizationChallengeRepo extends MongoRepository<MemorizationChallenge, String> {

}
