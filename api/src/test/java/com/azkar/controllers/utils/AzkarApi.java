package com.azkar.controllers.utils;

import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.CustomSimpleChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.MemorizationChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.azkar.payload.authenticationcontroller.requests.ResetPasswordRequest;
import com.azkar.payload.challengecontroller.requests.AddAzkarChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddCustomSimpleChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddMeaningChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddMemorizationChallengeRequest;
import com.azkar.payload.challengecontroller.requests.AddReadingQuranChallengeRequest;
import com.azkar.payload.challengecontroller.requests.UpdateChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddAzkarChallengeResponse;
import com.azkar.payload.challengecontroller.responses.AddCustomSimpleChallengeResponse;
import com.azkar.payload.challengecontroller.responses.AddMeaningChallengeResponse;
import com.azkar.payload.challengecontroller.responses.AddMemorizationChallengeResponse;
import com.azkar.payload.challengecontroller.responses.AddReadingQuranChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetFinishedChallengesCountResponse;
import com.azkar.payload.groupcontroller.requests.AddGroupRequest;
import com.azkar.payload.groupcontroller.responses.AddGroupResponse;
import com.azkar.payload.groupcontroller.responses.GetGroupResponse;
import com.azkar.payload.usercontroller.requests.SetNotificationTokenRequestBody;
import com.azkar.payload.usercontroller.responses.GetFriendsLeaderboardV2Response;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;

@Service
public class AzkarApi {

  @Autowired
  HttpClient httpClient;

  public ResultActions getProfileV2(User user) throws Exception {
    return httpClient.performGetRequest(user, "/users/me/v2");
  }

  public ResultActions getProfileWithoutAuthentication() throws Exception {
    return httpClient.performGetRequest(/*user=*/ (User) null, "/users/me");
  }

  public ResultActions getUserById(User user, String id) throws Exception {
    return httpClient.performGetRequest(user, String.format("/users/%s", id));
  }

  public ResultActions deleteUser(User user) throws Exception {
    return httpClient.performDeleteRequest(user, "/users/me");
  }

  public ResultActions getPubliclyAvailableUsers(User user) throws Exception {
    return httpClient.performGetRequest(user, "/users/publicly_available_users");
  }

  public ResultActions getPubliclyAvailableUsersWithPagination(User user, int pageNum)
      throws Exception {
    return httpClient.performGetRequest(user,
        String.format("/users/publicly_available_users?page_num=%d", pageNum));
  }

  public ResultActions addToPubliclyAvailableMales(User user) throws Exception {
    return httpClient.performPutRequest(user, "/users/publicly_available_males");
  }

  public ResultActions addToPubliclyAvailableFemales(User user) throws Exception {
    return httpClient.performPutRequest(user, "/users/publicly_available_females");
  }

  public ResultActions deleteFromPubliclyAvailableUsers(User user) throws Exception {
    return httpClient.performDeleteRequest(user, "/users/publicly_available_users");
  }

  public ResultActions searchForUserByUsername(User user, String username) throws Exception {
    return httpClient.performGetRequest(user, String.format("/users/search?username=%s", username));
  }

  public ResultActions sendNotificationsToken(User user, SetNotificationTokenRequestBody body)
      throws Exception {
    return httpClient.performPutRequest(user, "/users/notifications/token",
        JsonHandler.toJson(body));
  }

  public ResultActions searchForUserByFacebookUserId(User user, String facebookUserId)
      throws Exception {
    return httpClient.performGetRequest(user, String.format("/users/search?facebook_user_id=%s",
        facebookUserId));
  }

  public ResultActions getChallenge(User user, String challengeId) throws Exception {
    return httpClient.performGetRequest(user, String.format("/challenges/%s", challengeId));
  }

  public ResultActions deleteChallenge(User user, String challengeId) throws Exception {
    return httpClient.performDeleteRequest(user, String.format("/challenges/%s", challengeId));
  }

  public ResultActions deletePersonalChallenge(User user, String challengeId) throws Exception {
    return httpClient.performDeleteRequest(user, String.format("/challenges/personal/%s",
        challengeId));
  }

  public ResultActions getOriginalChallenge(User user, String challengeId) throws Exception {
    return httpClient.performGetRequest(user, String.format("/challenges/original/%s",
        challengeId));
  }

