package com.azkar.controllers;

import com.azkar.entities.Friendship;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.usercontroller.responses.AddFriendResponse;
import com.azkar.payload.usercontroller.responses.DeleteFriendResponse;
import com.azkar.payload.usercontroller.responses.GetFriendsLeaderboardV2Response;
import com.azkar.payload.usercontroller.responses.GetFriendsResponse;
import com.azkar.payload.usercontroller.responses.ResolveFriendRequestResponse;
import com.azkar.payload.utils.FeaturesVersions;
import com.azkar.payload.utils.VersionComparator;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.azkar.services.FriendshipService;
import com.azkar.services.NotificationsService;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/friends", produces = MediaType.APPLICATION_JSON_VALUE)
public class FriendshipController extends BaseController {

  private static final Logger logger = LoggerFactory.getLogger(FriendshipController.class);

  @Autowired
  private NotificationsService notificationsService;
  @Autowired
  private FriendshipRepo friendshipRepo;
  @Autowired
  private UserRepo userRepo;
  @Autowired
  private GroupRepo groupRepo;
  @Autowired
  private FriendshipService friendshipService;

  @GetMapping
  public ResponseEntity<GetFriendsResponse> getFriends(
      @RequestHeader(value = API_VERSION_HEADER, required = false) String apiVersion) {
    GetFriendsResponse response = new GetFriendsResponse();

    Friendship friendship = friendshipRepo.findByUserId(getCurrentUser().getUserId());
    List<Friend> friends = friendship.getFriends();
    if (apiVersion == null
        || VersionComparator.compare(apiVersion, FeaturesVersions.SABEQ_ADDITION_VERSION) < 0) {
      friends = friends.stream().filter(friend -> !friend.getUserId().equals(User.SABEQ_ID))
          .collect(Collectors.toList());
    }
    friendship.setFriends(friends);
    response.setData(friendship);
    return ResponseEntity.ok(response);
  }

  @GetMapping(path = "/leaderboard/v2")
  public ResponseEntity<GetFriendsLeaderboardV2Response> getFriendsLeaderboardV2(
      @RequestHeader(value = API_VERSION_HEADER, required = false) String apiVersion) {
    GetFriendsLeaderboardV2Response response = new GetFriendsLeaderboardV2Response();

    List<Friend> friends = null;
    try {
      friends = friendshipService.getFriendsLeaderboard(apiVersion,
          getCurrentUser(userRepo)).get();
    } catch (InterruptedException e) {
      GetFriendsLeaderboardV2Response errorResponse = new GetFriendsLeaderboardV2Response();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    } catch (ExecutionException e) {
      GetFriendsLeaderboardV2Response errorResponse = new GetFriendsLeaderboardV2Response();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    }

    response.setData(friends);
    return ResponseEntity.ok(response);
  }

