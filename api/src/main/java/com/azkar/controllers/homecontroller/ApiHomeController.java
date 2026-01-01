package com.azkar.controllers.homecontroller;

import com.azkar.controllers.BaseController;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.payload.ResponseBase.Status;
import com.azkar.payload.challengecontroller.responses.ReturnedChallenge;
import com.azkar.payload.homecontroller.GetHomeResponse;
import com.azkar.payload.homecontroller.GetHomeResponse.Body;
import com.azkar.repos.UserRepo;
import com.azkar.services.ChallengesCleanerService;
import com.azkar.services.ChallengesService;
import com.azkar.services.FriendshipService;
import com.azkar.services.GroupsService;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/apiHome", produces = MediaType.APPLICATION_JSON_VALUE)
public class ApiHomeController extends BaseController {

  private static final Logger logger = LoggerFactory.getLogger(ApiHomeController.class);

  @Autowired
  ChallengesService challengesService;
  @Autowired
  ChallengesCleanerService challengesCleanerService;
  @Autowired
  FriendshipService friendshipService;
  @Autowired
  GroupsService groupsService;
  @Autowired
  UserRepo userRepo;

  @GetMapping()
  public ResponseEntity<GetHomeResponse> getHome(
      @RequestHeader(value = API_VERSION_HEADER, required = true) String apiVersion) {
    GetHomeResponse getHomeResponse = new GetHomeResponse();

    User currentUser = getCurrentUser(userRepo);
    CompletableFuture<List<ReturnedChallenge>> challenges =
        challengesService.getAllChallenges(apiVersion, currentUser);
    CompletableFuture<List<Friend>> friendsLeaderboard =
        friendshipService.getFriendsLeaderboard(apiVersion, currentUser);
    CompletableFuture<List<Group>> groups = groupsService.getGroups(currentUser);

    try {
      getHomeResponse.setData(Body
          .builder()
          .challenges(challenges.get())
          .friends(friendsLeaderboard.get())
          .groups(groups.get())
          .build()
      );
    } catch (InterruptedException e) {
      GetHomeResponse errorResponse = new GetHomeResponse();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    } catch (ExecutionException e) {
      GetHomeResponse errorResponse = new GetHomeResponse();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    }

    challengesCleanerService.cleanOldUserChallengesAsync(currentUser);
    return ResponseEntity.ok(getHomeResponse);
  }
}
