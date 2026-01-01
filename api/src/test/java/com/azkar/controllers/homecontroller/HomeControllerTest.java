package com.azkar.controllers.homecontroller;

import static com.azkar.factories.entities.ChallengeFactory.EXPIRY_DATE_OFFSET;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.AzkarApi;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.payload.challengecontroller.requests.AddAzkarChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddMeaningChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddReadingQuranChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddAzkarChallengeResponse;
import com.azkar.payload.challengecontroller.responses.AddReadingQuranChallengeResponse;
import com.azkar.payload.challengecontroller.responses.ReturnedChallenge;
import com.azkar.payload.homecontroller.GetHomeResponse;
import com.azkar.payload.utils.FeaturesVersions;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import java.util.List;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MvcResult;

public class HomeControllerTest extends TestBase {

  @Autowired
  AzkarApi azkarApi;

  @Test
  public void getHome() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long readingQuranChallengeExpiryDate = Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET;
    long meaningChallengeExpiryDate = readingQuranChallengeExpiryDate + EXPIRY_DATE_OFFSET;
    long azkarChallengeExpiryDate = meaningChallengeExpiryDate + EXPIRY_DATE_OFFSET;

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
        azkarApi.getHome(user1, FeaturesVersions.READING_QURAN_CHALLENGE_VERSION)
            .andExpect(status().isOk())
            .andReturn();
    GetHomeResponse response = JsonHandler
        .fromJson(mvcResult.getResponse().getContentAsString(), GetHomeResponse.class);
    List<ReturnedChallenge> challengesInResponse = response.getData().getChallenges();

    assertThat(response.getData().getChallenges().size(),
        is(/*new=*/3 + TestBase.STARTING_CHALLENGES_COUNT));

    assertThat(response.getData().getChallenges().get(0).getMeaningChallenge(), is(nullValue()));
    assertThat(response.getData().getChallenges().get(0).getAzkarChallenge(), is(nullValue()));

    assertThat(response.getData().getChallenges().get(1).getAzkarChallenge(), is(nullValue()));
    assertThat(response.getData().getChallenges().get(1).getReadingQuranChallenge(), is(nullValue()));

    assertThat(response.getData().getChallenges().get(2).getReadingQuranChallenge(), is(nullValue()));
    assertThat(response.getData().getChallenges().get(2).getMeaningChallenge(), is(nullValue()));

    // First-to-be-expired first.
    assertThat(response.getData().getChallenges().get(0).getReadingQuranChallenge().getId(),
        is(addReadingQuranChallengeResponse.getData().getId()));
    assertThat(response.getData().getChallenges().get(1).getMeaningChallenge().getId(),
        is(meaningChallengeResponse.getId()));
    assertThat(response.getData().getChallenges().get(2).getAzkarChallenge().getId(),
        is(addAzkarChallengeResponse.getData().getId()));

    List<Friend> friendsInResponse = response.getData().getFriends();
    assertThat(friendsInResponse.get(0).getUserId(), is(User.SABEQ_ID));
    assertThat(friendsInResponse.get(1).getUserId(), is(user2.getId()));
    assertThat(friendsInResponse.get(2).getUserId(), is(user3.getId()));

    List<Group> groupsInResponse = response.getData().getGroups();
    assertThat("A group that was created for users who are involved in the same challenge should "
            + "have been returned",
        groupsInResponse.stream().anyMatch(
            group -> group.getUsersIds().contains(user1.getId()) && group.getUsersIds()
                .contains(user2.getId()) && group.getUsersIds().contains(user3.getId())));
  }
}