  public AzkarChallenge getChallengeAndReturn(User user, String challengeId) throws Exception {
    MvcResult result = httpClient.performGetRequest(user, String.format("/challenges/%s",
        challengeId)).andReturn();
    GetChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(), GetChallengeResponse.class);
    return response.getData();
  }

  public AzkarChallenge addAzkarChallengeAndReturn(User user, AzkarChallenge challenge)
      throws Exception {
    MvcResult result = addAzkarChallenge(user, challenge).andReturn();
    AddAzkarChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddAzkarChallengeResponse.class);
    return response.getData();
  }

  public ResultActions addAzkarChallenge(User user, AzkarChallenge challenge) throws Exception {
    return httpClient.performPostRequest(user, "/challenges",
        JsonHandler.toJson(new AddChallengeRequest(challenge)));
  }

  public ReadingQuranChallenge addReadingQuranChallengeAndReturn(User user,
      AddReadingQuranChallengeRequest request) throws Exception {
    MvcResult result = addReadingQuranChallenge(user, request).andReturn();
    AddReadingQuranChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddReadingQuranChallengeResponse.class);
    return response.getData();
  }


  public ResultActions addReadingQuranChallenge(User user,
      AddReadingQuranChallengeRequest request) throws Exception {
    return httpClient.performPostRequest(user, "/challenges/reading_quran",
        JsonHandler.toJson(request));
  }

  public CustomSimpleChallenge addCustomSimpleChallengeAndReturn(User user,
      AddCustomSimpleChallengeRequest request) throws Exception {
    MvcResult result = addCustomSimpleChallenge(user, request).andReturn();
    AddCustomSimpleChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddCustomSimpleChallengeResponse.class);
    return response.getData();
  }


  public ResultActions addCustomSimpleChallenge(User user,
      AddCustomSimpleChallengeRequest request) throws Exception {
    return httpClient.performPostRequest(user, "/challenges/simple",
        JsonHandler.toJson(request));
  }


  public MemorizationChallenge addMemorizationChallengeAndReturn(User user,
      AddMemorizationChallengeRequest request) throws Exception {
    MvcResult result = addMemorizationChallenge(user, request).andReturn();
    AddMemorizationChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddMemorizationChallengeResponse.class);
    return response.getData();
  }


  public ResultActions addMemorizationChallenge(User user,
      AddMemorizationChallengeRequest request) throws Exception {
    return httpClient.performPostRequest(user, "/challenges/memorization",
        JsonHandler.toJson(request));
  }

  public MeaningChallenge addMeaningChallengeAndReturn(User user,
      AddMeaningChallengeRequest request)
      throws Exception {
    MvcResult result = addMeaningChallenge(user, request).andReturn();
    AddMeaningChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddMeaningChallengeResponse.class);
    return response.getData();
  }

  public ResultActions addMeaningChallenge(User user, AddMeaningChallengeRequest request)
      throws Exception {
    return httpClient.performPostRequest(user, "/challenges/meaning",
        JsonHandler.toJson(request));
  }

  public ResultActions finishMeaningChallenge(User user, String meaningChallengeId)
      throws Exception {
    return httpClient.performPutRequest(user, String.format("/challenges/finish/meaning/%s",
        meaningChallengeId));
  }

  public ResultActions finishReadingQuranChallenge(User user, String readingQuranChallengeId)
      throws Exception {
    return httpClient.performPutRequest(user, String.format("/challenges/finish/reading_quran/%s",
        readingQuranChallengeId));
  }

  public ResultActions finishCustomSimpleChallenge(User user, String customSimpleChallengeId)
      throws Exception {
    return httpClient.performPutRequest(user, String.format("/challenges/finish/simple/%s",
        customSimpleChallengeId));
  }

  public ResultActions finishMemorizationChallengeQuestion(User user,
      String challengeId, String question)
      throws Exception {
    return httpClient.performPutRequest(user, String.format("/challenges/finish/memorization/%s/%s",
        challengeId, question));
  }

  public AzkarChallenge addAzkarChallengeAndReturn(User user,
      AddAzkarChallengeRequest request) throws Exception {
    MvcResult result = addAzkarChallenge(user, request).andReturn();
    AddAzkarChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddAzkarChallengeResponse.class);
    return response.getData();
  }

  public ResultActions addAzkarChallenge(User user, AddAzkarChallengeRequest request)
      throws Exception {
    return httpClient.performPostRequest(user, "/challenges/friends", JsonHandler.toJson(request));
  }

  public ResultActions getAllChallengesInGroup(User user, String groupId) throws Exception {
    return httpClient
        .performGetRequest(user, String.format("/challenges/groups/%s/", groupId));
  }

  public ResultActions updateChallenge(User user, String challengeId,
      UpdateChallengeRequest request) throws Exception {
    return httpClient.performPutRequest(user, String.format("/challenges/%s", challengeId),
        JsonHandler.toJson(request));
  }


  public Group addGroupAndReturn(User user, String groupName) throws Exception {
    MvcResult result = addGroup(user, groupName).andReturn();
    AddGroupResponse response = JsonHandler.fromJson(result.getResponse().getContentAsString(),
        AddGroupResponse.class);
    return response.getData();
  }

  public ResultActions addGroup(User user, String name) throws Exception {
    return httpClient.performPostRequest(user, "/groups",
        JsonHandler.toJson(AddGroupRequest.builder().name(name).build()));
  }

  public Group getGroupAndReturn(User user, String groupId) throws Exception {
    MvcResult result = getGroup(user, groupId).andReturn();
    GetGroupResponse response = JsonHandler.fromJson(result.getResponse().getContentAsString(),
        GetGroupResponse.class);
    return response.getData();
  }

  public ResultActions getGroup(User user, String groupId) throws Exception {
    return httpClient.performGetRequest(user, String.format("/groups/%s", groupId));
  }

  public ResultActions getGroups(User user) throws Exception {
    return httpClient.performGetRequest(user, "/groups");
  }

  public ResultActions addUserToGroup(User invitingUser, User invitedUser, String groupId)
      throws Exception {
    return httpClient.performPutRequest(invitingUser, String.format("/groups/%s/add/%s", groupId,
        invitedUser.getId()),
        /*body=*/ null);
  }

  public ResultActions resetPassword(String email) throws Exception {
    return httpClient.performPostRequest("/reset_password",
        JsonHandler.toJson(ResetPasswordRequest.builder().email(email).build()));
  }

  public ResultActions verifyResetPasswordToken(String token) throws Exception {
    return httpClient
        .performGetRequest(/* token= */ "", String.format("/update_password/?token=%s", token));
  }

  public ResultActions updatePassword(String token, String password) throws Exception {
    return httpClient.submitUpdatePasswordForm(token, password);
  }

  public ResultActions sendFriendRequest(User requester, User responder) throws Exception {
    return httpClient.performPutRequest(requester, String.format("/friends/%s",
        responder.getId()),
        /*body=*/ null);
  }

  public ResultActions acceptFriendRequest(User responder, User requester) throws Exception {
    return httpClient
        .performPutRequest(responder, String.format("/friends/%s/accept", requester.getId()),
            /*body=*/null);
  }

  public ResultActions rejectFriendRequest(User responder, User requester) throws Exception {
    return httpClient
        .performPutRequest(responder, String.format("/friends/%s/reject", requester.getId()),
            /*body=*/null);
  }

  public ResultActions deleteFriend(User requester, User otherUser) throws Exception {
    return httpClient
        .performDeleteRequest(requester, String.format("/friends/%s", otherUser.getId()));
  }

  public List<Friend> getFriendsLeaderboardV2AndReturn(User user) throws Exception {
    MvcResult result = getFriendsLeaderboardV2(user).andReturn();
    GetFriendsLeaderboardV2Response response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            GetFriendsLeaderboardV2Response.class);
    return response.getData();
  }

  public ResultActions callNonExistingEndpoint(User user) throws Exception {
    // /friends/leaderboard has been removed.
    return httpClient.performGetRequest(user, "/friends/leaderboard/");
  }

  public ResultActions getFriendsLeaderboardV2(User user) throws Exception {
    return httpClient.performGetRequest(user, "/friends/leaderboard/v2");
  }

  public ResultActions getFriendsLeaderboardV2WithApiVersion(User user, String apiVersion)
      throws Exception {
    return httpClient.performGetRequestWithApiVersion(user, "/friends/leaderboard/v2", apiVersion);
  }

  public ResultActions getAllChallengesV2(User user, String apiVersion)
      throws Exception {
    return httpClient.performGetRequestWithApiVersion(user, "/challenges/v2", apiVersion);
  }

  public ResultActions getFinishedChallengesCount(User user)
      throws Exception {
    return httpClient.performGetRequest(user, "/challenges/finished-challenges-count");
  }

  public int getFinishedChallengesCountAndReturn(User user)
      throws Exception {
    MvcResult result = getFinishedChallengesCount(user).andReturn();
    GetFinishedChallengesCountResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            GetFinishedChallengesCountResponse.class);
    return response.getData();
  }

  public ResultActions getHome(User user, String apiVersion) throws Exception {
    return httpClient.performGetRequestWithApiVersion(user, "/apiHome", apiVersion);
  }

  public void makeFriends(User user1, User user2) throws Exception {
    sendFriendRequest(user1, user2);
    acceptFriendRequest(user2, user1);
  }
}
