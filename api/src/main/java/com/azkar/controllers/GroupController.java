package com.azkar.controllers;

import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.groupcontroller.requests.AddGroupRequest;
import com.azkar.payload.groupcontroller.responses.AddGroupResponse;
import com.azkar.payload.groupcontroller.responses.AddToGroupResponse;
import com.azkar.payload.groupcontroller.responses.GetGroupResponse;
import com.azkar.payload.groupcontroller.responses.GetGroupsResponse;
import com.azkar.repos.AzkarChallengeRepo;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.azkar.services.GroupsService;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/groups", produces = MediaType.APPLICATION_JSON_VALUE)
public class GroupController extends BaseController {

  private static final Logger logger = LoggerFactory.getLogger(GroupController.class);

  @Autowired
  private GroupRepo groupRepo;
  @Autowired
  private AzkarChallengeRepo challengeRepo;
  @Autowired
  private UserRepo userRepo;
  @Autowired
  private FriendshipRepo friendshipRepo;
  @Autowired
  private GroupsService groupsService;

  @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<AddGroupResponse> addGroup(@RequestBody AddGroupRequest req) {
    req.validate();

    User currentUser = getCurrentUser(userRepo);
    Group newGroup =
        Group.builder()
            .name(req.getName())
            .creatorId(currentUser.getId())
            .usersIds(new ArrayList<>(Collections.singletonList(currentUser.getId())))
            .build();
    newGroup = groupRepo.save(newGroup);

    userRepo.save(currentUser);

    AddGroupResponse response = new AddGroupResponse();
    response.setData(newGroup);
    return ResponseEntity.ok(response);
  }

  @GetMapping(value = "/{groupId}")
  public ResponseEntity<GetGroupResponse> getGroup(@PathVariable String groupId) {
    GetGroupResponse response = new GetGroupResponse();

    Optional<Group> group = groupRepo.findById(groupId);
    // Check whether the group is deleted.
    if (!group.isPresent()) {
      response.setStatus(new Status(Status.NOT_MEMBER_IN_GROUP_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    User currentUser = getCurrentUser(userRepo);
    if (!group.get().getUsersIds().stream()
        .anyMatch(userId -> userId.equals(currentUser.getId()))) {
      response.setStatus(new Status(Status.NOT_MEMBER_IN_GROUP_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    response.setData(group.get());
    return ResponseEntity.ok(response);
  }

  @GetMapping()
  public ResponseEntity<GetGroupsResponse> getGroups() {
    GetGroupsResponse response = new GetGroupsResponse();
    List<Group> groups;
    try {
      groups = groupsService.getGroups(getCurrentUser(userRepo)).get();
    } catch (InterruptedException e) {
      GetGroupsResponse errorResponse = new GetGroupsResponse();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    } catch (ExecutionException e) {
      GetGroupsResponse errorResponse = new GetGroupsResponse();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    }
    response.setData(groups);
    return ResponseEntity.ok(response);
  }

  @PutMapping(value = "/{groupId}/add/{userId}")
  public ResponseEntity<AddToGroupResponse> addUser(
      @PathVariable String groupId,
      @PathVariable(value = "userId") String invitedUserId) {
    AddToGroupResponse response = new AddToGroupResponse();

    // Check if the ID of the user to be added is valid.
    Optional<User> userToAdd = userRepo.findById(invitedUserId);
    if (!userToAdd.isPresent()) {
      response.setStatus(new Status(Status.INVITED_USER_INVALID_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the group id is valid.
    Optional<Group> group = groupRepo.findById(groupId);
    if (!group.isPresent()) {
      response.setStatus(new Status(Status.GROUP_INVALID_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the two users are friends
    if (!friendshipRepo.findByUserId(getCurrentUser().getUserId()).getFriends().stream()
        .anyMatch(friend -> friend.getUserId().equals(invitedUserId) && !friend.isPending())) {
      response.setStatus(new Status(Status.NO_FRIENDSHIP_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the inviting user is a member of the group.
    if (!isMember(userRepo.findById(getCurrentUser().getUserId()).get(), group.get())) {
      response.setStatus(new Status(Status.INVITING_USER_IS_NOT_MEMBER_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the invited user is already a member of the group.
    if (isMember(userToAdd.get(), group.get())) {
      response.setStatus(new Status(Status.INVITED_USER_ALREADY_MEMBER_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    group.get().getUsersIds().add(userToAdd.get().getId());
    userRepo.save(userToAdd.get());
    groupRepo.save(group.get());
    return ResponseEntity.ok(response);
  }

  private boolean isMember(User user, Group group) {
    return group.getUsersIds().stream().anyMatch(userId -> userId.equals(user.getId()));
  }
}
