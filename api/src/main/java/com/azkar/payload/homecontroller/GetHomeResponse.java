package com.azkar.payload.homecontroller;

import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.payload.ResponseBase;
import com.azkar.payload.challengecontroller.responses.ReturnedChallenge;
import com.azkar.payload.homecontroller.GetHomeResponse.Body;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class GetHomeResponse extends ResponseBase<Body> {

  @Builder
  @Getter
  @NoArgsConstructor
  @AllArgsConstructor
  @Setter
  public static class Body {

    List<ReturnedChallenge> challenges;
    List<Friend> friends;
    List<Group> groups;
  }
}
