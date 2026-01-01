package com.azkar.entities;

import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/*
Publicly available females are users who want their names to be publicly available in a list that
can be used by females to send friend requests to each other.
 */
@Document(collection = "publicly_available_female_users")
@Builder(toBuilder = true)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PubliclyAvailableFemaleUser extends EntityBase {

  @Indexed
  @Id
  private String id;
  @Indexed
  private String userId;
  @NotNull
  private String firstName;
  @NotNull
  private String lastName;

}
