package com.azkar.controllers.usercontroller;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.util.AssertionErrors.assertTrue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.AzkarApi;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.PubliclyAvailableFemaleUser;
import com.azkar.entities.PubliclyAvailableMaleUser;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.usercontroller.responses.AddToPubliclyAvailableUsersResponse;
import com.azkar.payload.usercontroller.responses.DeleteFromPubliclyAvailableUsers;
import com.azkar.payload.usercontroller.responses.GetPubliclyAvailableUsersResponse;
import com.azkar.payload.usercontroller.responses.GetPubliclyAvailableUsersResponse.PubliclyAvailableUser;
import com.azkar.repos.PubliclyAvailableFemaleUsersRepo;
import com.azkar.repos.PubliclyAvailableMaleUsersRepo;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import java.util.ArrayList;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;

public class PubliclyAvailableUsersTest extends TestBase {

  @Autowired
  AzkarApi azkarApi;
  @Autowired
  PubliclyAvailableMaleUsersRepo publiclyAvailableMaleUsersRepo;
  @Autowired
  PubliclyAvailableFemaleUsersRepo publiclyAvailableFemaleUsersRepo;

  @Before
  public void before() {
    publiclyAvailableMaleUsersRepo.deleteAll();
    publiclyAvailableFemaleUsersRepo.deleteAll();
  }

