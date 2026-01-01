package com.azkar.repos;

import com.azkar.entities.challenges.GlobalChallenge;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Update;
import org.springframework.stereotype.Repository;

@Repository
public interface GlobalChallengeRepo extends MongoRepository<GlobalChallenge, String> {

  @Update("{ '$inc' : { 'finishedCount' : 1 } }")
  void findAndIncrementFinishedCountById(String id);
}
