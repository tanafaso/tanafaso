package com.azkar.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import javax.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "registration_with_email_confirmation_states")
@Builder
@Data
public class RegistrationEmailConfirmationState extends EntityBase {

  @Id
  private String id;
  @NotNull
  @Indexed(name = "email_index", unique = true)
  private String email;
  @NotNull
  private String password;
  // Use token instead
  @Deprecated
  private int pin;
  private String token;
  @NotNull
  private String firstName;
  @NotNull
  private String lastName;

  @JsonIgnore
  @CreatedDate
  private long createdAt;
  @JsonIgnore
  @LastModifiedDate
  private long updatedAt;
}
