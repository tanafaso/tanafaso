package com.azkar.controllers.friendshipcontroller;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.AzkarApi;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Friendship;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.UpdateChallengeRequest;
import com.azkar.payload.usercontroller.responses.AddFriendResponse;
import com.azkar.payload.usercontroller.responses.DeleteFriendResponse;
import com.azkar.payload.usercontroller.responses.GetFriendsLeaderboardV2Response;
import com.azkar.payload.usercontroller.responses.GetFriendsResponse;
import com.azkar.payload.usercontroller.responses.ResolveFriendRequestResponse;
import com.azkar.repos.AzkarChallengeRepo;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

public class FriendshipTest extends TestBase {

  private static final int SUB_CHALLENGES_REPETITIONS = 2;

  private static User USER1;
  private static User USER2;
  private static User USER3;
  private static User USER4;
  private static User USER5;
  private static User UNAUTHENTICATED_USER;
  @Autowired
  FriendshipRepo friendshipRepo;
  @Autowired
  GroupRepo groupRepo;
  @Autowired
  AzkarChallengeRepo challengeRepo;
  @Autowired
  UserRepo userRepo;
  @Autowired
  AzkarApi azkarApi;
  private User sabeq;

  @Before
  public void before() {
    USER1 = UserFactory.getNewUser();
    USER2 = UserFactory.getNewUser();
    USER3 = UserFactory.getNewUser();
    USER4 = UserFactory.getNewUser();
    USER5 = UserFactory.getNewUser();
    UNAUTHENTICATED_USER = UserFactory.getNewUser();
    addNewUser(USER1);
    addNewUser(USER2);
    addNewUser(USER3);
    addNewUser(USER4);
    addNewUser(USER5);
    sabeq = userRepo.findById(User.SABEQ_ID).get();
  }

