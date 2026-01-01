package com.azkar.controllers.challengecontroller;

import static com.azkar.factories.entities.ChallengeFactory.EXPIRY_DATE_OFFSET;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.User.UserGroup;
import com.azkar.entities.challenges.MemorizationChallenge;
import com.azkar.factories.entities.GroupFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.AddMemorizationChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddMemorizationChallengeResponse;
import com.azkar.payload.challengecontroller.responses.DeleteChallengeResponse;
import com.azkar.payload.challengecontroller.responses.FinishMemorizationChallengeQuestionResponse;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import lombok.Builder;
import lombok.Getter;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

public class MemorizationChallengeTest extends TestBase {

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
  public void addMemorizationChallenge_normalScenario_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    int numOfQuestions = 3;
    int difficulty = 2;
    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(friendsIds)
            .difficulty(difficulty)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(numOfQuestions)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .build();
    MvcResult result = azkarApi.addMemorizationChallenge(user1, request)
        .andExpect(status().isOk())
        .andReturn();
    AddMemorizationChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddMemorizationChallengeResponse.class);
    MemorizationChallenge resultChallenge = response.getData();

    assertThat(groupRepo.count(), is(groupsNumBefore + 1));

    assertThat(resultChallenge.getGroupId(), notNullValue());
    assertThat(resultChallenge.getQuestions().size(), is(numOfQuestions));
    assertThat(resultChallenge.getDifficulty(), is(difficulty));
    assertThat("Question is marked finished after creation",
        !resultChallenge.getQuestions().stream().anyMatch(question -> question.isFinished()));
    assertThat("One of the wrong options lists is of size != 2",
        !resultChallenge.getQuestions().stream().anyMatch(
            question -> question.getWrongFirstAyahInJuzOptions().size() != 2
                || question.getWrongFirstAyahInRubOptions().size() != 2
                || question.getWrongNextAyahOptions().size() != 2
                || question.getWrongPreviousAyahOptions().size() != 2
                || question.getWrongSurahOptions().size() != 2));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();


    assertThat(updatedUser1.getReadingQuranChallenges().size(),
        is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
    assertThat(updatedUser2.getReadingQuranChallenges().size(),
        is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
    assertThat(updatedUser3.getReadingQuranChallenges().size(),
        is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
  }

  @Test
  public void addMemorizationChallenge_invalidNumberOfQuestions_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    List<Integer> wrongNumOfQuestionsList = new ArrayList<>();
    wrongNumOfQuestionsList.add(11);
    wrongNumOfQuestionsList.add(100);
    wrongNumOfQuestionsList.add(0);
    wrongNumOfQuestionsList.add(-1);
    for (int wrongNumberOfQuestions : wrongNumOfQuestionsList) {
      int difficulty = 2;
      AddMemorizationChallengeRequest request =
          AddMemorizationChallengeRequest.builder().
              friendsIds(friendsIds)
              .difficulty(difficulty)
              .firstJuz(1)
              .lastJuz(3)
              .numberOfQuestions(wrongNumberOfQuestions)
              .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
              .build();
      MvcResult result = azkarApi.addMemorizationChallenge(user1, request)
          .andExpect(status().isBadRequest())
          .andReturn();
      AddMemorizationChallengeResponse response =
          JsonHandler.fromJson(result.getResponse().getContentAsString(),
              AddMemorizationChallengeResponse.class);

      assertThat(String.format("Number of questions: %d, should lead to returning an error",
          wrongNumberOfQuestions), response.getStatus().code ==
          Status.MEMORIZATION_CHALLENGE_NUMBER_OF_QUESTIONS_INVALID_ERROR);
    }
  }

  @Test
  public void addMemorizationChallenge_invalidDifficulty_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    List<Integer> wrongDifficulties = new ArrayList<>();
    wrongDifficulties.add(4);
    wrongDifficulties.add(100);
    wrongDifficulties.add(0);
    wrongDifficulties.add(-1);
    for (int wrongDifficulty : wrongDifficulties) {
      AddMemorizationChallengeRequest request =
          AddMemorizationChallengeRequest.builder().
              friendsIds(friendsIds)
              .difficulty(wrongDifficulty)
              .firstJuz(1)
              .lastJuz(3)
              .numberOfQuestions(3)
              .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
              .build();
      MvcResult result = azkarApi.addMemorizationChallenge(user1, request)
          .andExpect(status().isBadRequest())
          .andReturn();
      AddMemorizationChallengeResponse response =
          JsonHandler.fromJson(result.getResponse().getContentAsString(),
              AddMemorizationChallengeResponse.class);

      assertThat(String.format("Difficulty: %d, should lead to returning an error",
          wrongDifficulty), response.getStatus().code ==
          Status.MEMORIZATION_CHALLENGE_DIFFICULTY_LEVEL_INVALID_ERROR);
    }
  }

  @Test
  public void addMemorizationChallenge_invalidJuzsRange_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    List<JuzRange> wrongJuzRanges = new ArrayList<>();
    wrongJuzRanges.add(JuzRange.builder().start(1).end(31).build());
    wrongJuzRanges.add(JuzRange.builder().start(0).end(30).build());
    wrongJuzRanges.add(JuzRange.builder().start(5).end(4).build());
    for (JuzRange wrongJuzRange : wrongJuzRanges) {
      AddMemorizationChallengeRequest request =
          AddMemorizationChallengeRequest.builder().
              friendsIds(friendsIds)
              .difficulty(3)
              .firstJuz(wrongJuzRange.start)
              .lastJuz(wrongJuzRange.end)
              .numberOfQuestions(3)
              .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
              .build();
      MvcResult result = azkarApi.addMemorizationChallenge(user1, request)
          .andExpect(status().isBadRequest())
          .andReturn();
      AddMemorizationChallengeResponse response =
          JsonHandler.fromJson(result.getResponse().getContentAsString(),
              AddMemorizationChallengeResponse.class);

      assertThat(String.format("Juz range: [%d, %d], should lead to returning an error",
          wrongJuzRange.start, wrongJuzRange.end), response.getStatus().code ==
          Status.MEMORIZATION_CHALLENGE_JUZ_RANGE_INVALID_ERROR);
    }
  }

  @Test
  public void addMemorizationChallenge_notFriend_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(friendsIds)
            .difficulty(3)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(3)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .build();
    MvcResult result = azkarApi.addMemorizationChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andReturn();
    AddMemorizationChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddMemorizationChallengeResponse.class);

    assertThat(response.getStatus().code, is(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();

    assertThat(updatedUser1.getMemorizationChallenges().size(),
        is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
    assertThat(updatedUser2.getMemorizationChallenges().size(),
        is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
    assertThat(updatedUser3.getMemorizationChallenges().size(),
        is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
  }

  @Test
  public void addMemorizationChallenge_pastExpiryDate_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());

    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(friendsIds)
            .difficulty(3)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(3)
            .expiryDate(Instant.now().getEpochSecond() - EXPIRY_DATE_OFFSET)
            .build();
    MvcResult result = azkarApi.addMemorizationChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andReturn();
    AddMemorizationChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddMemorizationChallengeResponse.class);

    assertThat(response.getStatus().code, is(Status.PAST_EXPIRY_DATE_ERROR));
    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();

    assertThat(updatedUser1.getMemorizationChallenges().size(),
        is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
    assertThat(updatedUser2.getMemorizationChallenges().size(),
        is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
    assertThat(updatedUser3.getMemorizationChallenges().size(),
        is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
  }

  @Test
  public void deleteChallenge_normalScenario_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .difficulty(3)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(3)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .build();
    MemorizationChallenge returnedChallenge = azkarApi.addMemorizationChallengeAndReturn(user1,
        request);

    List<MemorizationChallenge> userChallenges =
        userRepo.findById(user1.getId()).get().getMemorizationChallenges();
    assertThat(userChallenges.size(), is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));

    azkarApi.deleteChallenge(user1, returnedChallenge.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(new DeleteChallengeResponse())));

    userChallenges = userRepo.findById(user1.getId()).get().getMemorizationChallenges();
    assertThat(userChallenges.size(), is(TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));
  }

  @Test
  public void finishMemorizationChallengeQuestion_normalScenario_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .difficulty(3)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(3)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .build();
    MemorizationChallenge returnedChallenge = azkarApi.addMemorizationChallengeAndReturn(user1,
        request);

    List<MemorizationChallenge> userChallenges =
        userRepo.findById(user1.getId()).get().getMemorizationChallenges();
    assertThat(userChallenges.size(), is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));

    azkarApi.finishMemorizationChallengeQuestion(user1, returnedChallenge.getId(), "0")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content()
            .json(JsonHandler.toJson(new FinishMemorizationChallengeQuestionResponse())));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));

    azkarApi.finishMemorizationChallengeQuestion(user1, returnedChallenge.getId(), "2")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content()
            .json(JsonHandler.toJson(new FinishMemorizationChallengeQuestionResponse())));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));

    azkarApi.finishMemorizationChallengeQuestion(user1, returnedChallenge.getId(), "1")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content()
            .json(JsonHandler.toJson(new FinishMemorizationChallengeQuestionResponse())));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(1));
  }

  @Test
  public void finishMemorizationChallengeQuestion_questionInvalid_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .difficulty(3)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(3)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .build();
    MemorizationChallenge returnedChallenge = azkarApi.addMemorizationChallengeAndReturn(user1,
        request);

    List<MemorizationChallenge> userChallenges =
        userRepo.findById(user1.getId()).get().getMemorizationChallenges();
    assertThat(userChallenges.size(), is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));

    List<String> invalidQuestions = ImmutableList.of("-1", "4", "not parseable");
    for (String invalidQuestion : invalidQuestions) {
      MvcResult result = azkarApi.finishMemorizationChallengeQuestion(user1,
          returnedChallenge.getId(), invalidQuestion)
          .andExpect(status().isBadRequest())
          .andExpect(content().contentType(MediaType.APPLICATION_JSON))
          .andReturn();
      FinishMemorizationChallengeQuestionResponse response =
          JsonHandler.fromJson(result.getResponse().getContentAsString(),
              FinishMemorizationChallengeQuestionResponse.class);

      assertThat(String.format("Question: %s, should lead to returning an error",
          invalidQuestion), response.getStatus().code ==
          Status.MEMORIZATION_CHALLENGE_NUMBER_OF_QUESTIONS_INVALID_ERROR);
      assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));
    }
  }

  @Test
  public void finishMemorizationChallengeQuestion_finishSameQuestion_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddMemorizationChallengeRequest request =
        AddMemorizationChallengeRequest.builder().
            friendsIds(ImmutableList.of(user2.getId()))
            .difficulty(3)
            .firstJuz(1)
            .lastJuz(3)
            .numberOfQuestions(3)
            .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
            .build();
    MemorizationChallenge returnedChallenge = azkarApi.addMemorizationChallengeAndReturn(user1,
        request);

    List<MemorizationChallenge> userChallenges =
        userRepo.findById(user1.getId()).get().getMemorizationChallenges();
    assertThat(userChallenges.size(), is(1 + TestBase.STARTING_MEMORIZATION_CHALLENGES_COUNT));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));

    azkarApi.finishMemorizationChallengeQuestion(user1, returnedChallenge.getId(), "0")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content()
            .json(JsonHandler.toJson(new FinishMemorizationChallengeQuestionResponse())));

    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));

    MvcResult result =
        azkarApi.finishMemorizationChallengeQuestion(user1, returnedChallenge.getId(), "0")
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andReturn();

    FinishMemorizationChallengeQuestionResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            FinishMemorizationChallengeQuestionResponse.class);

    assertThat(response.getStatus().getCode(),
        is(Status.MEMORIZATION_QUESTION_HAS_ALREADY_BEEN_FINISHED));
    assertThat(azkarApi.getFinishedChallengesCountAndReturn(user1), is(0));
  }

  @Builder
  @Getter
  private static class JuzRange {

    int start;
    int end;
  }
}
