package com.azkar.payload.usercontroller.responses;

import com.azkar.payload.ResponseBase;
import com.azkar.payload.usercontroller.responses.GetPubliclyAvailableUsersResponse.PubliclyAvailableUser;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class GetPubliclyAvailableUsersResponse extends ResponseBase<List<PubliclyAvailableUser>> {

  @Builder
  @Getter
  @NoArgsConstructor
  @AllArgsConstructor
  @Setter
  public static class PubliclyAvailableUser {

    private String userId;
    private String firstName;
    private String lastName;
  }
}
