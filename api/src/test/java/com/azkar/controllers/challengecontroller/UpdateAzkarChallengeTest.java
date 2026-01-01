package com.azkar.controllers.challengecontroller;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.User.UserGroup;
import com.azkar.entities.Zekr;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.UpdateChallengeRequest;
import com.azkar.payload.challengecontroller.responses.GetChallengeResponse;
import com.azkar.payload.challengecontroller.responses.UpdateChallengeResponse;
import com.azkar.repos.AzkarChallengeRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;

public class UpdateAzkarChallengeTest extends TestBase {

  public static final int OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS =
      ChallengeFactory.azkarSubChallenge1()
          .getRepetitions();
  public static final int NEW_SUB_CHALLENGE_1_LEFT_REPETITIONS =
      OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS - 1;
  public static final int OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS =
      ChallengeFactory.azkarSubChallenge2()
          .getRepetitions();
  public static final int NEW_SUB_CHALLENGE_2_LEFT_REPETITIONS =
      OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS - 2;
  protected User user;
  @Autowired
  protected GroupRepo groupRepo;
  protected Group group;
  @Autowired
  protected UserRepo userRepo;
  @Autowired
  AzkarChallengeRepo challengeRepo;

  static UpdateChallengeRequest createUpdateChallengeRequest(AzkarChallenge newChallenge) {
    return UpdateChallengeRequest.builder().newChallenge(newChallenge).build();
  }

  @Before
  public void setup() throws Exception {
    user = UserFactory.getNewUser();
    addNewUser(user);
    group = azkarApi.addGroupAndReturn(user, "group_name");
  }

