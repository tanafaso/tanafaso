package com.azkar.controllers.challengecontroller;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.factories.entities.GroupFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.responses.GetChallengeResponse;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

public class AzkarChallengeTest extends TestBase {

  @Autowired
  UserRepo userRepo;
  private User user;
  private Group group;
  @Autowired
  private GroupRepo groupRepo;

  @Before
  public void setUp() {
    user = UserFactory.getNewUser();
    addNewUser(user);
    group = GroupFactory.getNewGroup(user.getId());
    groupRepo.save(group);
  }

  @Test
  public void getOriginalChallenge_normalScenario_shouldSucceed() throws Exception {
    AzkarChallenge queriedChallenge = createGroupChallenge(user, group);
    // Create irrelevant challenge
    createGroupChallenge(user, group);

    // Change the user's copy of the challenge
    User updatedUser1 = userRepo.findById(user.getId()).get();
    updatedUser1.getUserChallenges().stream().forEach(
        userChallenge -> userChallenge.getSubChallenges().stream().forEach(
            subChallenge -> subChallenge.setRepetitions(subChallenge.getRepetitions() + 1)
        )
    );
    userRepo.save(updatedUser1);

    GetChallengeResponse response = new GetChallengeResponse();
    response.setData(queriedChallenge);

    azkarApi.getOriginalChallenge(user, queriedChallenge.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(response)));
  }

  @Test
  public void getOriginalChallenge_invalidChallengeId_shouldFail() throws Exception {
    GetChallengeResponse notFoundResponse = getGetChallengeNotFoundResponse();

    azkarApi.getOriginalChallenge(user, "invalidChallengeId")
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(notFoundResponse)));
  }

  @Test
  public void getOriginalChallenge_userDoesNotHaveChallenge_shouldFail() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(group.getId());
    azkarApi.addAzkarChallenge(user, challenge).andExpect(status().isOk());
    User nonGroupMember = UserFactory.getNewUser();
    addNewUser(nonGroupMember);
    GetChallengeResponse notFoundResponse = getGetChallengeNotFoundResponse();

    azkarApi.getOriginalChallenge(nonGroupMember, challenge.getId())
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(notFoundResponse)));
  }

  @Test
  public void getChallenge_invalidChallengeId_shouldFail() throws Exception {
    GetChallengeResponse notFoundResponse = getGetChallengeNotFoundResponse();

    azkarApi.getChallenge(user, "invalidChallengeId")
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(notFoundResponse)));
  }

  @Test
  public void getChallenge_normalScenario_shouldSucceed() throws Exception {
    AzkarChallenge queriedChallenge = createGroupChallenge(user, group);
    AzkarChallenge anotherChallenge = createGroupChallenge(user, group);
    GetChallengeResponse response = new GetChallengeResponse();
    response.setData(queriedChallenge);

    azkarApi.getChallenge(user, queriedChallenge.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(response)));
  }

  @Test
  public void getChallenge_userDoesNotHaveChallenge_shouldFail() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(group.getId());
    azkarApi.addAzkarChallenge(user, challenge).andExpect(status().isOk());
    User nonGroupMember = UserFactory.getNewUser();
    addNewUser(nonGroupMember);
    GetChallengeResponse notFoundResponse = getGetChallengeNotFoundResponse();

    azkarApi.getChallenge(nonGroupMember, challenge.getId())
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(notFoundResponse)));
  }

  private AzkarChallenge createGroupChallenge(User user, Group group)
      throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(group.getId());
    return azkarApi.addAzkarChallengeAndReturn(user, challenge);
  }

  private GetChallengeResponse getGetChallengeNotFoundResponse() {
    GetChallengeResponse expectedResponse = new GetChallengeResponse();
    expectedResponse.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
    return expectedResponse;
  }
}