  @Test
  public void addFriend_normalScenario_shouldSucceed() throws Exception {
    AddFriendResponse expectedResponse = new AddFriendResponse();
    long groupsCount = groupRepo.count();

    azkarApi.sendFriendRequest(USER1, USER2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(USER2.getId());

    // Only sabeq
    assertThat(user1Friendship.getFriends().size(), is(1));
    assertThat(user2Friendship.getFriends().size(), is(2));

    Friend user2Friend = user2Friendship.getFriends().get(1);
    assertFriendship(user2Friend, USER1, /*isPending=*/true);

    assertThat(groupRepo.count(), equalTo(groupsCount));
  }

  @Test
  public void addFriend_requesterRequestedBefore_shouldNotSucceed() throws Exception {
    long groupsCountBefore = groupRepo.count();

    azkarApi.sendFriendRequest(USER1, USER2);

    AddFriendResponse expectedResponse = new AddFriendResponse();
    expectedResponse.setStatus(new Status(Status.FRIENDSHIP_ALREADY_REQUESTED_ERROR));

    azkarApi.sendFriendRequest(USER1, USER2)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    assertThat(groupRepo.count(), is(groupsCountBefore));
  }


  @Test
  public void addFriend_responderRequestedBefore_shouldAddNonPendingFriendship() throws Exception {
    azkarApi.sendFriendRequest(USER1, USER2);

    AddFriendResponse expectedResponse = new AddFriendResponse();
    azkarApi.sendFriendRequest(USER2, USER1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(USER2.getId());

    assertThat(user1Friendship.getFriends().size(), is(2));
    assertThat(user2Friendship.getFriends().size(), is(2));

    Friend user1Friend1 = user1Friendship.getFriends().get(0);
    assertFriendship(user1Friend1, sabeq, /*isPending=*/false);

    Friend user1Friend2 = user1Friendship.getFriends().get(1);
    assertFriendship(user1Friend2, USER2, /*isPending=*/false);

    Friend user2Friend1 = user2Friendship.getFriends().get(0);
    assertFriendship(user2Friend1, sabeq, /*isPending=*/false);

    Friend user2Friend2 = user2Friendship.getFriends().get(1);
    assertFriendship(user2Friend2, USER1, /*isPending=*/false);

    assertThat(user1Friend2.getGroupId(), notNullValue());
    assertThat(user1Friend2.getGroupId(), is(user2Friend2.getGroupId()));
  }


  @Test
  public void addFriend_invalidResponder_shouldNotSucceed() throws Exception {
    AddFriendResponse expectedResponse = new AddFriendResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));

    azkarApi.sendFriendRequest(USER1, UNAUTHENTICATED_USER)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void addFriend_addSelf_shouldNotSucceed() throws Exception {
    AddFriendResponse expectedResponse = new AddFriendResponse();
    expectedResponse.setStatus(new Status(Status.ADD_SELF_ERROR));

    azkarApi.sendFriendRequest(USER1, USER1)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void acceptFriendRequest_normalScenario_shouldSucceed() throws Exception {
    long groupsCountBefore = groupRepo.count();

    azkarApi.sendFriendRequest(USER1, USER2);

    ResolveFriendRequestResponse expectedResponse = new ResolveFriendRequestResponse();
    azkarApi.acceptFriendRequest(USER2, USER1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(USER2.getId());

    // Sabeq and the new friend.
    assertThat(user1Friendship.getFriends().size(), is(2));
    assertThat(user2Friendship.getFriends().size(), is(2));

    Friend user1Friend = user1Friendship.getFriends().get(1);
    assertFriendship(user1Friend, USER2, /*isPending=*/false);

    Friend user2Friend = user2Friendship.getFriends().get(1);
    assertFriendship(user2Friend, USER1, /*isPending=*/false);

    assertThat(groupRepo.count(), equalTo(groupsCountBefore + 1));
    Group group = Iterators.getLast(groupRepo.findAll().iterator());
    assertThat(group.getUsersIds().size(), equalTo(2));
    assertThat(group.getUsersIds().contains(USER1.getId()), is(true));
    assertThat(group.getUsersIds().contains(USER2.getId()), is(true));

    assertThat(user1Friend.getGroupId(), notNullValue());
    assertThat(user1Friend.getGroupId(), equalTo(user2Friend.getGroupId()));
  }

  @Test
  public void rejectFriendRequest_normalScenario_shouldSucceed() throws Exception {
    long groupsCountBefore = groupRepo.count();

    azkarApi.sendFriendRequest(USER1, USER2);

    ResolveFriendRequestResponse expectedResponse = new ResolveFriendRequestResponse();
    azkarApi.rejectFriendRequest(USER2, USER1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(USER2.getId());

    // only sabeq is a friend
    assertThat(user1Friendship.getFriends().size(), is(1));
    assertThat(user2Friendship.getFriends().size(), is(1));
    assertThat(groupRepo.count(), equalTo(groupsCountBefore));
  }

  @Test
  public void acceptFriendRequest_friendshipNotPending_shouldNotSucceed() throws Exception {
    ResolveFriendRequestResponse expectedResponse = new ResolveFriendRequestResponse();
    expectedResponse
        .setStatus(new Status(Status.NO_FRIEND_REQUEST_EXIST_ERROR));
    azkarApi.acceptFriendRequest(USER1, USER2)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(USER2.getId());

    // Only sabeq is a friend.
    assertThat(user1Friendship.getFriends().size(), is(1));
    assertThat(user2Friendship.getFriends().size(), is(1));
  }

  @Test
  public void resolveFriendship_noFriendshipExist_shouldNotSucceed() throws Exception {
    ResolveFriendRequestResponse expectedResponse = new ResolveFriendRequestResponse();
    expectedResponse
        .setStatus(new Status(Status.NO_FRIEND_REQUEST_EXIST_ERROR));

    azkarApi.acceptFriendRequest(USER1, USER2)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    azkarApi.rejectFriendRequest(USER2, USER1)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void resolveFriendship_friendshipAlreadyExists_shouldNotSucceed() throws Exception {
    azkarApi.sendFriendRequest(USER1, USER2);
    azkarApi.acceptFriendRequest(USER2, USER1);

    ResolveFriendRequestResponse expectedResponse = new ResolveFriendRequestResponse();
    expectedResponse
        .setStatus(new Status(Status.FRIEND_REQUEST_ALREADY_ACCEPTED_ERROR));
    azkarApi.acceptFriendRequest(USER1, USER2)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    azkarApi.rejectFriendRequest(USER1, USER2)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    azkarApi.acceptFriendRequest(USER2, USER1)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    azkarApi.rejectFriendRequest(USER2, USER1)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }


  @Test
  public void getFriends_normalScenario_shouldSucceed() throws Exception {
    azkarApi.sendFriendRequest(USER1, USER5);

    azkarApi.makeFriends(USER1, USER2);
    azkarApi.makeFriends(USER3, USER4);
    azkarApi.makeFriends(USER3, USER1);

    // user1 expected friends.
    List<Friend> expectedUser1Friends = new ArrayList();
/*    expectedUser1Friends.add(Friend.builder()
        .userId(sabeq.getId())
        .username(sabeq.getUsername())
        .firstName(sabeq.getFirstName())
        .lastName(sabeq.getLastName())
        .isPending(false)
        .build()
    );*/
    expectedUser1Friends.add(Friend.builder()
        .userId(USER2.getId())
        .username(USER2.getUsername())
        .firstName(USER2.getFirstName())
        .lastName(USER2.getLastName())
        .isPending(false)
        .build()
    );
    expectedUser1Friends.add(Friend.builder()
        .userId(USER3.getId())
        .username(USER3.getUsername())
        .firstName(USER3.getFirstName())
        .lastName(USER3.getLastName())
        .isPending(false)
        .build()
    );

    MvcResult mvcResult =
        performGetRequest(USER1, "/friends")
            .andExpect(status().isOk())
            .andReturn();

    GetFriendsResponse getUser1FriendsResponse =
        JsonHandler
            .fromJson(mvcResult.getResponse().getContentAsString(), GetFriendsResponse.class);

    compareFriendshipList(getUser1FriendsResponse.getData().getFriends(), expectedUser1Friends);

    // user5 expected friends.
    List<Friend> expectedUser5Friends = new ArrayList();
/*    expectedUser5Friends.add(Friend.builder()
        .userId(sabeq.getId())
        .username(sabeq.getUsername())
        .firstName(sabeq.getFirstName())
        .lastName(sabeq.getLastName())
        .isPending(false)
        .build()
    );*/
    expectedUser5Friends.add(Friend.builder()
        .userId(USER1.getId())
        .username(USER1.getUsername())
        .firstName(USER1.getFirstName())
        .lastName(USER1.getLastName()).isPending(true)
        .build()
    );
    mvcResult = performGetRequest(USER5, "/friends")
        .andExpect(status().isOk())
        .andReturn();

    GetFriendsResponse getUser5FriendsResponse =
        JsonHandler
            .fromJson(mvcResult.getResponse().getContentAsString(), GetFriendsResponse.class);

    compareFriendshipList(getUser5FriendsResponse.getData().getFriends(), expectedUser5Friends);
  }

  @Test
  public void deleteFriend_deleteSabeq_shouldFail() throws Exception {
    long groupsCountBefore = groupRepo.count();

    DeleteFriendResponse expectedResponse = new DeleteFriendResponse();
    expectedResponse.setStatus(new Status(Status.CANNOT_REMOVE_SABEQ__FROM_FRIENDS_ERROR));
    azkarApi.deleteFriend(USER1, userRepo.findById(User.SABEQ_ID).get())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());

    // Sabeq is still a friend.
    assertThat(user1Friendship.getFriends().size(), is(1));
    assertThat("Removing sabeq was expected to fail",
        user1Friendship.getFriends().stream()
            .anyMatch(friend -> friend.getUserId().equals(User.SABEQ_ID)));

    assertThat(groupRepo.count(), equalTo(groupsCountBefore));
    User updatedUser1 = userRepo.findById(USER1.getId()).get();
  }

  @Test
  public void deleteFriend_normalScenario_shouldSucceed() throws Exception {
    azkarApi.makeFriends(USER1, USER2);
    long groupsCountAfterFriendship = groupRepo.count();

    DeleteFriendResponse expectedResponse = new DeleteFriendResponse();
    azkarApi.deleteFriend(USER1, USER2)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Friendship user1Friendship = friendshipRepo.findByUserId(USER1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(USER2.getId());

    // Only sabeq is left as a friend
    assertThat(user1Friendship.getFriends().size(), is(1));
    assertThat(user2Friendship.getFriends().size(), is(1));

    assertThat(groupRepo.count(), equalTo(groupsCountAfterFriendship));
    User updatedUser1 = userRepo.findById(USER1.getId()).get();
    User updatedUser2 = userRepo.findById(USER2.getId()).get();
  }

  @Test
  public void deleteFriend_invalidUser_shouldSucceed() throws Exception {
    DeleteFriendResponse expectedResponse = new DeleteFriendResponse();
    expectedResponse.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));

    azkarApi.deleteFriend(USER1, UNAUTHENTICATED_USER)
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void deleteFriend_friendRequestIsPending_shouldNotSucceed() throws Exception {
    azkarApi.sendFriendRequest(USER1, USER2);

    DeleteFriendResponse expectedResponse = new DeleteFriendResponse();
    expectedResponse.setStatus(new Status(Status.NO_FRIENDSHIP_ERROR));
    azkarApi.deleteFriend(USER1, USER2)
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void deleteFriend_noFriendRequestExist_shouldNotSucceed() throws Exception {
    DeleteFriendResponse expectedResponse = new DeleteFriendResponse();
    expectedResponse.setStatus(new Status(Status.NO_FRIENDSHIP_ERROR));

    azkarApi.deleteFriend(USER1, USER2)
        .andExpect(status().isNotFound())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }


  @Test
  public void getFriendsLeaderboardV2_notSupportingSabeqFeature_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();
    User user4 = getNewRegisteredUser();

    // user1 is friends with user2 and user3 only.
    azkarApi.makeFriends(user1, user2);
    String user1And2FriendshipGroupId = getFriendshipGroupId(user1, user2);
    azkarApi.makeFriends(user1, user3);
    String user1And3FriendshipGroupId = getFriendshipGroupId(user1, user3);
    azkarApi.makeFriends(user2, user3);
    azkarApi.makeFriends(user3, user4);

    // Members = [user1, user2]
    Group group1 = azkarApi.addGroupAndReturn(user1, "group1");
    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, group1.getId());

    // Members = [user1, user2]
    Group group2 = azkarApi.addGroupAndReturn(user2, "group2");
    azkarApi.addUserToGroup(/*invitingUser=*/user2, user1, group2.getId());

    // Members = [user1, user2, user3]
    Group group3 = azkarApi.addGroupAndReturn(user1, "group3");
    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, group3.getId());
    azkarApi.addUserToGroup(/*invitingUser=*/user2, user3, group3.getId());

    // Members = [user3, user4]
    Group group4 = azkarApi.addGroupAndReturn(user3, "group4");
    azkarApi.addUserToGroup(/*invitingUser=*/user3, user4, group4.getId());

    AzkarChallenge challenge = createChallengeInGroup(user1, user1And2FriendshipGroupId);
    createChallengeInGroup(user1, user1And2FriendshipGroupId);
    finishChallenge(user1, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 0]
    // [user1, user3] = [0, 0]
    // [user1, user4] = [0, 0]

    challenge = createChallengeInGroup(user1, user1And3FriendshipGroupId);
    finishChallenge(user3, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 0]
    // [user1, user3] = [0, 1]

    challenge = createChallengeInGroup(user3, group4.getId());
    finishChallenge(user3, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 0]
    // [user1, user3] = [0, 1]

    challenge = createChallengeInGroup(user1, group1.getId());
    finishChallenge(user2, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 1]
    // [user1, user3] = [0, 1]

    challenge = createChallengeInGroup(user3, group3.getId());
    finishChallenge(user1, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [2, 1]
    // [user1, user3] = [1, 1]

    GetFriendsLeaderboardV2Response expectedResponse = new GetFriendsLeaderboardV2Response();
    List<Friend> expectedFriendshipScores = ImmutableList.of(
        Friend.builder()
            .userTotalScore(2)
            .friendTotalScore(1)
            .userId(user2.getId())
            .groupId(user1And2FriendshipGroupId)
            .firstName(user2.getFirstName())
            .lastName(user2.getLastName())
            .username(user2.getUsername())
            .build(),

        Friend.builder()
            .userTotalScore(1)
            .friendTotalScore(1)
            .userId(user3.getId())
            .groupId(user1And3FriendshipGroupId)
            .firstName(user3.getFirstName())
            .lastName(user3.getLastName())
            .username(user3.getUsername())
            .build()

    );

    expectedResponse.setData(expectedFriendshipScores);
    azkarApi.getFriendsLeaderboardV2(user1)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse), /*strict=*/false));
    azkarApi.getFriendsLeaderboardV2WithApiVersion(user1, "1.3.9")
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse), /*strict=*/false));
  }

  @Test
  public void getFriendsLeaderboardV2_supportingSabeqFeature_shouldSucceed() throws Exception {
    User user1 = getNewRegisteredUser();
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();
    User user4 = getNewRegisteredUser();

    // user1 is friends with user2 and user3 only.
    azkarApi.makeFriends(user1, user2);
    String user1And2FriendshipGroupId = getFriendshipGroupId(user1, user2);
    azkarApi.makeFriends(user1, user3);
    String user1And3FriendshipGroupId = getFriendshipGroupId(user1, user3);
    azkarApi.makeFriends(user2, user3);
    azkarApi.makeFriends(user3, user4);

    // Members = [user1, user2]
    Group group1 = azkarApi.addGroupAndReturn(user1, "group1");
    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, group1.getId());

    // Members = [user1, user2]
    Group group2 = azkarApi.addGroupAndReturn(user2, "group2");
    azkarApi.addUserToGroup(/*invitingUser=*/user2, user1, group2.getId());

    // Members = [user1, user2, user3]
    Group group3 = azkarApi.addGroupAndReturn(user1, "group3");
    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, group3.getId());
    azkarApi.addUserToGroup(/*invitingUser=*/user2, user3, group3.getId());

    // Members = [user3, user4]
    Group group4 = azkarApi.addGroupAndReturn(user3, "group4");
    azkarApi.addUserToGroup(/*invitingUser=*/user3, user4, group4.getId());

    AzkarChallenge challenge = createChallengeInGroup(user1, user1And2FriendshipGroupId);
    createChallengeInGroup(user1, user1And2FriendshipGroupId);
    finishChallenge(user1, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 0]
    // [user1, user3] = [0, 0]
    // [user1, user4] = [0, 0]

    challenge = createChallengeInGroup(user1, user1And3FriendshipGroupId);
    finishChallenge(user3, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 0]
    // [user1, user3] = [0, 1]

    challenge = createChallengeInGroup(user3, group4.getId());
    finishChallenge(user3, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 0]
    // [user1, user3] = [0, 1]

    challenge = createChallengeInGroup(user1, group1.getId());
    finishChallenge(user2, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [1, 1]
    // [user1, user3] = [0, 1]

    challenge = createChallengeInGroup(user3, group3.getId());
    finishChallenge(user1, challenge.getId());
    // Friends Scores Now:
    // [user1, user2] = [2, 1]
    // [user1, user3] = [1, 1]

    GetFriendsLeaderboardV2Response expectedResponse = new GetFriendsLeaderboardV2Response();
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
            .userTotalScore(2)
            .friendTotalScore(1)
            .userId(user2.getId())
            .groupId(user1And2FriendshipGroupId)
            .firstName(user2.getFirstName())
            .lastName(user2.getLastName())
            .username(user2.getUsername())
            .build(),

        Friend.builder()
            .userTotalScore(1)
            .friendTotalScore(1)
            .userId(user3.getId())
            .groupId(user1And3FriendshipGroupId)
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

  private void compareFriendshipList(List<Friend> actual, List<Friend> expected) {
    Collections.sort(actual, Comparator.comparing(Friend::getUserId));
    Collections.sort(expected, Comparator.comparing(Friend::getUserId));

    assertThat(actual.size(), equalTo(expected.size()));

    for (int i = 0; i < actual.size(); i++) {
      Friend actualFriend = actual.get(i);
      Friend expectedFriend = actual.get(i);
      assertThat(actualFriend.getUserId(), equalTo(expectedFriend.getUserId()));
      assertThat(actualFriend.getUsername(), equalTo(expectedFriend.getUsername()));
      assertThat(actualFriend.isPending(), equalTo(expectedFriend.isPending()));
    }
  }

  private AzkarChallenge createChallengeInGroup(User user, String groupId) throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(groupId);
    challenge.setSubChallenges(ImmutableList.of(ChallengeFactory.azkarSubChallenge1()));
    challenge.getSubChallenges().get(0).setRepetitions(SUB_CHALLENGES_REPETITIONS);
    azkarApi.addAzkarChallenge(user, challenge).andExpect(status().isOk());
    return challenge;
  }

  private void finishChallenge(User user, String challengeId) throws Exception {
    AzkarChallenge challenge = challengeRepo.findById(challengeId).get();
    assertThat(challenge.getSubChallenges().size(), is(1));
    challenge.getSubChallenges().get(0).setRepetitions(0);
    UpdateChallengeRequest request =
        UpdateChallengeRequest.builder().newChallenge(challenge).build();
    UpdateChallengeRequest.builder().newChallenge(challenge).build();
    azkarApi.updateChallenge(user, challengeId, request);
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

  private void assertFriendship(Friend friend, User user, boolean isPending) {
    assertThat(friend.getUserId(), equalTo(user.getId()));
    assertThat(friend.getUsername(), equalTo(user.getUsername()));
    assertThat(friend.isPending(), is(isPending));
  }
}
