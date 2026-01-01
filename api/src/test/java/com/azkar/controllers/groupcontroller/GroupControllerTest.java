package com.azkar.controllers.groupcontroller;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.azkar.TestBase;
import com.azkar.controllers.utils.JsonHandler;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.factories.entities.GroupFactory;
import com.azkar.factories.entities.UserFactory;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.groupcontroller.responses.AddGroupResponse;
import com.azkar.payload.groupcontroller.responses.AddToGroupResponse;
import com.azkar.payload.groupcontroller.responses.GetGroupResponse;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

public class GroupControllerTest extends TestBase {

  @Autowired
  GroupRepo groupRepo;

  @Autowired
  UserRepo userRepo;

  @Autowired
  FriendshipRepo friendshipRepo;

  private User user1 = UserFactory.getNewUser();
  private User user2 = UserFactory.getNewUser();
  private User user3 = UserFactory.getNewUser();
  private User user4 = UserFactory.getNewUser();
  private Group user1Group = GroupFactory.getNewGroup(user1.getId());
  // A user who have never been authenticated and never added to the database.
  private User invalidUser = UserFactory.getNewUser();
  private User sabeq;

  @Before
  public void before() {
    addNewUser(user1);
    addNewUser(user2);
    addNewUser(user3);
    addNewUser(user4);
    groupRepo.save(user1Group);
    sabeq = userRepo.findById(User.SABEQ_ID).get();
  }

  @Test
  public void addGroup_normalScenario_shouldSucceed() throws Exception {
    final String TEST_GROUP_NAME = "example_name";
    long groupRepoCountBeforeOperation = groupRepo.count();

    MvcResult result =
        azkarApi.addGroup(user1, TEST_GROUP_NAME).andExpect(status().isOk()).andReturn();

    AddGroupResponse response = JsonHandler.fromJson(result.getResponse().getContentAsString(),
        AddGroupResponse.class);
    Group returnedGroup = response.getData();
    assertThat(returnedGroup.getName(), is(TEST_GROUP_NAME));
    assertThat(groupRepo.count(), is(groupRepoCountBeforeOperation + 1));
    assertThat(groupRepo.findById(returnedGroup.getId()).isPresent(), is(true));
  }

  @Test
  public void addUser_normalScenario_shouldSucceed() throws Exception {
    AddToGroupResponse expectedResponse = new AddToGroupResponse();

    azkarApi.makeFriends(user1, user2);

    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, user1Group.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Group updatedGroup = groupRepo.findById(user1Group.getId()).get();
    assertThat(updatedGroup.getUsersIds().size(), is(2));
    assertThat(updatedGroup.getUsersIds().get(0), equalTo(user1.getId()));
    assertThat(updatedGroup.getUsersIds().get(1), equalTo(user2.getId()));
  }