  @Test
  public void updateChallenge_updateOneSubChallenge_shouldSucceed() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    challenge.getSubChallenges().get(1)
        .setRepetitions(NEW_SUB_CHALLENGE_2_LEFT_REPETITIONS);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);
    UpdateChallengeResponse expectedResponse = new UpdateChallengeResponse();
    expectedResponse.setStatus(new Status(Status.SUCCESS));

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isOk())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(), is(
        OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(), is(
        NEW_SUB_CHALLENGE_2_LEFT_REPETITIONS));
  }

  @Test
  public void updateChallenge_updateMultipleSubChallenges_shouldSucceed() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    challenge.getSubChallenges().get(0)
        .setRepetitions(NEW_SUB_CHALLENGE_1_LEFT_REPETITIONS);
    challenge.getSubChallenges().get(1)
        .setRepetitions(NEW_SUB_CHALLENGE_2_LEFT_REPETITIONS);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isOk());

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(),
        is(NEW_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(),
        is(NEW_SUB_CHALLENGE_2_LEFT_REPETITIONS));
  }

  @Test
  public void updateChallenge_NegativeLeftRepetitions_shouldUpdateWithZero() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    challenge.getSubChallenges().get(0).setRepetitions(-1);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isOk());

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(),
        is(0));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(),
        is(OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS));

  }

  @Test
  public void updateChallenge_IncrementLeftRepetitions_shouldFail() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    challenge.getSubChallenges().get(0)
        .setRepetitions(OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS + 1);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);
    UpdateChallengeResponse expectedResponse = new UpdateChallengeResponse();
    expectedResponse
        .setStatus(new Status(Status.INCREMENTING_LEFT_REPETITIONS_ERROR));

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(),
        is(OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(),
        is(OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS));

  }

  @Test
  public void updateChallenge_invalidZekrId_shouldFail() throws Exception {
    int invalidZekrId = 777;
    AzkarChallenge challenge = createNewChallenge(user);
    challenge.getSubChallenges().get(1).setZekr(Zekr.builder().id(invalidZekrId).build());
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);
    UpdateChallengeResponse expectedResponse = new UpdateChallengeResponse();
    expectedResponse
        .setStatus(new Status(Status.NON_EXISTENT_SUB_CHALLENGE_ERROR));

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(),
        is(OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(),
        is(OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS));

  }

  @Test
  public void updateChallenge_invalidChallengeId_shouldFail() throws Exception {
    AzkarChallenge unsavedChallenge = ChallengeFactory.getNewChallenge("invalidId");
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(unsavedChallenge);
    UpdateChallengeResponse response = new UpdateChallengeResponse();
    response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));

    updateChallenge(user, "invalidId", requestBody)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(response)));
  }

  @Test
  public void updateChallenge_extraSubChallenge_shouldFail() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    List<SubChallenge> updatedSubChallenges = ImmutableList.of(
        challenge.getSubChallenges().get(0),
        challenge.getSubChallenges().get(0),
        challenge.getSubChallenges().get(1));
    updatedSubChallenges.get(2).setRepetitions(NEW_SUB_CHALLENGE_2_LEFT_REPETITIONS);
    challenge.setSubChallenges(updatedSubChallenges);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);
    UpdateChallengeResponse response = new UpdateChallengeResponse();
    response.setStatus(new Status(Status.MISSING_OR_DUPLICATED_SUB_CHALLENGE_ERROR));

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(response)));

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(), is(
        OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(), is(
        OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS));
  }

  @Test
  public void updateChallenge_missingSubChallenge_shouldFail() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    List<SubChallenge> updatedSubChallenges = ImmutableList.of(
        challenge.getSubChallenges().get(0));
    updatedSubChallenges.get(0).setRepetitions(NEW_SUB_CHALLENGE_1_LEFT_REPETITIONS);
    challenge.setSubChallenges(updatedSubChallenges);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);
    UpdateChallengeResponse response = new UpdateChallengeResponse();
    response.setStatus(new Status(Status.MISSING_OR_DUPLICATED_SUB_CHALLENGE_ERROR));

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(response)));

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(), is(
        OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(), is(
        OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS));
  }

  @Test
  public void updateChallenge_duplicatedSubChallenge_shouldFail() throws Exception {
    AzkarChallenge challenge = createNewChallenge(user);
    List<SubChallenge> updatedSubChallenges = ImmutableList.of(
        challenge.getSubChallenges().get(0),
        challenge.getSubChallenges().get(0));
    updatedSubChallenges.get(0).setRepetitions(NEW_SUB_CHALLENGE_1_LEFT_REPETITIONS);
    updatedSubChallenges.get(1).setRepetitions(NEW_SUB_CHALLENGE_1_LEFT_REPETITIONS);
    challenge.setSubChallenges(updatedSubChallenges);
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);
    UpdateChallengeResponse response = new UpdateChallengeResponse();
    response.setStatus(new Status(Status.MISSING_OR_DUPLICATED_SUB_CHALLENGE_ERROR));

    updateChallenge(user, challenge.getId(), requestBody)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(response)));

    AzkarChallenge updatedChallenge = getChallengeProgressFromApi(challenge);
    assertThat(updatedChallenge.getSubChallenges().get(0).getRepetitions(), is(
        OLD_SUB_CHALLENGE_1_LEFT_REPETITIONS));
    assertThat(updatedChallenge.getSubChallenges().get(1).getRepetitions(), is(
        OLD_SUB_CHALLENGE_2_LEFT_REPETITIONS));
  }

  @Test
  public void updateChallenge_finishChallenge_shouldUpdateScore() throws Exception {
    User user1 = UserFactory.getNewUser();
    addNewUser(user1);

    Group group1 = azkarApi.addGroupAndReturn(user1, "group1");
    Group group2 = azkarApi.addGroupAndReturn(user1, "group2");
    User user2InGroup1 = UserFactory.getNewUser();
    addNewUser(user2InGroup1);
    azkarApi.makeFriends(user1, user2InGroup1);
    azkarApi.addUserToGroup(/*invitingUser*/user1, /*user=*/user2InGroup1, group1.getId());

    AzkarChallenge challenge = createGroupChallenge(user1, group1.getId());
    for (SubChallenge subChallenge : challenge.getSubChallenges()) {
      subChallenge.setRepetitions(0);
    }
    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(challenge);

    updateChallenge(user1, challenge.getId(), requestBody)
        .andExpect(status().isOk());

    AzkarChallenge updatedUser1Challenge = azkarApi.getChallengeAndReturn(user1, challenge.getId());
    AzkarChallenge updatedUser2Challenge =
        azkarApi.getChallengeAndReturn(user2InGroup1, challenge.getId());
    assertThat(updatedUser1Challenge.getSubChallenges().get(0).getRepetitions(), is(
        0));
    assertThat(updatedUser1Challenge.getSubChallenges().get(1).getRepetitions(), is(
        0));

    assertThat(Iterators.getOnlyElement(updatedUser1Challenge.getUsersFinished().iterator()),
        equalTo(user1.getId()));
    assertThat(Iterators.getOnlyElement(updatedUser2Challenge.getUsersFinished().iterator()),
        equalTo(user1.getId()));
    AzkarChallenge updatedChallenge = challengeRepo.findById(challenge.getId()).get();
    assertThat(Iterators.getOnlyElement(updatedChallenge.getUsersFinished().iterator()),
        equalTo(user1.getId()));

    Friend user1Friend = azkarApi.getFriendsLeaderboardV2AndReturn(user1).stream()
        .filter(friend -> friend.getUserId().equals(user2InGroup1.getId())).findFirst().get();
    Friend user2Friend = azkarApi.getFriendsLeaderboardV2AndReturn(user2InGroup1).stream()
        .filter(friend -> friend.getUserId().equals(user1.getId())).findFirst().get();

    assertThat(user1Friend.getUserTotalScore(), is(1L));
    assertThat(user1Friend.getFriendTotalScore(), is(0L));

    assertThat(user2Friend.getUserTotalScore(), is(0L));
    assertThat(user2Friend.getFriendTotalScore(), is(1L));
  }

  @Test
  public void updateChallenge_partiallyFinishedChallenge_shouldNotUpdateScore() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(group.getId());
    assertThat(challenge.getSubChallenges().size(), not(0));
    challenge.getSubChallenges().get(0).setRepetitions(2);

    AzkarChallenge createdChallenge = createGroupChallenge(user, challenge);
    for (SubChallenge subChallenge : createdChallenge.getSubChallenges()) {
      subChallenge.setRepetitions(1);
    }

    UpdateChallengeRequest requestBody = createUpdateChallengeRequest(createdChallenge);
    updateChallenge(user, createdChallenge.getId(), requestBody)
        .andExpect(status().isOk());
  }

  private AzkarChallenge createNewChallenge(User user) throws Exception {
    return createGroupChallenge(user, group.getId());
  }

  private ResultActions updateChallenge(User user, String challengeId,
      UpdateChallengeRequest requestBody) throws Exception {
    return azkarApi.updateChallenge(user, challengeId, requestBody);
  }

  private AzkarChallenge getChallengeProgressFromApi(AzkarChallenge challenge)
      throws Exception {
    ResultActions resultActions = azkarApi.getChallenge(user, challenge.getId())
        .andExpect(status().isOk());
    return getResponse(resultActions, GetChallengeResponse.class).getData();
  }
}
