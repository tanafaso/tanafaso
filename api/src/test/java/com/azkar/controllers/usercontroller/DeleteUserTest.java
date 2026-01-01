package com.azkar.controllers.usercontroller;

import static com.azkar.factories.entities.ChallengeFactory.EXPIRY_DATE_OFFSET;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.AzkarApi;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.AddAzkarChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddMeaningChallengeRequest;
import com.azkar.payload.usercontroller.responses.DeleteUserResponse;
import com.azkar.payload.usercontroller.responses.GetUserResponse;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import java.util.List;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;


public class DeleteUserTest extends TestBase {

  @Autowired
  AzkarApi azkarApi;

  @Test
  public void deleteUser_normalScenario_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();

    azkarApi.addToPubliclyAvailableMales(user1);

    User user2 = getNewRegisteredUser();
    azkarApi.makeFriends(user1, user2);

    // user1 creating a meaning challenge
    AddMeaningChallengeRequest addMeaningChallengeRequest = AddMeaningChallengeRequest.builder()
        .friendsIds(ImmutableList.of(user2.getId()))
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .build();
    MeaningChallenge meaningChallenge =
        azkarApi.addMeaningChallengeAndReturn(user1, addMeaningChallengeRequest);

    // user2 creating an azkar challenge
    User user3 = getNewRegisteredUser();
    azkarApi.makeFriends(user2, user3);
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("groupId").toBuilder()
        .expiryDate(Instant.now().getEpochSecond() + EXPIRY_DATE_OFFSET)
        .groupId(null)
        .build();
    AddAzkarChallengeRequest addAzkarChallengeRequest =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(ImmutableList.of(user1.getId(), user3.getId()))
            .challenge(challenge)
            .build();
    AzkarChallenge azkarChallenge =
        azkarApi.addAzkarChallengeAndReturn(user2, addAzkarChallengeRequest);

    // delete user
    DeleteUserResponse expectedResponse = new DeleteUserResponse();
    expectedResponse.setData(
        User.builder()
            .id(user1.getId())
            .username(user1.getUsername())
            .firstName(user1.getFirstName())
            .lastName(user1.getLastName())
            .build()
    );
    azkarApi.deleteUser(user1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    // try to retrieve user after deletion
    GetUserResponse expectedGetUserResponse = new GetUserResponse();
    expectedGetUserResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));
    azkarApi.getUserById(user2, user1.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedGetUserResponse)));

    // try to retrieve friendships
    List<Friend> user2Friends = azkarApi.getFriendsLeaderboardV2AndReturn(user2);
    assertThat(user2Friends.size(), is(1));
    assertThat(user2Friends.get(0).getUserId(), is(user3.getId()));

    // try to retrieve meaning challenge group
    Group meaningChallengeGroup = azkarApi.getGroupAndReturn(user2, meaningChallenge.getGroupId());
    assertThat(meaningChallengeGroup.getUsersIds().size(), is(1));
    assertThat(meaningChallengeGroup.getUsersIds().get(0), is(user2.getId()));

    // try to retrieve azkar challenge group
    Group azkarChallengeGroup = azkarApi.getGroupAndReturn(user2, azkarChallenge.getGroupId());
    assertThat(azkarChallengeGroup.getUsersIds().size(), is(2));
    assertThat("", azkarChallengeGroup.getUsersIds().contains(user2.getId()));
    assertThat("", azkarChallengeGroup.getUsersIds().contains(user3.getId()));
  }
}
