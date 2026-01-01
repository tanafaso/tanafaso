package com.azkar.controllers.challengecontroller;

import static com.azkar.factories.entities.ChallengeFactory.EXPIRY_DATE_OFFSET;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.configs.TafseerCacher;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.User;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.AddMeaningChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddMeaningChallengeResponse;
import com.azkar.payload.challengecontroller.responses.FinishMeaningChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetMeaningChallengeResponse;
import com.azkar.payload.usercontroller.responses.GetFriendsLeaderboardV2Response;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import java.util.List;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

public class MeaningChallengeTest extends TestBase {

  @Autowired
  UserRepo userRepo;

  @Autowired
  TafseerCacher tafseerCacher;

  @Autowired
  FriendshipRepo friendshipRepo;

  @Test
  public void addMeaningChallenge_normalScenario_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    int meaningChallengesCountBefore = user1.getMeaningChallenges().size();

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MvcResult mvcResult = httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andReturn();

    AddMeaningChallengeResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), AddMeaningChallengeResponse.class);

    User updatedUser = userRepo.findById(user1.getId()).get();
    assertThat(updatedUser.getMeaningChallenges().size(), is(meaningChallengesCountBefore + 1));
    MeaningChallenge resultChallenge =
        updatedUser.getMeaningChallenges().stream()
            .filter(meaningChallenge -> meaningChallenge.getId().equals(response.getData().getId()))
            .findFirst().get();

    assertThat(resultChallenge.getMeanings().size(), is(3));
    assertThat(resultChallenge.getWords().size(), is(3));
    assertThat(resultChallenge.getWords().get(0), not(resultChallenge.getWords().get(1)));
    assertThat(resultChallenge.getWords().get(1), not(resultChallenge.getWords().get(2)));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(resultChallenge, /*pairIdx=*/0));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(resultChallenge, /*pairIdx=*/1));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(resultChallenge, /*pairIdx=*/2));

    User updatedUser2 = userRepo.findById(user2.getId()).get();
    MeaningChallenge user2ResultChallenge =
        updatedUser2.getMeaningChallenges().stream()
            .filter(meaningChallenge -> meaningChallenge.getId().equals(response.getData().getId()))
            .findFirst().get();
    assertThat(user2ResultChallenge.getMeanings().size(), is(3));
    assertThat(user2ResultChallenge.getWords().size(), is(3));
    assertThat(user2ResultChallenge.getWords().get(0), not(user2ResultChallenge.getWords().get(1)));
    assertThat(user2ResultChallenge.getWords().get(1), not(user2ResultChallenge.getWords().get(2)));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user2ResultChallenge, /*pairIdx=*/0));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user2ResultChallenge, /*pairIdx=*/1));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user2ResultChallenge, /*pairIdx=*/2));
  }

  @Test
  public void addMeaningChallenge_nineWords_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    int meaningChallengesCountBefore = user1.getMeaningChallenges().size();

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .numberOfWords(9)
        .build();
    MvcResult mvcResult = httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andReturn();

    AddMeaningChallengeResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), AddMeaningChallengeResponse.class);

    User updatedUser = userRepo.findById(user1.getId()).get();
    assertThat(updatedUser.getMeaningChallenges().size(), is(meaningChallengesCountBefore + 1));
    MeaningChallenge resultChallenge =
        updatedUser.getMeaningChallenges().stream()
            .filter(meaningChallenge -> meaningChallenge.getId().equals(response.getData().getId()))
            .findFirst().get();

    assertThat(resultChallenge.getMeanings().size(), is(9));
    assertThat(resultChallenge.getWords().size(), is(9));
    for (int i = 0; i < 8; i++) {
      assertThat(String.format("Words %d and %d must not be the same", i, i + 1),
          !resultChallenge.getWords().get(i).equals(resultChallenge.getWords().get(i + 1)));
    }
  }

  @Test
  public void addMeaningChallenge_withOneUser_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    int meaningChallengesCountBefore = user1.getMeaningChallenges().size();

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MvcResult mvcResult = httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andReturn();

    AddMeaningChallengeResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), AddMeaningChallengeResponse.class);

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    assertThat(updatedUser1.getMeaningChallenges().size(), is(meaningChallengesCountBefore + 1));
    MeaningChallenge user1ResultChallenge =
        updatedUser1.getMeaningChallenges().stream()
            .filter(meaningChallenge -> meaningChallenge.getId().equals(response.getData().getId()))
            .findFirst().get();
    assertThat(user1ResultChallenge.getMeanings().size(), is(3));
    assertThat(user1ResultChallenge.getWords().size(), is(3));
    assertThat(user1ResultChallenge.getWords().get(0), not(user1ResultChallenge.getWords().get(1)));
    assertThat(user1ResultChallenge.getWords().get(1), not(user1ResultChallenge.getWords().get(2)));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user1ResultChallenge, /*pairIdx=*/0));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user1ResultChallenge, /*pairIdx=*/1));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user1ResultChallenge, /*pairIdx=*/2));

    User updatedUser2 = userRepo.findById(user2.getId()).get();
    MeaningChallenge user2ResultChallenge =
        updatedUser2.getMeaningChallenges().stream()
            .filter(meaningChallenge -> meaningChallenge.getId().equals(response.getData().getId()))
            .findFirst().get();
    assertThat(user2ResultChallenge.getMeanings().size(), is(3));
    assertThat(user2ResultChallenge.getWords().size(), is(3));
    assertThat(user2ResultChallenge.getWords().get(0), not(user2ResultChallenge.getWords().get(1)));
    assertThat(user2ResultChallenge.getWords().get(1), not(user2ResultChallenge.getWords().get(2)));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user2ResultChallenge, /*pairIdx=*/0));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user2ResultChallenge, /*pairIdx=*/1));
    assertThat("The word-meaning pair is not valid",
        isWordMeaningPairValid(user2ResultChallenge, /*pairIdx=*/2));

  }

  @Test
  public void addMeaningChallenge_invalidNumberOfWords_shouldFail() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddMeaningChallengeResponse expectedResponse = new AddMeaningChallengeResponse();
    expectedResponse
        .setStatus(new Status(Status.TAFSEER_CHALLENGE_INCORRECT_NUMBER_OF_WORDS_ERROR));

    AddMeaningChallengeRequest request = getMeaningChallengeWithFriendAndNumberOfWords(user2, 2);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    request = getMeaningChallengeWithFriendAndNumberOfWords(user2, 1);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    request = getMeaningChallengeWithFriendAndNumberOfWords(user2, 10);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

  }

  @Test
  public void addMeaningChallenge_validNumberOfWords_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    AddMeaningChallengeRequest request = getMeaningChallengeWithFriendAndNumberOfWords(user2, null);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));

    request = getMeaningChallengeWithFriendAndNumberOfWords(user2, 3);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));

    request = getMeaningChallengeWithFriendAndNumberOfWords(user2, 5);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));

    request = getMeaningChallengeWithFriendAndNumberOfWords(user2, 9);
    httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON));

  }

  private AddMeaningChallengeRequest getMeaningChallengeWithFriendAndNumberOfWords(
      User friend,
      Integer numberOfWords) {
    return AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(friend.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .numberOfWords(numberOfWords)
        .build();
  }

  @Test
  public void addMeaningChallenge_notFriend_shouldFail() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MvcResult mvcResult = httpClient.performPostRequest(user1, "/challenges/meaning",
        JsonHandler.toJson(request))
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andReturn();

    AddMeaningChallengeResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), AddMeaningChallengeResponse.class);

    assertThat(response.getStatus().code, equalTo(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
  }

  @Test
  public void getMeaningChallenge_normalScenario_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MeaningChallenge meaningChallengeResponse =
        azkarApi.addMeaningChallengeAndReturn(user1, request);

    MvcResult mvcResult = httpClient
        .performGetRequest(user1, String.format("/challenges/meaning/%s",
            meaningChallengeResponse.getId()))
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andReturn();
    GetMeaningChallengeResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), GetMeaningChallengeResponse.class);

    MeaningChallenge resultMeaningChallenge = response.getData();
    assertThat(resultMeaningChallenge.getId(), equalTo(meaningChallengeResponse.getId()));
    assertThat(resultMeaningChallenge.getMeanings().get(0),
        equalTo(meaningChallengeResponse.getMeanings().get(0)));
    assertThat(resultMeaningChallenge.getMeanings().get(1),
        equalTo(meaningChallengeResponse.getMeanings().get(1)));
    assertThat(resultMeaningChallenge.getMeanings().get(2),
        equalTo(meaningChallengeResponse.getMeanings().get(2)));
  }

  @Test
  public void finishMeaningChallenge_normalScenario_shouldUpdateScore() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();
    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MeaningChallenge meaningChallengeResponse =
        azkarApi.addMeaningChallengeAndReturn(user1, request);

    httpClient
        .performPutRequest(user1, String.format("/challenges/finish/meaning/%s",
            meaningChallengeResponse.getId()), /*body=*/null)
        .andExpect(status().isOk())
        .andExpect(content().json(JsonHandler.toJson(new FinishMeaningChallengeResponse())));

    GetFriendsLeaderboardV2Response expectedResponse = new GetFriendsLeaderboardV2Response();
    User sabeq = userRepo.findById(User.SABEQ_ID).get();
    List<Friend> expectedFriendshipScores = ImmutableList.of(
        Friend.builder()
            .userTotalScore(0)
            .friendTotalScore(0)
            .userId(sabeq.getId())
            .firstName(sabeq.getFirstName())
            .lastName(sabeq.getLastName())
            .username(sabeq.getUsername())
            .build(),

        Friend.builder()
            .userTotalScore(1)
            .friendTotalScore(0)
            .userId(user2.getId())
            .groupId(getFriendshipGroupId(user1, user2))
            .firstName(user2.getFirstName())
            .lastName(user2.getLastName())
            .username(user2.getUsername())
            .build(),

        Friend.builder()
            .userTotalScore(1)
            .friendTotalScore(0)
            .userId(user3.getId())
            .groupId(getFriendshipGroupId(user1, user3))
            .firstName(user3.getFirstName())
            .lastName(user3.getLastName())
            .username(user3.getUsername())
            .build()

    );

    expectedResponse.setData(expectedFriendshipScores);
    azkarApi.getFriendsLeaderboardV2WithApiVersion(user1, "1.4.0")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse), /*strict=*/false));
    azkarApi.getFriendsLeaderboardV2WithApiVersion(user1, "1.4.1")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse), /*strict=*/false));
  }

  @Test
  public void finishMeaningChallenge_alreadyFinished_shouldFail() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();
    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    AddMeaningChallengeRequest request = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MeaningChallenge meaningChallengeResponse =
        azkarApi.addMeaningChallengeAndReturn(user1, request);

    httpClient
        .performPutRequest(user1, String.format("/challenges/finish/meaning/%s",
            meaningChallengeResponse.getId()), /*body=*/null)
        .andExpect(status().isOk())
        .andExpect(content().json(JsonHandler.toJson(new FinishMeaningChallengeResponse())));

    FinishMeaningChallengeResponse expectedFinishChallengeResponse =
        new FinishMeaningChallengeResponse();
    expectedFinishChallengeResponse
        .setStatus(new Status(Status.CHALLENGE_HAS_ALREADY_BEEN_FINISHED));
    httpClient
        .performPutRequest(user1, String.format("/challenges/finish/meaning/%s",
            meaningChallengeResponse.getId()), /*body=*/null)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedFinishChallengeResponse)));

    GetFriendsLeaderboardV2Response expectedResponse = new GetFriendsLeaderboardV2Response();
    User sabeq = userRepo.findById(User.SABEQ_ID).get();
    List<Friend> expectedFriendshipScores = ImmutableList.of(
        Friend.builder()
            .userTotalScore(0)
            .friendTotalScore(0)
            .userId(sabeq.getId())
            .firstName(sabeq.getFirstName())
            .lastName(sabeq.getLastName())
            .username(sabeq.getUsername())
            .build(),

        Friend.builder()
            .userTotalScore(1)
            .friendTotalScore(0)
            .userId(user2.getId())
            .groupId(getFriendshipGroupId(user1, user2))
            .firstName(user2.getFirstName())
            .lastName(user2.getLastName())
            .username(user2.getUsername())
            .build(),

        Friend.builder()
            .userTotalScore(1)
            .friendTotalScore(0)
            .userId(user3.getId())
            .groupId(getFriendshipGroupId(user1, user3))
            .firstName(user3.getFirstName())
            .lastName(user3.getLastName())
            .username(user3.getUsername())
            .build()

    );

    expectedResponse.setData(expectedFriendshipScores);
    azkarApi.getFriendsLeaderboardV2WithApiVersion(user1, "1.4.0")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse), /*strict=*/false));
    azkarApi.getFriendsLeaderboardV2WithApiVersion(user1, "1.4.1")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse), /*strict=*/false));
  }

  private String getFriendshipGroupId(User user1, User user2) throws Exception {
    return friendshipRepo.findAll().stream()
        .filter(friendship -> friendship.getUserId().equals(user1.getId()))
        .findFirst()
        .get()
        .getFriends()
        .stream()
        .filter(friend -> friend.getUserId().equals(user2.getId()))
        .findFirst()
        .get()
        .getGroupId();
  }

  private boolean isWordMeaningPairValid(MeaningChallenge challenge, int pairIdx) {
    return tafseerCacher.getWordMeaningPairs().stream().anyMatch(
        wordMeaningPair -> wordMeaningPair.getWord().equals(challenge.getWords().get(0))
            && wordMeaningPair.getMeaning().equals(challenge.getMeanings().get(0)));
  }
}
