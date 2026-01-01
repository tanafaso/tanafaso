package com.azkar.controllers.challengecontroller;

import static com.azkar.factories.entities.ChallengeFactory.EXPIRY_DATE_OFFSET;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.CustomSimpleChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.factories.entities.GroupFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.AddAzkarChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddCustomSimpleChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddMeaningChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddReadingQuranChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddAzkarChallengeResponse;
import com.azkar.payload.challengecontroller.responses.AddReadingQuranChallengeResponse;
import com.azkar.payload.challengecontroller.responses.DeleteChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetChallengesV2Response;
import com.azkar.payload.challengecontroller.responses.GetFinishedChallengesCountResponse;
import com.azkar.payload.utils.FeaturesVersions;
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

public class ChallengeTest extends TestBase {

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
  public void deleteChallenge_normalScenario_shouldSucceed() throws Exception {
    AzkarChallenge queriedChallenge = createGroupChallenge(user, group);
    AzkarChallenge anotherChallenge = createGroupChallenge(user, group);
    DeleteChallengeResponse response = new DeleteChallengeResponse();
    response.setData(queriedChallenge);
    List<AzkarChallenge> userChallenges =
        userRepo.findById(user.getId()).get().getAzkarChallenges();
    assertThat(userChallenges.size(), is(/*new=*/2 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));

    azkarApi.deleteChallenge(user, queriedChallenge.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(response)));

    userChallenges = userRepo.findById(user.getId()).get().getAzkarChallenges();
    assertThat(userChallenges.size(), is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(userChallenges.get(1).getId(), equalTo(anotherChallenge.getId()));
  }


