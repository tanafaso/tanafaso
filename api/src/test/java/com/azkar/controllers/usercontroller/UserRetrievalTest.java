package com.azkar.controllers.usercontroller;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.AzkarApi;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.User;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.usercontroller.responses.GetUserResponse;
import com.azkar.repos.UserRepo;
import java.util.Collections;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;

public class UserRetrievalTest extends TestBase {

  @Autowired
  UserRepo userRepo;

  @Autowired
  AzkarApi azkarApi;

  @Test
  public void getLoggedInUserProfileV2_shouldSucceed() throws Exception {
    User user = UserFactory.getNewUser();
    addNewUser(user);

    MvcResult result = azkarApi.getProfileV2(user)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andReturn();

    GetUserResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            GetUserResponse.class);

    User returnedUser = response.getData();
    assertThat(returnedUser.getId(), is(user.getId()));
    assertThat(returnedUser.getEmail(), is(user.getEmail()));
    assertThat(returnedUser.getFirstName(), is(user.getFirstName()));
    assertThat(returnedUser.getLastName(), is(user.getLastName()));
    assertThat(returnedUser.getUsername(), is(user.getUsername()));
    assertThat(returnedUser.getAzkarChallenges(), is(Collections.emptyList()));
    assertThat(returnedUser.getPersonalChallenges(), is(Collections.emptyList()));
  }

  @Test
  public void getUserById_notFriend_shouldRetrieveMinimalInformation() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();

    GetUserResponse expectedResponse = new GetUserResponse();
    User expectedReturnedUser = User.builder()
        .id(user2.getId())
        .username(user2.getUsername())
        .firstName(user2.getFirstName())
        .lastName(user2.getLastName())
        .build();
    expectedResponse.setData(expectedReturnedUser);

    azkarApi.getUserById(user1, user2.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getUserById_normalScenario_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    azkarApi.makeFriends(user1, user2);

    GetUserResponse expectedResponse = new GetUserResponse();
    User expectedReturnedUser = User.builder()
        .id(user2.getId())
        .username(user2.getUsername())
        .firstName(user2.getFirstName())
        .lastName(user2.getLastName())
        .build();
    expectedResponse.setData(expectedReturnedUser);

    azkarApi.getUserById(user1, user2.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  public UserRepo getUserRepo() {
    return userRepo;
  }

  @Test
  public void getSabeq_shouldSucceed() throws Exception {
    String userId = "example id";
    User sabeq = userRepo.findById(User.SABEQ_ID).get();
    User expectedReturnedUser = User.builder()
        .id(sabeq.getId())
        .username(sabeq.getUsername())
        .firstName(sabeq.getFirstName())
        .lastName(sabeq.getLastName())
        .build();
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setData(expectedReturnedUser);

    performGetRequest(expectedReturnedUser, String.format("/users/sabeq", userId))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getUserById_fakeUserId_shouldNotSucceed() throws Exception {
    String realUserId = "example id";
    String fakeUserId = "fake user id";
    User user = UserFactory.getNewUser().toBuilder().
        id(realUserId).
        build();
    addNewUser(user);
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));

    ResultActions result = performGetRequest(user, String.format("/users/%s", fakeUserId));

    result
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void searchForUserByUsername_validUsername_shouldSucceed() throws Exception {
    String username = "example_username";
    User user = UserFactory.getNewUser().toBuilder().
        username(username).
        build();
    addNewUser(user);

    User expectedReturnedUser = User.builder()
        .id(user.getId())
        .firstName(user.getFirstName())
        .lastName(user.getLastName())
        .username(user.getUsername())
        .build();
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setData(expectedReturnedUser);

    ResultActions result = azkarApi.searchForUserByUsername(user, username);

    result
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void searchForUserByUsername_fakeUsername_shouldNotSucceed() throws Exception {
    String realUsername = "example-username";
    String fakeUsername = "fake-username";
    User user = UserFactory.getNewUser().toBuilder().
        username(realUsername).
        build();
    addNewUser(user);
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));

    ResultActions result = azkarApi.searchForUserByUsername(user, fakeUsername);

    result
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void searchForUserByFacebookUserId_validFacebookUserId_shouldSucceed() throws Exception {
    String facebookUserId = "0123401234";
    User user = UserFactory.getUserRegisteredWithFacebookWithFacebookUserId(facebookUserId);
    addNewUser(user);
    User expectedReturnedUser = User.builder()
        .id(user.getId())
        .firstName(user.getFirstName())
        .lastName(user.getLastName())
        .username(user.getUsername())
        .build();
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setData(expectedReturnedUser);

    ResultActions result = azkarApi.searchForUserByFacebookUserId(user, facebookUserId);

    result
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void searchForUserByFacebookUserId_fakeFacebookUserId_shouldNotSucceed() throws Exception {
    String realFacebookUserId = "1234120";
    String fakeFacebookUserId = "23423413";
    User user = UserFactory.getUserRegisteredWithFacebookWithFacebookUserId(realFacebookUserId);
    addNewUser(user);
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));

    ResultActions result = azkarApi.searchForUserByFacebookUserId(user, fakeFacebookUserId);

    result
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void searchForUserByUsername_wrongQueryParameterName_shouldNotSucceed() throws Exception {
    String username = "example-username";
    User user = UserFactory.getNewUser().toBuilder()
        .username(username)
        .build();
    addNewUser(user);
    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setStatus(new Status(Status.SEARCH_PARAMETERS_NOT_SPECIFIED));

    ResultActions result =
        performGetRequest(user, String.format("/users/search?wrong=%s", username));

    result
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void searchForUserByUsername_noQueryParametersSpecified_shouldNotSucceed()
      throws Exception {
    String username = "example-username";
    User user = UserFactory.getNewUser().toBuilder()
        .username(username)
        .build();
    addNewUser(user);

    GetUserResponse expectedResponse = new GetUserResponse();
    expectedResponse.setStatus(new Status(Status.SEARCH_PARAMETERS_NOT_SPECIFIED));

    ResultActions result =
        performGetRequest(user, String.format("/users/search", username));

    result
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }
}
