package com.azkar.controllers.challengecontroller;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.GlobalChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.payload.challengecontroller.responses.FinishGlobalChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetGlobalChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetGlobalChallengeResponse.ReturnedGlobalChallenge;
import com.azkar.payload.challengecontroller.responses.ReturnedChallenge;
import com.azkar.repos.AzkarChallengeRepo;
import com.azkar.repos.GlobalChallengeRepo;
import com.azkar.repos.UserRepo;
import org.junit.After;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

public class GlobalChallengeTest extends TestBase {

  @Autowired
  UserRepo userRepo;

  @Autowired
  AzkarChallengeRepo azkarChallengeRepo;

  @Autowired
  GlobalChallengeRepo globalChallengeRepo;

  @After
  public void afterEach() {
    globalChallengeRepo.deleteAll(globalChallengeRepo.findAll());
  }

  @Test
  public void globalChallenge_requestingGlobalChallenge_shouldSucceed() throws Exception {
    AzkarChallenge unusedAzkarChallenge1 = ChallengeFactory.getNewChallenge("unused_challenge1",
        "unused_group_id1");
    AzkarChallenge azkarChallenge = ChallengeFactory.getNewChallenge("used_challenge",
        "unneeded_group_id2");
    AzkarChallenge unusedAzkarChallenge2 = ChallengeFactory.getNewChallenge("unused_challenge2",
        "unused_group_id3");

    azkarChallengeRepo.save(unusedAzkarChallenge1);
    azkarChallengeRepo.save(azkarChallenge);
    azkarChallengeRepo.save(unusedAzkarChallenge2);

    globalChallengeRepo.save(
        GlobalChallenge.builder()
            .azkarChallengeIdRef(azkarChallenge.getId())
            .build()
    );

    User user = getNewRegisteredUser();
    GetGlobalChallengeResponse expectedResponse = new GetGlobalChallengeResponse();
    expectedResponse.setData(ReturnedGlobalChallenge.builder()
        .challenge(ReturnedChallenge.builder()
            .azkarChallenge(azkarChallenge)
            .build())
        .finishedCount(0)
        .build());
    httpClient.performGetRequest(user, "/challenges/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void globalChallenge_usersFinishedChallenge_shouldSucceed() throws Exception {
    AzkarChallenge unusedAzkarChallenge1 = ChallengeFactory.getNewChallenge("unused_challenge1",
        "unused_group_id1");
    AzkarChallenge azkarChallenge = ChallengeFactory.getNewChallenge("used_challenge",
        "unneeded_group_id2");
    AzkarChallenge unusedAzkarChallenge2 = ChallengeFactory.getNewChallenge("unused_challenge2",
        "unused_group_id3");

    azkarChallengeRepo.save(unusedAzkarChallenge1);
    azkarChallengeRepo.save(azkarChallenge);
    azkarChallengeRepo.save(unusedAzkarChallenge2);

    globalChallengeRepo.save(
        GlobalChallenge.builder()
            .azkarChallengeIdRef(azkarChallenge.getId())
            .finishedCount(0)
            .build()
    );

    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();

    // User1 finishes the challenge twice.
    FinishGlobalChallengeResponse expectedFinishGlobalChallengeReponse =
        new FinishGlobalChallengeResponse();
    httpClient.performPutRequest(user1, "/challenges/finish/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedFinishGlobalChallengeReponse)));
    httpClient.performPutRequest(user1, "/challenges/finish/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedFinishGlobalChallengeReponse)));
    assertThat(userRepo.findById(user1.getId()).get().getFinishedAzkarChallengesCount(), is(2));
    assertThat(userRepo.findById(user2.getId()).get().getFinishedAzkarChallengesCount(), is(0));

    // Users retrieve the global challenge.
    GetGlobalChallengeResponse expectedGetGlobalChallengeReponse = new GetGlobalChallengeResponse();
    expectedGetGlobalChallengeReponse.setData(ReturnedGlobalChallenge.builder()
        .challenge(ReturnedChallenge.builder()
            .azkarChallenge(azkarChallenge)
            .build())
        .finishedCount(2)
        .build());
    httpClient.performGetRequest(user1, "/challenges/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedGetGlobalChallengeReponse)));
    httpClient.performGetRequest(user2, "/challenges/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedGetGlobalChallengeReponse)));

    // User two finishes the global challenge.
    httpClient.performPutRequest(user2, "/challenges/finish/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedFinishGlobalChallengeReponse)));
    assertThat(userRepo.findById(user1.getId()).get().getFinishedAzkarChallengesCount(), is(2));
    assertThat(userRepo.findById(user2.getId()).get().getFinishedAzkarChallengesCount(), is(1));

    // Users retrieve the global challenge.
    expectedGetGlobalChallengeReponse.setData(ReturnedGlobalChallenge.builder()
        .challenge(ReturnedChallenge.builder()
            .azkarChallenge(azkarChallenge)
            .build())
        .finishedCount(3)
        .build());
    httpClient.performGetRequest(user1, "/challenges/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedGetGlobalChallengeReponse)));
    httpClient.performGetRequest(user2, "/challenges/global")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedGetGlobalChallengeReponse)));
  }
}
