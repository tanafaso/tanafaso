package com.azkar.repos;

import com.azkar.entities.challenges.ReadingQuranChallenge;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReadingQuranChallengeRepo extends MongoRepository<ReadingQuranChallenge, String> {

}