  @Test
  public void addUser_notFriend_shouldFail() throws Exception {
    AddToGroupResponse expectedResponse = new AddToGroupResponse();
    expectedResponse.setStatus(new Status(Status.NO_FRIENDSHIP_ERROR));
    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, user1Group.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void addUser_invalidOtherUser_shouldNotSucceed() throws Exception {
    AddToGroupResponse expectedResponse = new AddToGroupResponse();
    expectedResponse.setStatus(new Status(Status.INVITED_USER_INVALID_ERROR));
    azkarApi.addUserToGroup(/*invitingUser=*/user1, invalidUser, user1Group.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void addUser_invalidGroup_shouldNotSucceed() throws Exception {
    Group unSavedGroup = GroupFactory.getNewGroup(user1.getId());

    AddToGroupResponse expectedResponse = new AddToGroupResponse();
    expectedResponse.setStatus(new Status(Status.GROUP_INVALID_ERROR));
    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, unSavedGroup.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));

    Group user1GroupInRepo = groupRepo.findById(user1Group.getId()).get();
    assertThat(user1GroupInRepo.getUsersIds().size(), is(1));
  }

  @Test
  public void addUser_otherUserAlreadyMember_shouldNotSucceed() throws Exception {
    azkarApi.makeFriends(user1, user2);

    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, user1Group.getId());

    AddToGroupResponse expectedResponse = new AddToGroupResponse();
    expectedResponse.setStatus(new Status(Status.INVITED_USER_ALREADY_MEMBER_ERROR));

    azkarApi.addUserToGroup(/*invitingUser=*/user1, user2, user1Group.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

  @Test
  public void addUser_invitingUserIsNotMember_shouldNotSucceed() throws Exception {
    AddToGroupResponse expectedResponse = new AddToGroupResponse();
    expectedResponse.setStatus(new Status(Status.INVITING_USER_IS_NOT_MEMBER_ERROR));

    azkarApi.makeFriends(user2, user3);

    azkarApi.addUserToGroup(/*invitingUser=*/user2, user3, user1Group.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }

/*  @Test
  // TODO(Test this properly)
  public void getGroups_normalScenario_shouldSucceed() throws Exception {
    User user4 = getNewRegisteredUser();

    azkarApi.makeFriends(user3, user1);
    azkarApi.makeFriends(user3, user2);

    String user1Group1Name = "user1group1name";
    String user1Group2Name = "user1group2name";
    String user2Group1Name = "user2group1name";
    String user4Group1Name = "user4group1name";
    Group group1 = azkarApi.addGroupAndReturn(user1, user1Group1Name);
    Group group2 = azkarApi.addGroupAndReturn(user1, user1Group2Name);
    Group group3 = azkarApi.addGroupAndReturn(user2, user2Group1Name);
    azkarApi.addGroupAndReturn(user4, user4Group1Name);

    GetGroupsResponse expectedResponse = new GetGroupsResponse();
    // Add all currently existing groups that user 3 exist in before doing any of the operations
    // under test.
    List<Group> expectedUser3Groups =
        new ArrayList(groupRepo.findAll().stream()
            .filter(group -> group.getUsersIds().contains(user3.getId())).collect(
                Collectors.toList()));
    expectedUser3Groups.add(group1.toBuilder()
        .usersIds(ImmutableList.of(user1.getId(), user3.getId())).build());

    expectedUser3Groups.add(group2.toBuilder()
        .usersIds(ImmutableList.of(user1.getId(), user3.getId())).build());

    expectedUser3Groups.add(group3.toBuilder()
        .usersIds(ImmutableList.of(user2.getId(), user3.getId())).build());

    expectedResponse.setData(expectedUser3Groups);

    // Add user3 to group1.
    azkarApi.addUserToGroup(*//*invitingUser=*//*user1, user3, group1.getId());

    // Add user3 to group2.
    azkarApi.addUserToGroup(*//*invitingUser=*//*user1, user3, group2.getId());

    // Add user3 to group3.
    azkarApi.addUserToGroup(*//*invitingUser=*//*user2, user3, group3.getId());

    azkarApi.getGroups(user3)
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)));
  }*/

  @Test
  public void getGroup_normalScenario_shouldSucceed() throws Exception {
    azkarApi.addGroup(user1, "group1");
    Group group2 = azkarApi.addGroupAndReturn(user1, "group2");
    azkarApi.addGroup(user2, "group3");

    GetGroupResponse expectedResponse = new GetGroupResponse();
    expectedResponse.setData(group2);
    azkarApi.getGroup(user1, group2.getId())
        .andExpect(status().isOk())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)))
        .andReturn();
  }

  @Test
  public void getGroup_notMember_shouldFail() throws Exception {
    azkarApi.addGroup(user1, "group1");
    azkarApi.addGroup(user1, "group2");
    Group group3 = azkarApi.addGroupAndReturn(user2, "group3");

    GetGroupResponse expectedResponse = new GetGroupResponse();
    expectedResponse.setStatus(new Status(Status.NOT_MEMBER_IN_GROUP_ERROR));
    azkarApi.getGroup(user1, group3.getId())
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)))
        .andReturn();
  }

  @Test
  public void getGroup_notExistingGroup_shouldFail() throws Exception {
    azkarApi.addGroup(user1, "group1");
    azkarApi.addGroup(user1, "group2");
    azkarApi.addGroup(user2, "group3");

    GetGroupResponse expectedResponse = new GetGroupResponse();
    expectedResponse.setStatus(new Status(Status.NOT_MEMBER_IN_GROUP_ERROR));
    azkarApi.getGroup(user1, "nonExistingGroupId")
        .andExpect(status().isBadRequest())
        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
        .andExpect(content().json(JsonHandler.toJson(expectedResponse)))
        .andReturn();
  }
}
