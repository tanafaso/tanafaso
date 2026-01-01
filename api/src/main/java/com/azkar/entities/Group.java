package com.azkar.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.List;
import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Builder.Default;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "groups")
@Getter
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class Group extends EntityBase {

  @Indexed
  @Id
  private String id;
  @Deprecated
  @JsonProperty("binary")
  @Builder.Default
  private boolean isBinary = true;
  // Group name can be null in case of auto-generated groups. Groups are auto-generated in the
  // following two cases.
  // 1- A group is auto-generated for every pair of friends so that it is easier to challenge a
  // particular friends without creating a group for every friend challenge.
  // 2- A group is auto-generated when the user want to quickly challenge a set of friends
  // without creating a new group. If the user repeated that for the same set of friends, a new
  // group will be generated every time.
  private String name;
  // TODO(issue#258): Populate Group.creatorId for existing users
  private String creatorId;
  @NotNull
  private List<String> usersIds;
  @Default
  private List<String> challengesIds = new ArrayList<>();
  @JsonIgnore
  @CreatedDate
  private long createdAt;
  @JsonIgnore
  @LastModifiedDate
  private long modifiedAt;
}
