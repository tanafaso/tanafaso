package com.azkar.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.ArrayList;
import java.util.List;
import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Builder.Default;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "friendships")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Friendship extends EntityBase {

  @Indexed
  @Id
  private String id;
  @NotNull
  @Indexed(name = "user_id_index")
  private String userId;
  @Default
  private List<Friend> friends = new ArrayList<Friend>();
  @JsonIgnore
  @CreatedDate
  private long createdAt;
  @JsonIgnore
  @LastModifiedDate
  private long modifiedAt;

  @Builder
  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class Friend {

    // Change the name to friendId so as to be consistent with score variables names.
    @NotNull
    private String userId;
    private String groupId;
    @NotNull
    private String username;
    @NotNull
    private String firstName;
    @NotNull
    private String lastName;
    private boolean isPending;

    @Default
    private long userTotalScore = 0;
    @Default
    private long friendTotalScore = 0;
  }
}