  @PutMapping(path = "/{id}")
  public ResponseEntity<AddFriendResponse> add(
      @PathVariable(value = "id") String otherUserId) {
    AddFriendResponse response = new AddFriendResponse();

    User currentUser = userRepo.findById(getCurrentUser().getUserId()).get();
    if (currentUser.getId().equals(otherUserId)) {
      response.setStatus(new Status(Status.ADD_SELF_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the provided id is valid.
    Optional<User> otherUser = userRepo.findById(otherUserId);
    if (!otherUser.isPresent()) {
      response.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the current user already requested friendship with the other user.
    Friendship otherUserFriendship = friendshipRepo.findByUserId(otherUserId);
    if (otherUserFriendship.getFriends().stream()
        .anyMatch(friend -> friend.getUserId().equals(currentUser.getId()))) {
      response.setStatus(new Status(Status.FRIENDSHIP_ALREADY_REQUESTED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the other user already requested friendship with the current user. If this is the
    // case then the friendship should not be pending anymore.
    Friendship currentUserFriendship = friendshipRepo.findByUserId(currentUser.getId());
    Optional<Friend> friend = currentUserFriendship.getFriends().stream()
        .filter(f -> f.getUserId().equals(otherUserId))
        .findAny();
    if (friend.isPresent()) {
      Group binaryGroup = generateBinaryGroup(currentUser, friend.get());
      groupRepo.save(binaryGroup);

      // Set isPending for the current user.
      friend.get().setPending(false);
      friend.get().setGroupId(binaryGroup.getId());

      // Set isPending for the current user.
      otherUserFriendship.getFriends().add(
          Friend.builder()
              .userId(currentUser.getId())
              .groupId(binaryGroup.getId())
              .username(currentUser.getUsername())
              .firstName(currentUser.getFirstName())
              .lastName(currentUser.getLastName())
              .isPending(false)
              .build()
      );

      friendshipRepo.save(currentUserFriendship);
      friendshipRepo.save(otherUserFriendship);
      return ResponseEntity.ok().body(response);
    }

    otherUserFriendship.getFriends().add(
        Friend.builder()
            .userId(currentUser.getId())
            .username(currentUser.getUsername())
            .firstName(currentUser.getFirstName())
            .lastName(currentUser.getLastName())
            .isPending(true)
            .build()
    );
    friendshipRepo.save(otherUserFriendship);
    notificationsService.sendNotificationToUser(otherUser.get(), "لديك طلب صداقة جديد",
        currentUser.getFirstName() + " " + currentUser.getLastName());

    return ResponseEntity.ok(response);
  }

  @PutMapping(path = "/{id}/accept")
  public ResponseEntity<ResolveFriendRequestResponse> accept(
      @PathVariable(value = "id") String otherUserId) {
    ResolveFriendRequestResponse response = new ResolveFriendRequestResponse();

    User currentUser = userRepo.findById(getCurrentUser().getUserId()).get();

    // Assert that the current user has a pending friend request from the other user.
    Friendship currentUserFriendship = friendshipRepo.findByUserId(currentUser.getId());
    Optional<Friend> friend = currentUserFriendship.getFriends().stream()
        .filter(f -> f.getUserId().equals(otherUserId))
        .findAny();
    if (!friend.isPresent()) {
      response.setStatus(new Status(Status.NO_FRIEND_REQUEST_EXIST_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    // Check if the users are already friends.
    if (!friend.get().isPending()) {
      response
          .setStatus(new Status(Status.FRIEND_REQUEST_ALREADY_ACCEPTED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    Group binaryGroup = generateBinaryGroup(currentUser, friend.get());
    groupRepo.save(binaryGroup);

    friend.get().setPending(false);
    friend.get().setGroupId(binaryGroup.getId());
    Friendship otherUserFriendship = friendshipRepo.findByUserId(otherUserId);

    otherUserFriendship.getFriends().add(
        Friend.builder()
            .userId(currentUser.getId())
            .username(currentUser.getUsername())
            .firstName(currentUser.getFirstName())
            .lastName(currentUser.getLastName())
            .isPending(false)
            .groupId(binaryGroup.getId())
            .build()
    );

    friendshipRepo.save(currentUserFriendship);
    friendshipRepo.save(otherUserFriendship);
    userRepo.save(currentUser);

    notificationsService.sendNotificationToUser(userRepo.findById(otherUserId).get(),
        "تم قبول طلب الصداقة",
        currentUser.getFirstName() + " " + currentUser.getLastName());

    return ResponseEntity.ok(response);
  }

  private Group generateBinaryGroup(User currentUser, Friend friend) {
    // TODO(issue#148): Make Group.adminId a list
    Group group = Group.builder()
        .usersIds(Arrays.asList(currentUser.getId(), friend.getUserId()))
        .creatorId(friend.getUserId())
        .build();
    return group;
  }

  @PutMapping(path = "/{id}/reject")
  public ResponseEntity<ResolveFriendRequestResponse> reject(
      @PathVariable(name = "id") String otherUserId) {
    ResolveFriendRequestResponse response = new ResolveFriendRequestResponse();

    // Assert that the current user has a pending friend request from the other user.
    // Check if the current user already requested friendship with the other user.
    Friendship currentUserFriendship = friendshipRepo.findByUserId(getCurrentUser().getUserId());
    List<Friend> currentUserFriends = currentUserFriendship.getFriends();

    int friendIndex = findFriendIndexInList(otherUserId, currentUserFriends);
    if (friendIndex == -1) {
      response.setStatus(new Status(Status.NO_FRIEND_REQUEST_EXIST_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    // Check if the users are already friends.
    if (!currentUserFriends.get(friendIndex).isPending()) {
      response
          .setStatus(new Status(Status.FRIEND_REQUEST_ALREADY_ACCEPTED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    currentUserFriends.remove(friendIndex);
    friendshipRepo.save(currentUserFriendship);
    return ResponseEntity.ok(response);
  }

  @DeleteMapping(path = "/{id}")
  public ResponseEntity<DeleteFriendResponse> deleteFriend(
      @PathVariable(value = "id") String otherUserId) {
    DeleteFriendResponse response = new DeleteFriendResponse();

    // Check if the provided id is valid.
    Optional<User> otherUser = userRepo.findById(otherUserId);
    if (!otherUser.isPresent()) {
      response.setStatus(new Status(Status.USER_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (otherUser.get().getId().equals(User.SABEQ_ID)) {
      response.setStatus(new Status(Status.CANNOT_REMOVE_SABEQ__FROM_FRIENDS_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    Friendship currentUserFriendship = friendshipRepo.findByUserId(getCurrentUser().getUserId());
    Friendship otherUserFriendship = friendshipRepo.findByUserId(otherUserId);

    int currentUserAsFriendIndex = findFriendIndexInList(getCurrentUser().getUserId(),
        otherUserFriendship.getFriends());
    int otherUserAsFriendIndex =
        findFriendIndexInList(otherUserId, currentUserFriendship.getFriends());

    if (currentUserAsFriendIndex == -1 || otherUserAsFriendIndex == -1) {
      response.setStatus(new Status(Status.NO_FRIENDSHIP_ERROR));
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    currentUserFriendship.getFriends().remove(otherUserAsFriendIndex);
    otherUserFriendship.getFriends().remove(currentUserAsFriendIndex);

    // Don't remove their binary group so as we don't need to remove their previous challenges too.

    friendshipRepo.save(currentUserFriendship);
    friendshipRepo.save(otherUserFriendship);
    return ResponseEntity.ok(response);
  }

  private int findFriendIndexInList(String userId, List<Friend> friends) {
    for (int i = 0; i < friends.size(); i++) {
      if (friends.get(i).getUserId().equals(userId)) {
        return i;
      }
    }
    return -1;
  }
}
