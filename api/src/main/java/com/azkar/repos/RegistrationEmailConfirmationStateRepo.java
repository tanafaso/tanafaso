package com.azkar.repos;

import com.azkar.entities.RegistrationEmailConfirmationState;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface RegistrationEmailConfirmationStateRepo extends
    MongoRepository<RegistrationEmailConfirmationState, String> {

  boolean existsByEmail(String email);

  Optional<RegistrationEmailConfirmationState> findByToken(String token);

  Optional<RegistrationEmailConfirmationState> findByEmail(String email);
}
