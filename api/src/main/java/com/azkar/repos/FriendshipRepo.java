package com.azkar.repos;

import com.azkar.entities.Friendship;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FriendshipRepo extends MongoRepository<Friendship, String> {

  Friendship findByUserId(String userId);

  Long deleteByUserId(String userId);

}