  @Test
  public void addToPubliclyAvailableMaleUsers_normalScenario_shouldSucceed() throws Exception {
    // Add first male user.
    User maleUser1 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new AddToPubliclyAvailableUsersResponse())));

    PubliclyAvailableMaleUser publiclyAvailableMaleUserInDb =
        Iterators.getOnlyElement(publiclyAvailableMaleUsersRepo.findAll().iterator());
    assertThat(publiclyAvailableMaleUserInDb.getUserId(), equalTo(maleUser1.getId()));
    assertThat(publiclyAvailableMaleUserInDb.getFirstName(), equalTo(maleUser1.getFirstName()));
    assertThat(publiclyAvailableMaleUserInDb.getLastName(), equalTo(maleUser1.getLastName()));

    // Add second male user.
    User maleUser2 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new AddToPubliclyAvailableUsersResponse())));

    List<PubliclyAvailableMaleUser> publiclyAvailableMaleUsersInDb =
        publiclyAvailableMaleUsersRepo.findAll();
    assertThat(publiclyAvailableMaleUsersInDb.get(0).getUserId(), equalTo(maleUser1.getId()));
    assertThat(publiclyAvailableMaleUsersInDb.get(1).getUserId(), equalTo(maleUser2.getId()));

    // Add first female user.
    User femaleUser1 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new AddToPubliclyAvailableUsersResponse())));

    PubliclyAvailableFemaleUser publiclyAvailableFemaleUserInDb =
        Iterators.getOnlyElement(publiclyAvailableFemaleUsersRepo.findAll().iterator());
    assertThat(publiclyAvailableFemaleUserInDb.getUserId(), equalTo(femaleUser1.getId()));
    assertThat(publiclyAvailableFemaleUserInDb.getFirstName(), equalTo(femaleUser1.getFirstName()));
    assertThat(publiclyAvailableFemaleUserInDb.getLastName(), equalTo(femaleUser1.getLastName()));
    publiclyAvailableMaleUsersInDb =
        publiclyAvailableMaleUsersRepo.findAll();
    assertThat(publiclyAvailableMaleUsersInDb.get(0).getUserId(), equalTo(maleUser1.getId()));
    assertThat(publiclyAvailableMaleUsersInDb.get(1).getUserId(), equalTo(maleUser2.getId()));

    // Add second male user.
    User femaleUser2 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new AddToPubliclyAvailableUsersResponse())));

    List<PubliclyAvailableFemaleUser> publiclyAvailableFemaleUsersInDb =
        publiclyAvailableFemaleUsersRepo.findAll();
    assertThat(publiclyAvailableFemaleUsersInDb.get(0).getUserId(), equalTo(femaleUser1.getId()));
    assertThat(publiclyAvailableFemaleUsersInDb.get(1).getUserId(), equalTo(femaleUser2.getId()));
    publiclyAvailableMaleUsersInDb =
        publiclyAvailableMaleUsersRepo.findAll();
    assertThat(publiclyAvailableMaleUsersInDb.get(0).getUserId(), equalTo(maleUser1.getId()));
    assertThat(publiclyAvailableMaleUsersInDb.get(1).getUserId(), equalTo(maleUser2.getId()));
  }

  @Test
  public void addToPubliclyAvailableMaleUsers_alreadyAdded_shouldFail() throws Exception {
    // Add male user
    User maleUser = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new AddToPubliclyAvailableUsersResponse())));

    AddToPubliclyAvailableUsersResponse expectedResponse =
        new AddToPubliclyAvailableUsersResponse();
    expectedResponse.setStatus(new Status(Status.USER_ALREADY_IS_PUBLICLY_AVAILABLE_USER_ERROR));
    azkarApi.addToPubliclyAvailableMales(maleUser)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    azkarApi.addToPubliclyAvailableFemales(maleUser)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // Add female user
    User femaleUser = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new AddToPubliclyAvailableUsersResponse())));

    azkarApi.addToPubliclyAvailableMales(femaleUser)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
    azkarApi.addToPubliclyAvailableFemales(femaleUser)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void deleteFromPubliclyAvailableUsers_normalScenario_shouldSucceed() throws Exception {
    // Add first male user.
    User maleUser1 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser1);

    // Add second male user.
    User maleUser2 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser2);

    // Add female user.
    User femaleUser = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser);

    azkarApi.deleteFromPubliclyAvailableUsers(maleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new DeleteFromPubliclyAvailableUsers())));

    PubliclyAvailableMaleUser publiclyAvailableMaleUserInDb =
        Iterators.getOnlyElement(publiclyAvailableMaleUsersRepo.findAll().iterator());
    assertThat(publiclyAvailableMaleUserInDb.getUserId(), equalTo(maleUser1.getId()));
    PubliclyAvailableFemaleUser publiclyAvailableFemaleUserInDb =
        Iterators.getOnlyElement(publiclyAvailableFemaleUsersRepo.findAll().iterator());
    assertThat(publiclyAvailableFemaleUserInDb.getUserId(), equalTo(femaleUser.getId()));
  }

  @Test
  public void deleteFromPubliclyAvailableUsers_notAddedBefore_shouldFail() throws Exception {
    User maleUser1 = getNewRegisteredUser();
    User femaleUser1 = getNewRegisteredUser();
    User userToBeDeleted = getNewRegisteredUser();

    azkarApi.addToPubliclyAvailableMales(maleUser1);
    azkarApi.addToPubliclyAvailableFemales(femaleUser1);

    DeleteFromPubliclyAvailableUsers expectedResponse = new DeleteFromPubliclyAvailableUsers();
    expectedResponse.setStatus(new Status(Status.USER_NOT_ADDED_TO_PUBLICLY_AVAILABLE_USERS_ERROR));

    azkarApi.deleteFromPubliclyAvailableUsers(userToBeDeleted)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getPubliclyAvailableUsers_normalScenario_shouldSucceed() throws Exception {
    // Add male user 1
    User maleUser1 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser1);

    GetPubliclyAvailableUsersResponse expectedResponse = new GetPubliclyAvailableUsersResponse();
    List<PubliclyAvailableUser> expectedPubliclyAvailableUsers = new ArrayList<>();
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(maleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // Add male user 2
    User maleUser2 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser2);

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(maleUser2.getId())
            .firstName(maleUser2.getFirstName())
            .lastName(maleUser2.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(maleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(maleUser1.getId())
            .firstName(maleUser1.getFirstName())
            .lastName(maleUser1.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(maleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // Add female user 1
    User femaleUser1 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser1);

    expectedPubliclyAvailableUsers = new ArrayList<>();
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(femaleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // Add female user 2
    User femaleUser2 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser2);

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(femaleUser2.getId())
            .firstName(femaleUser2.getFirstName())
            .lastName(femaleUser2.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(femaleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(femaleUser1.getId())
            .firstName(femaleUser1.getFirstName())
            .lastName(femaleUser1.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(femaleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // Delete male user 1
    azkarApi.deleteFromPubliclyAvailableUsers(maleUser1);

    expectedPubliclyAvailableUsers = new ArrayList<>();
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(maleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(femaleUser2.getId())
            .firstName(femaleUser2.getFirstName())
            .lastName(femaleUser2.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(femaleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(femaleUser1.getId())
            .firstName(femaleUser1.getFirstName())
            .lastName(femaleUser1.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(femaleUser2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    expectedResponse.setData(null);
    expectedResponse.setStatus(new Status(Status.USER_NOT_ADDED_TO_PUBLICLY_AVAILABLE_USERS_ERROR));

    azkarApi.getPubliclyAvailableUsers(maleUser1)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // Add one more female user to test returning multiple users
    User femaleUser3 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(femaleUser3);

    expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(femaleUser2.getId())
            .firstName(femaleUser2.getFirstName())
            .lastName(femaleUser2.getLastName())
            .build(),
        PubliclyAvailableUser.builder()
            .userId(femaleUser3.getId())
            .firstName(femaleUser3.getFirstName())
            .lastName(femaleUser3.getLastName())
            .build()
    );
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    expectedResponse.setStatus(null);
    azkarApi.getPubliclyAvailableUsers(femaleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getPubliclyAvailableUsers_males_withPagination_shouldSucceed() throws Exception {
    final String testUserFirstNamePrefix = "firstName";

    User user = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(user);

    // Add 3 pages of users..
    for (int i = 0; i < 20 + 20 + 10; i++) {
      User newUser = UserFactory.getNewUser();
      newUser.setFirstName(testUserFirstNamePrefix + i);
      addNewUser(newUser);
      azkarApi.addToPubliclyAvailableMales(newUser);
    }

    // Get first page
    ResultActions resultActions = azkarApi.getPubliclyAvailableUsersWithPagination(user, 0)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    GetPubliclyAvailableUsersResponse response = getResponse(resultActions,
        GetPubliclyAvailableUsersResponse.class);
    assertThat(response.getData().size(), is(20));
    assertTrue("Note that users are returned in reverse order of registering in the publicly "
        + "available list", response.getData().stream().anyMatch(
        publiclyAvailableUser -> publiclyAvailableUser.getFirstName()
            .equals(testUserFirstNamePrefix + "40")));

    // Get second page
    resultActions = azkarApi.getPubliclyAvailableUsersWithPagination(user, 1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    response = getResponse(resultActions,
        GetPubliclyAvailableUsersResponse.class);
    assertThat(response.getData().size(), is(20));
    assertTrue("Note that users are returned in reverse order of registering in the publicly "
        + "available list", response.getData().stream().anyMatch(
        publiclyAvailableUser -> publiclyAvailableUser.getFirstName()
            .equals(testUserFirstNamePrefix + "20")));

    // Get third page
    resultActions = azkarApi.getPubliclyAvailableUsersWithPagination(user, 2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    response = getResponse(resultActions,
        GetPubliclyAvailableUsersResponse.class);
    assertThat(response.getData().size(), is(10));
    assertTrue("Note that users are returned in reverse order of registering in the publicly "
        + "available list", response.getData().stream().anyMatch(
        publiclyAvailableUser -> publiclyAvailableUser.getFirstName()
            .equals(testUserFirstNamePrefix + "0")));
  }


  @Test
  public void getPubliclyAvailableUsers_females_withPagination_shouldSucceed() throws Exception {
    final String testUserFirstNamePrefix = "firstName";

    User user = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableFemales(user);

    // Add 3 pages of users..
    for (int i = 0; i < 20 + 20 + 10; i++) {
      User newUser = UserFactory.getNewUser();
      newUser.setFirstName(testUserFirstNamePrefix + i);
      addNewUser(newUser);
      azkarApi.addToPubliclyAvailableFemales(newUser);
    }

    // Get first page
    ResultActions resultActions = azkarApi.getPubliclyAvailableUsersWithPagination(user, 0)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    GetPubliclyAvailableUsersResponse response = getResponse(resultActions,
        GetPubliclyAvailableUsersResponse.class);
    assertThat(response.getData().size(), is(20));
    assertTrue("Note that users are returned in reverse order of registering in the publicly "
        + "available list", response.getData().stream().anyMatch(
        publiclyAvailableUser -> publiclyAvailableUser.getFirstName()
            .equals(testUserFirstNamePrefix + "40")));

    // Get second page
    resultActions = azkarApi.getPubliclyAvailableUsersWithPagination(user, 1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    response = getResponse(resultActions,
        GetPubliclyAvailableUsersResponse.class);
    assertThat(response.getData().size(), is(20));
    assertTrue("Note that users are returned in reverse order of registering in the publicly "
        + "available list", response.getData().stream().anyMatch(
        publiclyAvailableUser -> publiclyAvailableUser.getFirstName()
            .equals(testUserFirstNamePrefix + "20")));

    // Get third page
    resultActions = azkarApi.getPubliclyAvailableUsersWithPagination(user, 2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    response = getResponse(resultActions,
        GetPubliclyAvailableUsersResponse.class);
    assertThat(response.getData().size(), is(10));
    assertTrue("Note that users are returned in reverse order of registering in the publicly "
        + "available list", response.getData().stream().anyMatch(
        publiclyAvailableUser -> publiclyAvailableUser.getFirstName()
            .equals(testUserFirstNamePrefix + "0")));
  }

  @Test
  public void getPubliclyAvailableUsers_userIsFriend_shouldNotBeReturned() throws Exception {
    // Testing for males
    User maleUser1 = getNewRegisteredUser();
    User maleUser2 = getNewRegisteredUser();
    User maleUser3 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser1);
    azkarApi.addToPubliclyAvailableMales(maleUser2);
    azkarApi.addToPubliclyAvailableMales(maleUser3);

    azkarApi.makeFriends(maleUser1, maleUser2);

    GetPubliclyAvailableUsersResponse expectedResponse = new GetPubliclyAvailableUsersResponse();
    List<PubliclyAvailableUser> expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(maleUser3.getId())
            .firstName(maleUser3.getFirstName())
            .lastName(maleUser3.getLastName())
            .build());
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(maleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getPubliclyAvailableUsers_hasPendingRequestToUser_shouldNotBeReturned()
      throws Exception {
    // Testing for males
    User maleUser1 = getNewRegisteredUser();
    User maleUser2 = getNewRegisteredUser();
    User maleUser3 = getNewRegisteredUser();
    azkarApi.addToPubliclyAvailableMales(maleUser1);
    azkarApi.addToPubliclyAvailableMales(maleUser2);
    azkarApi.addToPubliclyAvailableMales(maleUser3);

    azkarApi.sendFriendRequest(maleUser1, maleUser2);

    GetPubliclyAvailableUsersResponse expectedResponse = new GetPubliclyAvailableUsersResponse();
    List<PubliclyAvailableUser> expectedPubliclyAvailableUsers = ImmutableList.of(
        PubliclyAvailableUser.builder()
            .userId(maleUser3.getId())
            .firstName(maleUser3.getFirstName())
            .lastName(maleUser3.getLastName())
            .build());
    expectedResponse.setData(expectedPubliclyAvailableUsers);
    azkarApi.getPubliclyAvailableUsers(maleUser1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getPubliclyAvailableUsers_notAddedBefore_shouldFail() throws Exception {
    User user = getNewRegisteredUser();

    GetPubliclyAvailableUsersResponse expectedResponse = new GetPubliclyAvailableUsersResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_ADDED_TO_PUBLICLY_AVAILABLE_USERS_ERROR));

    azkarApi.getPubliclyAvailableUsers(user)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }
}