  @Test
  public void deleteChallenge_invalidChallengeId_shouldFail() throws Exception {
    DeleteChallengeResponse notFoundResponse = new DeleteChallengeResponse();
    notFoundResponse.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));

    azkarApi.deleteChallenge(user, "invalidChallengeId")
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(notFoundResponse)));
  }

  @Test
  public void deleteChallenge_userDoesNotHaveChallenge_shouldFail() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(group.getId());
    azkarApi.addAzkarChallenge(user, challenge).andExpect(status().isOk());
    User nonGroupMember = UserFactory.getNewUser();
    addNewUser(nonGroupMember);
    DeleteChallengeResponse notFoundResponse = new DeleteChallengeResponse();
    notFoundResponse.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));

    azkarApi.deleteChallenge(nonGroupMember, challenge.getId())
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(notFoundResponse)));
  }

  @Test
  public void getChallenges_normalScenario_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long readingQuranChallengeExpiryDate = Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET;
    long meaningChallengeExpiryDate = readingQuranChallengeExpiryDate + EXPIRY_DATE_OFFSET;
    long azkarChallengeExpiryDate = meaningChallengeExpiryDate + EXPIRY_DATE_OFFSET;
    long customSimpleChallengeExpiryDate = azkarChallengeExpiryDate + EXPIRY_DATE_OFFSET;

    // Add one reading Quran challenge.
    ReadingQuranChallenge readingQuranChallenge = ChallengeFactory.getNewReadingChallenge(
        "reading-quran-group-id").toBuilder()
        .expiryDate(readingQuranChallengeExpiryDate)
        .groupId(null)
        .build();
    AddReadingQuranChallengeRequest addReadingQuranChallengeRequest =
        AddReadingQuranChallengeRequest.AddReadingQuranChallengeRequestBuilder().
            friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
            .readingQuranChallenge(readingQuranChallenge)
            .build();

    MvcResult result = azkarApi.addReadingQuranChallenge(user1, addReadingQuranChallengeRequest)
        .andExpect(status().isOk())
        .andReturn();
    AddReadingQuranChallengeResponse addReadingQuranChallengeResponse =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddReadingQuranChallengeResponse.class);

    // Add one meaning challenge.
    AddMeaningChallengeRequest addMeaningChallengeRequest = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId()))
        .expiryDate(meaningChallengeExpiryDate)
        .build();
    MeaningChallenge meaningChallengeResponse =
        azkarApi.addMeaningChallengeAndReturn(user1, addMeaningChallengeRequest);

    // Add one azkar challenge.
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("groupId").toBuilder()
        .expiryDate(azkarChallengeExpiryDate)
        .groupId(null)
        .build();
    AddAzkarChallengeRequest addAzkarChallengeRequest =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
            .challenge(challenge)
            .build();

    result = azkarApi.addAzkarChallenge(user1, addAzkarChallengeRequest)
        .andExpect(status().isOk())
        .andReturn();
    AddAzkarChallengeResponse addAzkarChallengeResponse =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddAzkarChallengeResponse.class);

    MvcResult mvcResult =
        azkarApi.getAllChallengesV2(user1, FeaturesVersions.READING_QURAN_CHALLENGE_VERSION)
            .andExpect(status().isOk())
            .andReturn();
    GetChallengesV2Response response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), GetChallengesV2Response.class);
    assertThat(response.getData().size(), is(/*new=*/3 + TestBase.STARTING_CHALLENGES_COUNT));

    assertThat(response.getData().get(0).getMeaningChallenge(), is(nullValue()));
    assertThat(response.getData().get(0).getAzkarChallenge(), is(nullValue()));

    assertThat(response.getData().get(1).getAzkarChallenge(), is(nullValue()));
    assertThat(response.getData().get(1).getReadingQuranChallenge(), is(nullValue()));

    assertThat(response.getData().get(2).getReadingQuranChallenge(), is(nullValue()));
    assertThat(response.getData().get(2).getMeaningChallenge(), is(nullValue()));

    // Non-pending first then First-to-be-expired first.
    assertThat(response.getData().get(0).getReadingQuranChallenge().getId(),
        is(addReadingQuranChallengeResponse.getData().getId()));
    assertThat(response.getData().get(1).getMeaningChallenge().getId(),
        is(meaningChallengeResponse.getId()));
    assertThat(response.getData().get(2).getAzkarChallenge().getId(),
        is(addAzkarChallengeResponse.getData().getId()));

    // Finish meaning challenge.
    azkarApi.finishMeaningChallenge(user1, meaningChallengeResponse.getId());

    mvcResult = azkarApi.getAllChallengesV2(user1, FeaturesVersions.READING_QURAN_CHALLENGE_VERSION)
        .andExpect(status().isOk())
        .andReturn();
    response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), GetChallengesV2Response.class);

    // Non-pending first then First-to-be-expired first.
    assertThat(response.getData().get(0).getReadingQuranChallenge().getId(),
        is(addReadingQuranChallengeResponse.getData().getId()));
    assertThat(response.getData().get(1).getAzkarChallenge().getId(),
        is(addAzkarChallengeResponse.getData().getId()));
    // Skip the 3 automatically created challenges because the user haven't finished them so they
    // should appear before the finished one.
    assertThat(response.getData().get(5).getMeaningChallenge().getId(),
        is(meaningChallengeResponse.getId()));

    // Add one meaning challenge.
    AddCustomSimpleChallengeRequest addCustomSimpleChallengeRequest =
        AddCustomSimpleChallengeRequest.builder()
            .friendsIds(ImmutableList.of(user2.getId()))
            .expiryDate(customSimpleChallengeExpiryDate)
            .description("description")
            .build();
    CustomSimpleChallenge addCustomSimpleChallengeResponse =
        azkarApi.addCustomSimpleChallengeAndReturn(user1, addCustomSimpleChallengeRequest);

    mvcResult = azkarApi.getAllChallengesV2(user1, FeaturesVersions.CUSTOM_SIMPLE_CHALLENGE_VERSION)
        .andExpect(status().isOk())
        .andReturn();
    response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), GetChallengesV2Response.class);

    assertThat(response.getData().get(0).getReadingQuranChallenge().getId(),
        is(addReadingQuranChallengeResponse.getData().getId()));
    assertThat(response.getData().get(1).getAzkarChallenge().getId(),
        is(addAzkarChallengeResponse.getData().getId()));
    assertThat(response.getData().get(2).getCustomSimpleChallenge().getId(),
        is(addCustomSimpleChallengeResponse.getId()));
    // Skip the 3 automatically created challenges because the user haven't finished them so they
    // should appear before the finished one.
    assertThat(response.getData().get(6).getMeaningChallenge().getId(),
        is(meaningChallengeResponse.getId()));
  }

  @Test
  public void getFinishedChallengesCount_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long readingQuranChallengeExpiryDate = Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET;
    long meaningChallengeExpiryDate = readingQuranChallengeExpiryDate + EXPIRY_DATE_OFFSET;
    long azkarChallengeExpiryDate = meaningChallengeExpiryDate + EXPIRY_DATE_OFFSET;
    long customSimpleChallengeExpiryDate = azkarChallengeExpiryDate + EXPIRY_DATE_OFFSET;

    // Add one reading Quran challenge.
    ReadingQuranChallenge readingQuranChallenge = ChallengeFactory.getNewReadingChallenge(
        "reading-quran-group-id").toBuilder()
        .expiryDate(readingQuranChallengeExpiryDate)
        .groupId(null)
        .build();
    AddReadingQuranChallengeRequest addReadingQuranChallengeRequest =
        AddReadingQuranChallengeRequest.AddReadingQuranChallengeRequestBuilder().
            friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
            .readingQuranChallenge(readingQuranChallenge)
            .build();

    MvcResult result = azkarApi.addReadingQuranChallenge(user1, addReadingQuranChallengeRequest)
        .andExpect(status().isOk())
        .andReturn();
    AddReadingQuranChallengeResponse addReadingQuranChallengeResponse =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddReadingQuranChallengeResponse.class);

    // Add one meaning challenge.
    AddMeaningChallengeRequest addMeaningChallengeRequest = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId()))
        .expiryDate(meaningChallengeExpiryDate)
        .build();
    MeaningChallenge meaningChallengeResponse =
        azkarApi.addMeaningChallengeAndReturn(user1, addMeaningChallengeRequest);

    // Add one azkar challenge.
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("groupId").toBuilder()
        .expiryDate(azkarChallengeExpiryDate)
        .groupId(null)
        .build();
    AddAzkarChallengeRequest addAzkarChallengeRequest =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(ImmutableList.of(user2.getId(), user3.getId()))
            .challenge(challenge)
            .build();

    azkarApi.addAzkarChallenge(user1, addAzkarChallengeRequest)
        .andExpect(status().isOk())
        .andReturn();

    // Add one meaning challenge.
    AddCustomSimpleChallengeRequest addCustomSimpleChallengeRequest =
        AddCustomSimpleChallengeRequest.builder()
            .friendsIds(ImmutableList.of(user2.getId()))
            .expiryDate(customSimpleChallengeExpiryDate)
            .description("description")
            .build();
    CustomSimpleChallenge addCustomSimpleChallengeResponse =
        azkarApi.addCustomSimpleChallengeAndReturn(user1, addCustomSimpleChallengeRequest);

    // Finish some challenges
    azkarApi.finishMeaningChallenge(user1, meaningChallengeResponse.getId());
    azkarApi.finishReadingQuranChallenge(user1, addReadingQuranChallengeResponse.getData().getId());
    azkarApi.finishCustomSimpleChallenge(user1, addCustomSimpleChallengeResponse.getId());

    MvcResult mvcResult = azkarApi.getFinishedChallengesCount(user1)
        .andExpect(status().isOk())
        .andReturn();
    GetFinishedChallengesCountResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(),
            GetFinishedChallengesCountResponse.class);

    assertThat(response.getData(), is(3));
  }

  private AzkarChallenge createGroupChallenge(User user, Group group)
      throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(group.getId());
    return azkarApi.addAzkarChallengeAndReturn(user, challenge);
  }
}
