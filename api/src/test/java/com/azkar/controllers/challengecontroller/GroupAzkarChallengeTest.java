package com.azkar.controllers.challengecontroller;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.util.AssertionErrors.assertTrue;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.User.UserGroup;
import com.azkar.entities.Zekr;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.factories.entities.ChallengeFactory;
import com.azkar.factories.entities.GroupFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.requests.AddAzkarChallengeRequest;
import com.azkar.payload.challengecontroller.responses.AddAzkarChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetChallengesResponse;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.google.common.collect.ImmutableList;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;

public class GroupAzkarChallengeTest extends TestBase {

  private static final String CHALLENGE_NAME_PREFIX_1 = "challenge_1_";
  private static final String CHALLENGE_NAME_PREFIX_2 = "challenge_2_";

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
  public void addChallenge_multipleMembersInGroup_shouldSucceed() throws Exception {
    User anotherGroupMember = getNewRegisteredUser();
    User nonGroupMember = getNewRegisteredUser();

    azkarApi.makeFriends(user1, anotherGroupMember);
    azkarApi.addUserToGroup(/* invitingUser= */ user1, anotherGroupMember, validGroup.getId());
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(validGroup.getId());
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setData(challenge.toBuilder()
        .creatingUserId(user1.getId())
        .usersFinished(new ArrayList<>())
        .build()
    );

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isOk())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    assertThat(challengesProgress.size(), is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    List<String> groupChallenges = groupRepo.findById(validGroup.getId()).get().getChallengesIds();
    assertThat(groupChallenges.size(), is(1));
    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedAnotherGroupMember = userRepo.findById(anotherGroupMember.getId()).get();
    User updatedNonGroupMember = userRepo.findById(nonGroupMember.getId()).get();
    assertThat(updatedUser1.getAzkarChallenges().size(),
        is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedAnotherGroupMember.getAzkarChallenges().size(),
        is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedNonGroupMember.getAzkarChallenges().size(),
        is(0 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addFriendsChallenge_normalScenario_shouldSucceed() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);
    azkarApi.makeFriends(user1, user3);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("toBeRemovedGroupId").toBuilder()
        .groupId(null)
        .build();

    AddAzkarChallengeRequest request =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(friendsIds)
            .challenge(challenge)
            .build();
    MvcResult result = azkarApi.addAzkarChallenge(user1, request)
        .andExpect(status().isOk())
        .andReturn();
    AddAzkarChallengeResponse response =
        JsonHandler.fromJson(result.getResponse().getContentAsString(),
            AddAzkarChallengeResponse.class);
    AzkarChallenge resultChallenge = response.getData();

    assertThat(groupRepo.count(), is(groupsNumBefore + 1));

    assertThat(resultChallenge.getName(), equalTo(challenge.getName()));
    assertThat(resultChallenge.getGroupId(), notNullValue());

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();

    assertThat(updatedUser1.getAzkarChallenges().size(),
        is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedUser2.getAzkarChallenges().size(),
        is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedUser3.getAzkarChallenges().size(),
        is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));

    assertThat(
        updatedUser1.getAzkarChallenges().get(TestBase.STARTING_AZKAR_CHALLENGES_COUNT).getName(),
        equalTo(challenge.getName()));
  }

