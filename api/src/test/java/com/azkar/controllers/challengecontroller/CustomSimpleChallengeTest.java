package com.azkar.controllers.challengecontroller;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.util.AssertionErrors.assertTrue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.CustomSimpleChallenge;
import com.azkar.factories.entities.GroupFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.AddCustomSimpleChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddCustomSimpleChallengeResponse;
import com.azkar.payload.challengecontroller.responses.DeleteChallengeResponse;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

public class CustomSimpleChallengeTest extends TestBase {

  public final static long EXPIRY_DATE_OFFSET = 60 * 60;
  @Autowired
  GroupRepo groupRepo;
  @Autowired
  UserRepo userRepo;
  private User user1 = UserFactory.getNewUser();
  private Group validGroup = GroupFactory.getNewGroup(user1.getId());
  private Group invalidGroup = GroupFactory.getNewGroup(user1.getId());

  @Before
  public void before() {
    addNewUser(user1);
    groupRepo.save(validGroup);
  }

  @Test
  public void addCustomSimpleChallenge_normalScenario_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());
    String description = "descriptionExample";
    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(friendsIds)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .description(description)
            .build();
    MvcResult result = azkarApi.addCustomSimpleChallenge(user1, request)
        .andExpect(status().isOk())
        .andReturn();
    AddCustomSimpleChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddCustomSimpleChallengeResponse.class);
    CustomSimpleChallenge resultChallenge = response.getData();

    assertThat(groupRepo.count(), is(groupsNumBefore + 1));

    assertThat(resultChallenge.getGroupId(), notNullValue());
    assertThat(resultChallenge.getDescription(), equalTo(description));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();

    assertThat(updatedUser1.getCustomSimpleChallenges().size(), is(1));
    assertThat(updatedUser2.getCustomSimpleChallenges().size(), is(1));
    assertThat(updatedUser3.getCustomSimpleChallenges().size(), is(1));
  }

  @Test
  public void addCustomSimpleChallenge_notFriend_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(friendsIds)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .description("description")
            .build();
    AddCustomSimpleChallengeResponse expectedResponse = new AddCustomSimpleChallengeResponse();
    expectedResponse.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
    azkarApi.addCustomSimpleChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();

    assertThat(updatedUser1.getCustomSimpleChallenges().size(), is(0));
    assertThat(updatedUser2.getCustomSimpleChallenges().size(), is(0));
    assertThat(updatedUser3.getCustomSimpleChallenges().size(), is(0));
  }

  @Test
  public void addCustomSimpleChallenge_oneFriendProvided_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    List<String> friendsIds = ImmutableList.of(user2.getId());
    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(friendsIds)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .description("description")
            .build();
    AddCustomSimpleChallengeResponse expectedResponse = new AddCustomSimpleChallengeResponse();
    expectedResponse.setStatus(new Status(Status.LESS_THAN_TWO_FRIENDS_ARE_PROVIDED_ERROR));
    azkarApi.addCustomSimpleChallenge(user1, request)
        .andExpect(status().isOk());
  }

  @Test
  public void addCustomSimpleChallenge_duplicateFriendIds_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user2.getId());
    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(friendsIds)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .description("description")
            .build();
    AddCustomSimpleChallengeResponse expectedResponse = new AddCustomSimpleChallengeResponse();
    expectedResponse.setStatus(new Status(Status.DUPLICATE_FRIEND_IDS_PROVIDED_ERROR));
    azkarApi.addCustomSimpleChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();

    assertThat(updatedUser1.getCustomSimpleChallenges().size(), is(0));
    assertThat(updatedUser2.getCustomSimpleChallenges().size(), is(0));
  }

  @Test
  public void addCustomSimpleChallenge_beforeExpiryDate_shouldNotSucceed() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    long beforeExpiryDate = Instant.now().getEpochSecond() - EXPIRY_DATE_OFFSET;

    AddCustomSimpleChallengeResponse expectedResponse = new AddCustomSimpleChallengeResponse();
    expectedResponse.setStatus(new Status(Status.PAST_EXPIRY_DATE_ERROR));

    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .expiryDate(beforeExpiryDate)
            .description("description")
            .build();
    azkarApi.addCustomSimpleChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<CustomSimpleChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getCustomSimpleChallenges();
    assertThat(challengesProgress.size(),
        equalTo(0));
    List<String> groupChallenges = groupRepo.findById(validGroup.getId()).get().getChallengesIds();
    assertTrue("GroupChallenges list is expected to be empty but it is not.",
        groupChallenges.isEmpty());
  }

  @Test
  public void addCustomSimpleChallenge_emptyDescription_shouldFail()
      throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .description("")
            .build();

    AddCustomSimpleChallengeResponse expectedResponse = new AddCustomSimpleChallengeResponse();
    expectedResponse.setStatus(new Status(Status.CUSTOM_SIMPLE_CHALLENGE_DESCRIPTION_EMPTY_ERROR));
    azkarApi.addCustomSimpleChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void deleteChallenge_normalScenario_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddCustomSimpleChallengeRequest request =
        AddCustomSimpleChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .description("description")
            .build();
    CustomSimpleChallenge returnedChallenge = azkarApi.addCustomSimpleChallengeAndReturn(user1,
        request);

    List<CustomSimpleChallenge> userChallenges =
        userRepo.findById(user1.getId()).get().getCustomSimpleChallenges();
    assertThat(userChallenges.size(), is(1));

    azkarApi.deleteChallenge(user1, returnedChallenge.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new DeleteChallengeResponse())));

    userChallenges = userRepo.findById(user1.getId()).get().getCustomSimpleChallenges();
    assertThat(userChallenges.size(), is(0));
  }
}
