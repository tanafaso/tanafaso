package com.azkar.factories.entities;

import com.azkar.entities.User;
import com.azkar.entities.User.UserFacebookData;

public class UserFactory {

  static int usersRequested = 0;

  public static User getNewUser() {
    usersRequested++;
    return User.builder()
        .id("testId" + usersRequested)
        .email("testEmail" + usersRequested + "@example_domain.com")
        .username("test_username" + usersRequested)
        .firstName("testFirstName" + usersRequested)
        .lastName("testLastName" + usersRequested)
        .build();
  }

  public static User getNewUserWithEmailAndEncodedPassword(String email, String encodedPassword) {
    usersRequested++;
    return User.builder()
        .id("testId" + usersRequested)
        .email(email)
        .encodedPassword(encodedPassword)
        .username("test_username" + usersRequested)
        .firstName("testFirstName" + usersRequested)
        .lastName("testLastName" + usersRequested)
        .build();
  }

  public static User getUserRegisteredWithFacebook() {
    usersRequested++;
    UserFacebookData userFacebookData = UserFacebookData.builder()
        .email("testFacebookEmail" + usersRequested
            + "@example_domain.com")
        .userId("testFacebookId" + usersRequested)
        .firstName("testFacebookFirstName"
            + usersRequested)
        .lastName(
            "testFacebookLastName" + usersRequested)
        .build();

    return User.builder()
        .id("testId" + usersRequested)
        .userFacebookData(userFacebookData)
        .firstName(userFacebookData.getLastName())
        .lastName(userFacebookData.getLastName())
        .build();
  }

  public static User getUserRegisteredWithFacebookWithFacebookUserId(String facebookUserId) {
    usersRequested++;
    UserFacebookData userFacebookData = UserFacebookData.builder()
        .email("testFacebookEmail" + usersRequested
            + "@example_domain.com")
        .userId(facebookUserId)
        .firstName("testFirstName" + usersRequested)
        .lastName("testLastName" + usersRequested)
        .build();

    return User.builder()
        .id("testId" + usersRequested)
        .userFacebookData(userFacebookData)
        .firstName(userFacebookData.getLastName())
        .lastName(userFacebookData.getLastName())
        .build();
  }
}