  @Test
  public void addFriendsChallenge_notFriend_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();
    User user3 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user3.getId());
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("toBeRemovedGroupId").toBuilder()
        .groupId(null)
        .build();

    AddAzkarChallengeRequest request =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(friendsIds)
            .challenge(challenge)
            .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
    azkarApi.addAzkarChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();
    User updatedUser3 = userRepo.findById(user3.getId()).get();

    assertThat(updatedUser1.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedUser2.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedUser3.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addFriendsChallenge_oneFriendProvided_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId());
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("toBeRemovedGroupId").toBuilder()
        .groupId(null)
        .build();

    AddAzkarChallengeRequest request =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(friendsIds)
            .challenge(challenge)
            .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.LESS_THAN_TWO_FRIENDS_ARE_PROVIDED_ERROR));
    azkarApi.addAzkarChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();

    assertThat(updatedUser1.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedUser2.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addFriendsChallenge_duplicateFriendIds_shouldFail() throws Exception {
    User user2 = getNewRegisteredUser();

    azkarApi.makeFriends(user1, user2);

    long groupsNumBefore = groupRepo.count();

    List<String> friendsIds = ImmutableList.of(user2.getId(), user2.getId());
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge("toBeRemovedGroupId").toBuilder()
        .groupId(null)
        .build();

    AddAzkarChallengeRequest request =
        AddAzkarChallengeRequest.AddFriendsChallengeRequestBuilder().
            friendsIds(friendsIds)
            .challenge(challenge)
            .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.DUPLICATE_FRIEND_IDS_PROVIDED_ERROR));
    azkarApi.addAzkarChallenge(user1, request)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    assertThat(groupRepo.count(), is(groupsNumBefore));

    User updatedUser1 = userRepo.findById(user1.getId()).get();
    User updatedUser2 = userRepo.findById(user2.getId()).get();

    assertThat(updatedUser1.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(updatedUser2.getAzkarChallenges().size(),
        is(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addChallenge_oneMemberInGroup_shouldSucceed() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(validGroup.getId());
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setData(challenge.toBuilder()
        .creatingUserId(user1.getId())
        .usersFinished(new ArrayList<>())
        .build()
    );

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isOk())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    List<String> groupChallenges = groupRepo.findById(validGroup.getId()).get().getChallengesIds();
    assertThat(challengesProgress.size(), is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(groupChallenges.size(), is(1));
  }

  @Test
  public void addChallenge_zeroSubChallengeRepetitions_shouldNotSucceed() throws Exception {
    long expiryDate = Instant.now().getEpochSecond() + ChallengeFactory.EXPIRY_DATE_OFFSET;
    SubChallenge zeroRepetitionSubChallenge =
        SubChallenge.builder().zekr(Zekr.builder().id(1).zekr("zekr").build())
            .build();
    AzkarChallenge challenge = AzkarChallenge.builder()
        .name(ChallengeFactory.CHALLENGE_NAME_BASE)
        .motivation(ChallengeFactory.CHALLENGE_MOTIVATION)
        .expiryDate(expiryDate)
        .subChallenges(ImmutableList.of(zeroRepetitionSubChallenge))
        .groupId(validGroup.getId())
        .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.MALFORMED_SUB_CHALLENGES_ERROR));

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    assertThat(challengesProgress.size(), equalTo(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addChallenge_duplicateZekr_shouldNotSucceed() throws Exception {
    long expiryDate = Instant.now().getEpochSecond() + ChallengeFactory.EXPIRY_DATE_OFFSET;
    SubChallenge subChallenge1 =
        SubChallenge.builder().repetitions(2).zekr(Zekr.builder().id(1).zekr("zekr").build())
            .build();
    SubChallenge subChallenge2 =
        SubChallenge.builder().repetitions(3).zekr(Zekr.builder().id(1).zekr("zekr").build())
            .build();
    AzkarChallenge challenge = AzkarChallenge.builder()
        .name(ChallengeFactory.CHALLENGE_NAME_BASE)
        .motivation(ChallengeFactory.CHALLENGE_MOTIVATION)
        .expiryDate(expiryDate)
        .subChallenges(ImmutableList.of(subChallenge1, subChallenge2))
        .groupId(validGroup.getId())
        .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.CHALLENGE_CREATION_DUPLICATE_ZEKR_ERROR));

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    assertThat(challengesProgress.size(), equalTo(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addChallenge_invalidGroup_shouldNotSucceed() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(invalidGroup.getId());
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.GROUP_NOT_FOUND_ERROR));

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    assertThat(challengesProgress.size(), equalTo(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
  }

  @Test
  public void addChallenge_nonGroupMember_shouldNotSucceed() throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(validGroup.getId());
    User nonGroupMember = UserFactory.getNewUser();
    addNewUser(nonGroupMember);
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.NOT_GROUP_MEMBER_ERROR));

    azkarApi.addAzkarChallenge(nonGroupMember, challenge)
        .andExpect(status().isForbidden())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> userChallenges = userRepo.findById(nonGroupMember.getId())
        .get()
        .getAzkarChallenges();
    assertThat(userChallenges.size(), equalTo(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    List<String> groupChallenges = groupRepo.findById(validGroup.getId()).get().getChallengesIds();
    assertThat(groupChallenges, empty());
  }

  @Test
  public void addChallenge_missingMotivationField_shouldSucceed() throws Exception {
    long expiryDate = Instant.now().getEpochSecond() + ChallengeFactory.EXPIRY_DATE_OFFSET;
    AzkarChallenge challenge = AzkarChallenge.builder()
        .name(ChallengeFactory.CHALLENGE_NAME_BASE)
        .expiryDate(expiryDate)
        .subChallenges(
            ImmutableList.of(ChallengeFactory.azkarSubChallenge1()))
        .groupId(validGroup.getId())
        .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setData(challenge);

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isOk())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    List<String> groupChallenges = groupRepo.findById(validGroup.getId()).get().getChallengesIds();
    assertThat(challengesProgress.size(), is(1 + TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    assertThat(groupChallenges.size(), is(1));
  }

  @Test
  public void addChallenge_pastExpiryDate_shouldNotSucceed() throws Exception {
    long pastExpiryDate = Instant.now().getEpochSecond() - ChallengeFactory.EXPIRY_DATE_OFFSET;
    AzkarChallenge challenge = AzkarChallenge.builder()
        .name(ChallengeFactory.CHALLENGE_NAME_BASE)
        .motivation(ChallengeFactory.CHALLENGE_MOTIVATION)
        .expiryDate(pastExpiryDate)
        .subChallenges(
            ImmutableList.of(ChallengeFactory.azkarSubChallenge1()))
        .groupId(validGroup.getId())
        .build();
    AddAzkarChallengeResponse expectedResponse = new AddAzkarChallengeResponse();
    expectedResponse.setStatus(new Status(Status.PAST_EXPIRY_DATE_ERROR));

    azkarApi.addAzkarChallenge(user1, challenge)
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    List<AzkarChallenge> challengesProgress = userRepo.findById(user1.getId()).get()
        .getAzkarChallenges();
    assertThat(challengesProgress.size(), equalTo(TestBase.STARTING_AZKAR_CHALLENGES_COUNT));
    List<String> groupChallenges = groupRepo.findById(validGroup.getId()).get().getChallengesIds();
    assertTrue("GroupChallenges list is expected to be empty but it is not.",
        groupChallenges.isEmpty());
  }



  @Test
  public void getGroupChallenges_invalidGroup_shouldFail() throws Exception {
    GetChallengesResponse expectedResponse = new GetChallengesResponse();
    expectedResponse.setStatus(new Status(Status.GROUP_NOT_FOUND_ERROR));

    azkarApi.getAllChallengesInGroup(user1, invalidGroup.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getGroupChallenges_nonGroupMember_shouldFail() throws Exception {
    User nonGroupMember = getNewRegisteredUser();
    GetChallengesResponse expectedResponse = new GetChallengesResponse();
    expectedResponse.setStatus(new Status(Status.NON_GROUP_MEMBER_ERROR));

    azkarApi.getAllChallengesInGroup(nonGroupMember, validGroup.getId())
        .andExpect(status().isForbidden())
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void getGroupChallenges_multipleGroups_shouldSucceed() throws Exception {
    Group anotherGroup = GroupFactory.getNewGroup(user1.getId());
    groupRepo.save(anotherGroup);
    addNewValidChallenge(user1, /* challengeNamePrefix= */"", validGroup.getId());

    GetChallengesResponse validGroupAllChallenges = getAllChallengesInGroup(user1,
        validGroup.getId());
    GetChallengesResponse anotherGroupAllChallenges = getAllChallengesInGroup(user1,
        anotherGroup.getId());

    assertThat(validGroupAllChallenges.getData(), hasSize(1));
    assertThat(anotherGroupAllChallenges.getData(), empty());
  }

  private GetChallengesResponse getAllChallengesInGroup(User user, String groupId)
      throws Exception {
    ResultActions resultActions = azkarApi.getAllChallengesInGroup(user, groupId)
        .andExpect(status().isOk());
    return getResponse(resultActions, GetChallengesResponse.class);
  }

  private ResultActions addNewValidChallenge(User creatingUser, String challengeNamePrefix,
      String groupId)
      throws Exception {
    AzkarChallenge challenge = ChallengeFactory.getNewChallenge(challengeNamePrefix, groupId);
    return azkarApi.addAzkarChallenge(creatingUser, challenge);
  }
}
