package com.azkar.controllers;

import com.azkar.configs.TafseerCacher;
import com.azkar.configs.TafseerCacher.WordMeaningPair;
import com.azkar.entities.Friendship;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.User.UserGroup;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.entities.challenges.CustomSimpleChallenge;
import com.azkar.entities.challenges.GlobalChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.MemorizationChallenge;
import com.azkar.entities.challenges.MemorizationChallenge.Question;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.azkar.payload.ResponseBase.Status;
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
import com.azkar.payload.challengecontroller.responses.DeleteChallengeResponse;
import com.azkar.payload.challengecontroller.responses.FinishCustomSimpleChallengeResponse;
import com.azkar.payload.challengecontroller.responses.FinishGlobalChallengeResponse;
import com.azkar.payload.challengecontroller.responses.FinishMeaningChallengeResponse;
import com.azkar.payload.challengecontroller.responses.FinishMemorizationChallengeQuestionResponse;
import com.azkar.payload.challengecontroller.responses.FinishReadingQuranChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetChallengesResponse;
import com.azkar.payload.challengecontroller.responses.GetChallengesV2Response;
import com.azkar.payload.challengecontroller.responses.GetFinishedChallengesCountResponse;
import com.azkar.payload.challengecontroller.responses.GetGlobalChallengeResponse;
import com.azkar.payload.challengecontroller.responses.GetMeaningChallengeResponse;
import com.azkar.payload.challengecontroller.responses.ReturnedChallenge;
import com.azkar.payload.challengecontroller.responses.UpdateChallengeResponse;
import com.azkar.payload.exceptions.BadRequestException;
import com.azkar.repos.AzkarChallengeRepo;
import com.azkar.repos.CustomSimpleChallengeRepo;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GlobalChallengeRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.MeaningChallengeRepo;
import com.azkar.repos.MemorizationChallengeRepo;
import com.azkar.repos.ReadingQuranChallengeRepo;
import com.azkar.repos.UserRepo;
import com.azkar.services.ChallengesService;
import com.azkar.services.NotificationsService;
import com.azkar.services.QuranService;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/challenges", produces = MediaType.APPLICATION_JSON_VALUE)
public class ChallengeController extends BaseController {

  private static final Logger logger = LoggerFactory.getLogger(ChallengeController.class);

  private static final int RANDOMLY_CHOSEN_WORDS_INDEX_DIFF = 100;

  @Autowired
  private NotificationsService notificationsService;
  @Autowired
  private UserRepo userRepo;
  @Autowired
  private AzkarChallengeRepo azkarChallengeRepo;
  @Autowired
  private GlobalChallengeRepo globalChallengeRepo;
  @Autowired
  private MeaningChallengeRepo meaningChallengeRepo;
  @Autowired
  private MemorizationChallengeRepo memorizationChallengeRepo;
  @Autowired
  private ReadingQuranChallengeRepo readingQuranChallengeRepo;
  @Autowired
  private CustomSimpleChallengeRepo customSimpleChallengeRepo;
  @Autowired
  private GroupRepo groupRepo;
  @Autowired
  private FriendshipRepo friendshipRepo;
  @Autowired
  private TafseerCacher tafseerCacher;
  @Autowired
  private ChallengesService challengesService;
  @Autowired
  private QuranService quranService;


  public static ArrayList<WordMeaningPair> getWordMeaningPairs(TafseerCacher tafseerCacher,
      int numberOfWords) {
    Random random = new Random();
    ArrayList<WordMeaningPair> wordMeaningPairs = new ArrayList<>();
    int randomIndex1 = random.nextInt(tafseerCacher.getWordMeaningPairs().size());
    wordMeaningPairs.add(tafseerCacher.getWordMeaningPairs().get(randomIndex1));

    int lastRandomIndex = randomIndex1;
    for (int i = 0; i < numberOfWords - 1; i++) {
      int randomIndex =
          (lastRandomIndex + RANDOMLY_CHOSEN_WORDS_INDEX_DIFF)
              % tafseerCacher.getWordMeaningPairs()
              .size();
      wordMeaningPairs.add(tafseerCacher.getWordMeaningPairs().get(randomIndex));

      lastRandomIndex = randomIndex;
    }
    return wordMeaningPairs;
  }

  // Note: This function may modify oldSubChallenges.
  private static Optional<ResponseEntity<UpdateChallengeResponse>> updateOldSubChallenges(
      List<SubChallenge> oldSubChallenges,
      List<SubChallenge> newSubChallenges) {
    UpdateChallengeResponse response = new UpdateChallengeResponse();
    if (newSubChallenges.size() != oldSubChallenges.size()) {
      response
          .setStatus(new Status(Status.MISSING_OR_DUPLICATED_SUB_CHALLENGE_ERROR));
      return Optional.of(ResponseEntity.badRequest().body(response));
    }

    // Set to make sure that the zekr IDs of both old and modified sub-challenges are identical.
    Set<Integer> newZekrIds = new HashSet<>();
    for (SubChallenge newSubChallenge : newSubChallenges) {
      newZekrIds.add(newSubChallenge.getZekr().getId());
      Optional<SubChallenge> subChallenge = findSubChallenge(oldSubChallenges, newSubChallenge);
      if (!subChallenge.isPresent()) {
        response.setStatus(new Status(Status.NON_EXISTENT_SUB_CHALLENGE_ERROR));
        return Optional.of(ResponseEntity.badRequest().body(response));
      }
      Optional<Status> error = updateSubChallenge(subChallenge.get(), newSubChallenge);
      if (error.isPresent()) {
        response.setStatus(error.get());
        return Optional.of(ResponseEntity.badRequest().body(response));
      }
    }
    if (newZekrIds.size() != oldSubChallenges.size()) {
      response
          .setStatus(new Status(Status.MISSING_OR_DUPLICATED_SUB_CHALLENGE_ERROR));
      return Optional.of(ResponseEntity.badRequest().body(response));
    }
    return Optional.empty();
  }

  private static Optional<SubChallenge> findSubChallenge(
      List<SubChallenge> oldSubChallenges,
      SubChallenge newSubChallenge) {
    for (SubChallenge subChallenge : oldSubChallenges) {
      if (subChallenge.getZekr().getId().equals(newSubChallenge.getZekr().getId())) {
        return Optional.of(subChallenge);
      }
    }
    return Optional.empty();
  }

  /**
   * Updates the subChallenge as requested in newSubChallenge. If an error occurred the function
   * returns an error, and returns empty object otherwise.
   */
  private static Optional<Status> updateSubChallenge(
      SubChallenge subChallenge,
      SubChallenge newSubChallenge) {
    int newLeftRepetitions = newSubChallenge.getRepetitions();
    if (newLeftRepetitions > subChallenge.getRepetitions()) {
      return Optional.of(new Status(Status.INCREMENTING_LEFT_REPETITIONS_ERROR));
    }
    if (newLeftRepetitions < 0) {
      logger.warn("Received UpdateChallenge request with negative leftRepetition value of: "
          + newLeftRepetitions);
      newLeftRepetitions = 0;
    }
    subChallenge.setRepetitions(newLeftRepetitions);
    return Optional.empty();
  }

  @GetMapping("{challengeId}")
  public ResponseEntity<GetChallengeResponse> getChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    GetChallengeResponse response = new GetChallengeResponse();
    Optional<AzkarChallenge> userChallenge = getCurrentUser(userRepo).getAzkarChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    if (!userChallenge.isPresent()) {
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    response.setData(userChallenge.get());
    return ResponseEntity.ok(response);
  }

  @GetMapping("/meaning/{challengeId}")
  public ResponseEntity<GetMeaningChallengeResponse> getMeaningChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    GetMeaningChallengeResponse response = new GetMeaningChallengeResponse();
    Optional<MeaningChallenge> userMeaningChallenge =
        getCurrentUser(userRepo).getMeaningChallenges()
            .stream()
            .filter(
                challenge -> challenge.getId()
                    .equals(
                        challengeId))
            .findFirst();
    if (!userMeaningChallenge.isPresent()) {
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    response.setData(userMeaningChallenge.get());
    return ResponseEntity.ok(response);
  }

  @GetMapping("/original/{challengeId}")
  public ResponseEntity<GetChallengeResponse> getOriginalChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    GetChallengeResponse response = new GetChallengeResponse();
    Optional<AzkarChallenge> userChallenge = getCurrentUser(userRepo).getAzkarChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    Optional<AzkarChallenge> personalChallenge = getCurrentUser(userRepo).getPersonalChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    Optional<AzkarChallenge> originalChallenge = azkarChallengeRepo.findById(challengeId);
    if ((!userChallenge.isPresent() && !personalChallenge.isPresent())
        || !originalChallenge.isPresent()) {
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    response.setData(originalChallenge.get());
    return ResponseEntity.ok(response);
  }

  @GetMapping("/global")
  public ResponseEntity<GetGlobalChallengeResponse> getGlobalChallenge() {
    GetGlobalChallengeResponse response = new GetGlobalChallengeResponse();
    List<GlobalChallenge> globalChallenges = globalChallengeRepo.findAll();

    if (globalChallenges.size() != 1) {
      logger.error("Found {} global challenges, although only one is expected",
          globalChallenges.size());
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    GlobalChallenge globalChallenge = globalChallenges.get(0);
    Optional<AzkarChallenge> azkarChallenge =
        azkarChallengeRepo.findById(globalChallenge.getAzkarChallengeIdRef());

    if (!azkarChallenge.isPresent()) {
      logger.error("Didn't find the global Azkar challenge with ID {}",
          globalChallenge.getAzkarChallengeIdRef());
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    response.setData(
        GetGlobalChallengeResponse.ReturnedGlobalChallenge.builder()
            .challenge(
                ReturnedChallenge.builder()
                    .azkarChallenge(azkarChallenge.get())
                    .build()
            )
            .finishedCount(globalChallenge.getFinishedCount())
            .build());
    return ResponseEntity.ok(response);
  }

  @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<AddAzkarChallengeResponse> addGroupChallenge(
      @RequestBody AddChallengeRequest req) {
    AddAzkarChallengeResponse response = new AddAzkarChallengeResponse();
    try {
      req.validate();
    } catch (BadRequestException e) {
      response.setStatus(e.error);
      return ResponseEntity.badRequest().body(response);
    }
    Optional<Group> group = groupRepo.findById(req.getChallenge().getGroupId());
    if (!group.isPresent()) {
      response.setStatus(new Status(Status.GROUP_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    if (!groupContainsCurrentUser(group.get())) {
      response.setStatus(new Status(Status.NOT_GROUP_MEMBER_ERROR));
      return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
    }
    User currentUser = getCurrentUser(userRepo);
    AzkarChallenge challenge = req.getChallenge().toBuilder()
        .creatingUserId(currentUser.getId())
        .build();
    azkarChallengeRepo.save(challenge);

    group.get().getChallengesIds().add(challenge.getId());
    groupRepo.save(group.get());

    List<String> groupUsersIds = group.get().getUsersIds();
    Iterable<User> affectedUsers = userRepo.findAllById(groupUsersIds);
    affectedUsers.forEach(user -> user.getAzkarChallenges().add(challenge));
    affectedUsers.forEach(affectedUser -> {
      if (!affectedUser.getId().equals(currentUser.getId())) {
        // Fire emoji 🔥
        String body = "\uD83D\uDD25";
        body += " ";
        body += currentUser.getFirstName();
        body += " ";
        body += currentUser.getLastName();
        body += " (";

        body += challenge.getName();
        body += ")";
        notificationsService.sendNotificationToUser(affectedUser, "لديك تحدٍ جديد",
            body);
      }
    });
    userRepo.saveAll(affectedUsers);

    response.setData(challenge);
    return ResponseEntity.ok(response);
  }

  // This endpoint can be used to challenge a set of friends without creating a group.
  // This endpoint is not allowed to be used with only one friend.
  @PostMapping("/friends")
  public ResponseEntity<AddAzkarChallengeResponse> addAzkarChallenge(
      @RequestBody AddAzkarChallengeRequest request) {
    AddAzkarChallengeResponse response = new AddAzkarChallengeResponse();

    try {
      request.validate();
    } catch (BadRequestException e) {
      response.setStatus(e.error);
      return ResponseEntity.badRequest().body(response);
    }

    User currentUser = getCurrentUser(userRepo);

    if (request.getFriendsIds().size() < 2) {
      response.setStatus(new Status(Status.LESS_THAN_TWO_FRIENDS_ARE_PROVIDED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    HashSet<String> friendsIds = getUserFriends(currentUser);
    boolean allValidFriends =
        request.getFriendsIds().stream().allMatch(id -> friendsIds.contains(id));
    if (!allValidFriends) {
      response.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    List<String> groupMembers = new ArrayList<>(request.getFriendsIds());
    groupMembers.add(currentUser.getId());

    Group newGroup = Group.builder()
        .id(new ObjectId().toString())
        .creatorId(currentUser.getId())
        .usersIds(groupMembers)
        .build();

    UserGroup userGroup = UserGroup.builder()
        .groupId(newGroup.getId())
        .invitingUserId(currentUser.getId())
        .monthScore(0)
        .totalScore(0)
        .build();

    AzkarChallenge challenge = request.getChallenge().toBuilder()
        .id(new ObjectId().toString())
        .creatingUserId(currentUser.getId())
        .groupId(newGroup.getId())
        .build();

    newGroup.getChallengesIds().add(challenge.getId());

    Iterable<User> affectedUsers = userRepo.findAllById(groupMembers);
    affectedUsers.forEach(user -> {
      user.getAzkarChallenges().add(challenge);
    });

    userRepo.saveAll(affectedUsers);
    groupRepo.save(newGroup);
    azkarChallengeRepo.save(challenge);

    affectedUsers.forEach(affectedUser -> {
      if (!affectedUser.getId().equals(currentUser.getId())) {
        // Fire emoji 🔥
        String body = "\uD83D\uDD25";
        body += " ";
        body += currentUser.getFirstName();
        body += " ";
        body += currentUser.getLastName();
        body += " (";

        body += challenge.getName();
        body += ")";
        notificationsService.sendNotificationToUser(affectedUser, "لديك تحدٍ جديد",
            body);
      }
    });

    response.setData(challenge);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/meaning")
  public ResponseEntity<AddMeaningChallengeResponse> addMeaningChallenge(
      @RequestBody AddMeaningChallengeRequest request) {
    AddMeaningChallengeResponse response = new AddMeaningChallengeResponse();

    try {
      request.validate();
    } catch (BadRequestException e) {
      response.setStatus(e.error);
      return ResponseEntity.badRequest().body(response);
    }

    User currentUser = getCurrentUser(userRepo);

    // TODO(issue#328): Reuse the friend group to associate new MeaningChallenges
    HashSet<String> friendsIds = getUserFriends(currentUser);
    boolean allValidFriends =
        request.getFriendsIds().stream().allMatch(id -> friendsIds.contains(id));
    if (!allValidFriends) {
      response.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    List<String> groupMembers = new ArrayList<>(request.getFriendsIds());
    groupMembers.add(currentUser.getId());

    Group newGroup = Group.builder()
        .id(new ObjectId().toString())
        .creatorId(currentUser.getId())
        .usersIds(groupMembers)
        .build();

    UserGroup userGroup = UserGroup.builder()
        .groupId(newGroup.getId())
        .invitingUserId(currentUser.getId())
        .monthScore(0)
        .totalScore(0)
        .build();

    int numberOfWords = request.getNumberOfWords() == null ? 3 : request.getNumberOfWords();
    ArrayList<WordMeaningPair> wordMeaningPairs = getWordMeaningPairs(tafseerCacher, numberOfWords);
    MeaningChallenge challenge = MeaningChallenge.builder()
        .id(new ObjectId().toString())
        .creatingUserId(currentUser.getId())
        .groupId(newGroup.getId())
        .expiryDate(request.getExpiryDate())
        .words(extractWords(wordMeaningPairs))
        .meanings(extractMeanings(wordMeaningPairs))
        .finished(false)
        .build();

    newGroup.getChallengesIds().add(challenge.getId());

    Iterable<User> affectedUsers = userRepo.findAllById(groupMembers);
    affectedUsers.forEach(user -> {
      user.getMeaningChallenges().add(challenge);
    });

    userRepo.saveAll(affectedUsers);
    groupRepo.save(newGroup);
    meaningChallengeRepo.save(challenge);

    affectedUsers.forEach(affectedUser -> {
      if (!affectedUser.getId().equals(currentUser.getId())) {
        // Fire emoji 🔥
        String body = "\uD83D\uDD25";
        body += " ";
        body += currentUser.getFirstName();
        body += " ";
        body += currentUser.getLastName();
        body += " (";

        body += "معاني كلمات القرآن";
        body += ")";
        notificationsService.sendNotificationToUser(affectedUser, "لديك تحدٍ جديد",
            body);
      }
    });

    response.setData(challenge);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/memorization")
  public ResponseEntity<AddMemorizationChallengeResponse> addMemorizationChallenge(
      @RequestBody AddMemorizationChallengeRequest request) {
    AddMemorizationChallengeResponse response = new AddMemorizationChallengeResponse();

    try {
      request.validate();
    } catch (BadRequestException e) {
      response.setStatus(e.error);
      return ResponseEntity.badRequest().body(response);
    }

    User currentUser = getCurrentUser(userRepo);

    // TODO(issue#328): Reuse the friend group to associate new Memorization challenges
    HashSet<String> friendsIds = getUserFriends(currentUser);
    boolean allValidFriends =
        request.getFriendsIds().stream().allMatch(id -> friendsIds.contains(id));
    if (!allValidFriends) {
      response.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    List<String> groupMembers = new ArrayList<>(request.getFriendsIds());
    groupMembers.add(currentUser.getId());

    Group newGroup = Group.builder()
        .id(new ObjectId().toString())
        .creatorId(currentUser.getId())
        .usersIds(groupMembers)
        .build();

    UserGroup userGroup = UserGroup.builder()
        .groupId(newGroup.getId())
        .invitingUserId(currentUser.getId())
        .monthScore(0)
        .totalScore(0)
        .build();

    MemorizationChallenge challenge = createMemorizationChallenge(request, currentUser, newGroup);

    newGroup.getChallengesIds().add(challenge.getId());

    Iterable<User> affectedUsers = userRepo.findAllById(groupMembers);
    affectedUsers.forEach(user -> {
      user.getMemorizationChallenges().add(challenge);
    });

    userRepo.saveAll(affectedUsers);
    groupRepo.save(newGroup);
    memorizationChallengeRepo.save(challenge);

    affectedUsers.forEach(affectedUser -> {
      if (!affectedUser.getId().equals(currentUser.getId())) {
        // Fire emoji 🔥
        String body = "\uD83D\uDD25";
        body += " ";
        body += currentUser.getFirstName();
        body += " ";
        body += currentUser.getLastName();
        body += " (";

        body += "اختبار حفظ قرآن";
        body += ")";
        notificationsService.sendNotificationToUser(affectedUser, "لديك تحدٍ جديد",
            body);
      }
    });

    response.setData(challenge);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/reading_quran")
  public ResponseEntity<AddReadingQuranChallengeResponse> addReadingQuranChallenge(
      @RequestBody AddReadingQuranChallengeRequest request) {
    AddReadingQuranChallengeResponse response = new AddReadingQuranChallengeResponse();

    try {
      request.validate();
    } catch (BadRequestException e) {
      response.setStatus(e.error);
      return ResponseEntity.badRequest().body(response);
    }

    User currentUser = getCurrentUser(userRepo);
    HashSet<String> friendsIds = getUserFriends(currentUser);
    boolean allValidFriends =
        request.getFriendsIds().stream().allMatch(id -> friendsIds.contains(id));
    if (!allValidFriends) {
      response.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    List<String> groupMembers = new ArrayList<>(request.getFriendsIds());
    groupMembers.add(currentUser.getId());

    Group newGroup = Group.builder()
        .id(new ObjectId().toString())
        .creatorId(currentUser.getId())
        .usersIds(groupMembers)
        .build();

    ReadingQuranChallenge challenge = request.getReadingQuranChallenge().toBuilder()
        .id(new ObjectId().toString())
        .creatingUserId(currentUser.getId())
        .groupId(newGroup.getId())
        .finished(false)
        .build();

    newGroup.getChallengesIds().add(challenge.getId());

    Iterable<User> affectedUsers = userRepo.findAllById(groupMembers);
    affectedUsers.forEach(user -> {
      user.getReadingQuranChallenges().add(challenge);
    });

    userRepo.saveAll(affectedUsers);
    groupRepo.save(newGroup);
    readingQuranChallengeRepo.save(challenge);

    affectedUsers.forEach(affectedUser -> {
      if (!affectedUser.getId().equals(currentUser.getId())) {
        // Fire emoji 🔥
        String body = "\uD83D\uDD25";
        body += " ";
        body += currentUser.getFirstName();
        body += " ";
        body += currentUser.getLastName();
        body += " (";

        body += "قراءة قرآن";
        body += ")";
        notificationsService.sendNotificationToUser(affectedUser, "لديك تحدٍ جديد",
            body);
      }
    });

    response.setData(challenge);
    return ResponseEntity.ok(response);
  }

  // Returns all challenges with all types.
  @GetMapping(path = "/v2")
  public ResponseEntity<GetChallengesV2Response> getAllChallengesV2(
      @RequestHeader(value = API_VERSION_HEADER, required = false) String apiVersion) {
    if (apiVersion != null) {
      logger.info("API version requested is " + apiVersion);
    }

    GetChallengesV2Response response = new GetChallengesV2Response();
    List<ReturnedChallenge> returnedChallenges = null;
    try {
      returnedChallenges = challengesService.getAllChallenges(apiVersion,
          getCurrentUser(userRepo)).get();
    } catch (InterruptedException e) {
      GetChallengesV2Response errorResponse = new GetChallengesV2Response();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    } catch (ExecutionException e) {
      GetChallengesV2Response errorResponse = new GetChallengesV2Response();
      errorResponse.setStatus(new Status(Status.DEFAULT_ERROR));
      logger.error("Concurrency error", e);
      return ResponseEntity.badRequest().body(errorResponse);
    }
    response.setData(returnedChallenges);
    return ResponseEntity.ok(response);
  }

  @GetMapping(path = "/groups/{groupId}/")
  public ResponseEntity<GetChallengesResponse> getAllChallengesInGroup(
      @PathVariable(value = "groupId") String groupId) {
    Optional<Group> optionalGroup = groupRepo.findById(groupId);
    ResponseEntity<GetChallengesResponse> error = validateGroupAndReturnError(optionalGroup);

    if (error != null) {
      return error;
    }

    List<AzkarChallenge> challengesInGroup =
        getCurrentUser(userRepo).getAzkarChallenges().stream()
            .filter((challenge -> challenge.getGroupId().equals(groupId)))
            .collect(
                Collectors.toList());

    Collections.reverse(challengesInGroup);
    GetChallengesResponse response = new GetChallengesResponse();
    response.setData(challengesInGroup);
    return ResponseEntity.ok(response);
  }

  // TODO(issue/204): This is not an atomic operation anymore, i.e. it is not guranteed that if
  //  something wrong happened in the middle of handling a request, the state will remain the
  //  same as before doing the request.
  @PutMapping(path = "/{challengeId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<UpdateChallengeResponse> updateAzkarChallenge(
      @PathVariable(value = "challengeId") String challengeId,
      @RequestBody UpdateChallengeRequest request) {
    User currentUser = getCurrentUser(userRepo);
    Optional<AzkarChallenge> currentUserChallenge = currentUser.getAzkarChallenges()
        .stream()
        .filter(challenge -> challenge.getId()
            .equals(
                challengeId))
        .findFirst();
    if (!currentUserChallenge.isPresent()) {
      UpdateChallengeResponse response = new UpdateChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    // TODO(issue#170): Time should be supplied by a bean to allow easier testing
    if (currentUserChallenge.get().getExpiryDate() < Instant.now().getEpochSecond()) {
      UpdateChallengeResponse response = new UpdateChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_EXPIRED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    List<SubChallenge> oldSubChallenges = currentUserChallenge.get().getSubChallenges();
    boolean oldSubChallengesFinished =
        oldSubChallenges.stream().allMatch(subChallenge -> (subChallenge.getRepetitions() == 0));
    Optional<ResponseEntity<UpdateChallengeResponse>> errorResponse = updateOldSubChallenges(
        oldSubChallenges, request.getNewChallenge().getSubChallenges());
    if (errorResponse.isPresent()) {
      return errorResponse.get();
    }
    boolean newSubChallengesFinished =
        oldSubChallenges.stream().allMatch(subChallenge -> (subChallenge.getRepetitions() == 0));
    if (newSubChallengesFinished && !oldSubChallengesFinished) {
      updateScoreInFriendships(currentUser, currentUserChallenge.get().getGroupId());
      userRepo.save(currentUser);

      AzkarChallenge challenge = azkarChallengeRepo.findById(challengeId).get();
      updateAzkarChallengeOnUserFinished(challenge, currentUser);
      // Invalidate current user because it may have changed indirectly (by changing only the
      // database instance) after calling updateChallengeOnUserFinished.
      currentUser = userRepo.findById(currentUser.getId()).get();
      currentUser
          .setFinishedAzkarChallengesCount(currentUser.getFinishedAzkarChallengesCount() + 1);

      challengesService
          .sendNotificationOnFinishedAzkarChallenge(getCurrentUser(userRepo), challenge);
      azkarChallengeRepo.save(challenge);
    }
    userRepo.save(currentUser);

    return ResponseEntity.ok(new UpdateChallengeResponse());
  }

  @PutMapping(path = "/finish/meaning/{challengeId}")
  public ResponseEntity<FinishMeaningChallengeResponse> finishMeaningChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    User currentUser = getCurrentUser(userRepo);
    Optional<MeaningChallenge> currentUserChallenge = currentUser.getMeaningChallenges()
        .stream()
        .filter(challenge -> challenge.getId()
            .equals(
                challengeId))
        .findFirst();
    if (!currentUserChallenge.isPresent()) {
      FinishMeaningChallengeResponse response = new FinishMeaningChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    // TODO(issue#170): Time should be supplied by a bean to allow easier testing
    if (currentUserChallenge.get().getExpiryDate() < Instant.now().getEpochSecond()) {
      FinishMeaningChallengeResponse response = new FinishMeaningChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_EXPIRED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (currentUserChallenge.get().isFinished()) {
      FinishMeaningChallengeResponse response = new FinishMeaningChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_HAS_ALREADY_BEEN_FINISHED));
      return ResponseEntity.badRequest().body(response);
    }

    currentUserChallenge.get().setFinished(true);
    updateScoreInFriendships(currentUser, currentUserChallenge.get().getGroupId());
    userRepo.save(currentUser);

    MeaningChallenge challenge = meaningChallengeRepo.findById(challengeId).get();
    updateMeaningChallengeOnUserFinished(challenge, currentUser);
    // Invalidate current user because it may have changed indirectly (by changing only the
    // database instance) after calling updateChallengeOnUserFinished.
    currentUser = userRepo.findById(currentUser.getId()).get();
    currentUser
        .setFinishedMeaningChallengesCount(currentUser.getFinishedMeaningChallengesCount() + 1);

    challengesService
        .sendNotificationOnFinishedMeaningChallenge(getCurrentUser(userRepo), challenge);
    meaningChallengeRepo.save(challenge);
    userRepo.save(currentUser);

    return ResponseEntity.ok(new FinishMeaningChallengeResponse());
  }

  @PutMapping(path = "/finish/reading_quran/{challengeId}")
  public ResponseEntity<FinishReadingQuranChallengeResponse> finishReadingQuranChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    User currentUser = getCurrentUser(userRepo);
    Optional<ReadingQuranChallenge> currentUserChallenge = currentUser.getReadingQuranChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    if (!currentUserChallenge.isPresent()) {
      FinishReadingQuranChallengeResponse response = new FinishReadingQuranChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    // TODO(issue#170): Time should be supplied by a bean to allow easier testing
    if (currentUserChallenge.get().getExpiryDate() < Instant.now().getEpochSecond()) {
      FinishReadingQuranChallengeResponse response = new FinishReadingQuranChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_EXPIRED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (currentUserChallenge.get().isFinished()) {
      FinishReadingQuranChallengeResponse response = new FinishReadingQuranChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_HAS_ALREADY_BEEN_FINISHED));
      return ResponseEntity.badRequest().body(response);
    }

    currentUserChallenge.get().setFinished(true);
    updateScoreInFriendships(currentUser, currentUserChallenge.get().getGroupId());
    userRepo.save(currentUser);

    ReadingQuranChallenge challenge = readingQuranChallengeRepo.findById(challengeId).get();
    updateReadingQuranChallengeOnUserFinished(challenge, currentUser);
    // Invalidate current user because it may have changed indirectly (by changing only the
    // database instance) after calling updateChallengeOnUserFinished.
    currentUser = userRepo.findById(currentUser.getId()).get();
    currentUser.setFinishedReadingQuranChallengesCount(
        currentUser.getFinishedReadingQuranChallengesCount() + 1);

    challengesService.sendNotificationOnFinishedReadingQuranChallenge(getCurrentUser(userRepo),
        challenge);
    readingQuranChallengeRepo.save(challenge);
    userRepo.save(currentUser);

    return ResponseEntity.ok(new FinishReadingQuranChallengeResponse());
  }

  // question is 0-based.
  @PutMapping(path = "/finish/memorization/{challengeId}/{question}")
  public ResponseEntity<FinishMemorizationChallengeQuestionResponse> finishMemorizationQuestion(
      @PathVariable(value = "challengeId") String challengeId,
      @PathVariable(value = "question") String question) {
    User currentUser = getCurrentUser(userRepo);
    Optional<MemorizationChallenge> currentUserChallenge = currentUser.getMemorizationChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    if (!currentUserChallenge.isPresent()) {
      FinishMemorizationChallengeQuestionResponse response =
          new FinishMemorizationChallengeQuestionResponse();
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    // TODO(issue#170): Time should be supplied by a bean to allow easier testing
    if (currentUserChallenge.get().getExpiryDate() < Instant.now().getEpochSecond()) {
      FinishMemorizationChallengeQuestionResponse response =
          new FinishMemorizationChallengeQuestionResponse();
      response.setStatus(new Status(Status.CHALLENGE_EXPIRED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    int questionNumber;
    try {
      questionNumber = Integer.parseInt(question);
    } catch (NumberFormatException e) {
      logger.error("Couldn't parse question number {} to integer", question);
      FinishMemorizationChallengeQuestionResponse response =
          new FinishMemorizationChallengeQuestionResponse();
      response
          .setStatus(new Status(Status.MEMORIZATION_CHALLENGE_NUMBER_OF_QUESTIONS_INVALID_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (questionNumber >= currentUserChallenge.get().getQuestions().size() || questionNumber < 0) {
      logger.error("Question number: {} is invalid, because the total number of questions are {}",
          question, currentUserChallenge.get().getQuestions().size());
      FinishMemorizationChallengeQuestionResponse response =
          new FinishMemorizationChallengeQuestionResponse();
      response
          .setStatus(new Status(Status.MEMORIZATION_CHALLENGE_NUMBER_OF_QUESTIONS_INVALID_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (currentUserChallenge.get().getQuestions().get(questionNumber).isFinished()) {
      FinishMemorizationChallengeQuestionResponse response =
          new FinishMemorizationChallengeQuestionResponse();
      response.setStatus(new Status(Status.MEMORIZATION_QUESTION_HAS_ALREADY_BEEN_FINISHED));
      return ResponseEntity.badRequest().body(response);
    }

    currentUserChallenge.get().getQuestions().get(questionNumber).setFinished(true);
    if (!currentUserChallenge.get().finished()) {
      userRepo.save(currentUser);
      return ResponseEntity.ok(new FinishMemorizationChallengeQuestionResponse());
    }

    updateScoreInFriendships(currentUser, currentUserChallenge.get().getGroupId());
    userRepo.save(currentUser);

    MemorizationChallenge challenge = memorizationChallengeRepo.findById(challengeId).get();
    updateMemorizationChallengeOnUserFinished(challenge, currentUser);
    // Invalidate current user because it may have changed indirectly (by changing only the
    // database instance) after calling updateChallengeOnUserFinished.
    currentUser = userRepo.findById(currentUser.getId()).get();
    currentUser.setFinishedMemorizationChallengesCount(
        currentUser.getFinishedMemorizationChallengesCount() + 1);

    challengesService.sendNotificationOnFinishedMemorizationChallenge(getCurrentUser(userRepo),
        challenge);
    memorizationChallengeRepo.save(challenge);
    userRepo.save(currentUser);

    return ResponseEntity.ok(new FinishMemorizationChallengeQuestionResponse());
  }

  @PutMapping("/finish/global")
  public ResponseEntity<FinishGlobalChallengeResponse> finishGlobalChallenge() {
    FinishGlobalChallengeResponse response = new FinishGlobalChallengeResponse();
    List<GlobalChallenge> globalChallenges = globalChallengeRepo.findAll();

    if (globalChallenges.size() != 1) {
      logger.error("Found {} global challenges, although only one is expected",
          globalChallenges.size());
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    globalChallengeRepo.findAndIncrementFinishedCountById(globalChallenges.get(0).getId());

    User currentUser = getCurrentUser(userRepo);
    currentUser
        .setFinishedAzkarChallengesCount(currentUser.getFinishedAzkarChallengesCount() + 1);
    userRepo.save(currentUser);

    return ResponseEntity.ok(response);
  }

  /*
  Can be used for all types of challenges.
   */
  @DeleteMapping("{challengeId}")
  public ResponseEntity<DeleteChallengeResponse> deleteChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    DeleteChallengeResponse response = new DeleteChallengeResponse();
    User user = getCurrentUser(userRepo);

    Optional<AzkarChallenge> azkarChallenge = user.getAzkarChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();

    Optional<MeaningChallenge> meaningChallenge = user.getMeaningChallenges()
        .stream(

        )
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();

    Optional<ReadingQuranChallenge> readingQuranChallenge = user.getReadingQuranChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();

    Optional<MemorizationChallenge> memorizationChallenge = user.getMemorizationChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();

    Optional<CustomSimpleChallenge> customSimpleChallenge = user.getCustomSimpleChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    if (!azkarChallenge.isPresent() && !meaningChallenge.isPresent() && !readingQuranChallenge
        .isPresent()
        && !memorizationChallenge.isPresent()
        && !customSimpleChallenge.isPresent()) {
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    if (azkarChallenge.isPresent()) {
      user.getAzkarChallenges().removeIf(challenge -> challenge.getId().equals(challengeId));
      response.setData(azkarChallenge.get());
    } else if (meaningChallenge.isPresent()) {
      user.getMeaningChallenges().removeIf(challenge -> challenge.getId().equals(challengeId));
      response.setData(meaningChallenge.get());
    } else if (readingQuranChallenge.isPresent()) {
      user.getReadingQuranChallenges().removeIf(challenge -> challenge.getId().equals(challengeId));
      response.setData(readingQuranChallenge.get());
    } else if (memorizationChallenge.isPresent()) {
      user.getMemorizationChallenges().removeIf(challenge -> challenge.getId().equals(challengeId));
      response.setData(memorizationChallenge.get());
    } else {
      user.getCustomSimpleChallenges().removeIf(challenge -> challenge.getId().equals(challengeId));
    }
    userRepo.save(user);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/simple")
  public ResponseEntity<AddCustomSimpleChallengeResponse> addCustomSimpleChallenge(
      @RequestBody AddCustomSimpleChallengeRequest request) {
    AddCustomSimpleChallengeResponse response = new AddCustomSimpleChallengeResponse();

    try {
      request.validate();
    } catch (BadRequestException e) {
      response.setStatus(e.error);
      return ResponseEntity.badRequest().body(response);
    }

    User currentUser = getCurrentUser(userRepo);
    HashSet<String> friendsIds = getUserFriends(currentUser);
    boolean allValidFriends =
        request.getFriendsIds().stream().allMatch(id -> friendsIds.contains(id));
    if (!allValidFriends) {
      response.setStatus(new Status(Status.ONE_OR_MORE_USERS_NOT_FRIENDS_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    List<String> groupMembers = new ArrayList<>(request.getFriendsIds());
    groupMembers.add(currentUser.getId());

    Group newGroup = Group.builder()
        .id(new ObjectId().toString())
        .creatorId(currentUser.getId())
        .usersIds(groupMembers)
        .build();

    CustomSimpleChallenge challenge = CustomSimpleChallenge.builder()
        .id(new ObjectId().toString())
        .creatingUserId(currentUser.getId())
        .groupId(newGroup.getId())
        .finished(false)
        .expiryDate(request.getExpiryDate())
        .description(request.getDescription())
        .build();

    newGroup.getChallengesIds().add(challenge.getId());

    Iterable<User> affectedUsers = userRepo.findAllById(groupMembers);
    affectedUsers.forEach(user -> {
      user.getCustomSimpleChallenges().add(challenge);
    });

    userRepo.saveAll(affectedUsers);
    groupRepo.save(newGroup);
    customSimpleChallengeRepo.save(challenge);

    affectedUsers.forEach(affectedUser -> {
      if (!affectedUser.getId().equals(currentUser.getId())) {
        // Fire emoji 🔥
        String body = "\uD83D\uDD25";
        body += " ";
        body += currentUser.getFirstName();
        body += " ";
        body += currentUser.getLastName();
        body += " (";

        body += challenge.getDescription();
        body += ")";
        notificationsService.sendNotificationToUser(affectedUser, "لديك تحدٍ جديد",
            body);
      }
    });

    response.setData(challenge);
    return ResponseEntity.ok(response);
  }

  @PutMapping(path = "/finish/simple/{challengeId}")
  public ResponseEntity<FinishCustomSimpleChallengeResponse> finishCustomSimpleChallenge(
      @PathVariable(value = "challengeId") String challengeId) {
    User currentUser = getCurrentUser(userRepo);
    Optional<CustomSimpleChallenge> currentUserChallenge = currentUser.getCustomSimpleChallenges()
        .stream()
        .filter(
            challenge -> challenge.getId()
                .equals(
                    challengeId))
        .findFirst();
    if (!currentUserChallenge.isPresent()) {
      FinishCustomSimpleChallengeResponse response = new FinishCustomSimpleChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    // TODO(issue#170): Time should be supplied by a bean to allow easier testing
    if (currentUserChallenge.get().getExpiryDate() < Instant.now().getEpochSecond()) {
      FinishCustomSimpleChallengeResponse response = new FinishCustomSimpleChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_EXPIRED_ERROR));
      return ResponseEntity.badRequest().body(response);
    }

    if (currentUserChallenge.get().isFinished()) {
      FinishCustomSimpleChallengeResponse response = new FinishCustomSimpleChallengeResponse();
      response.setStatus(new Status(Status.CHALLENGE_HAS_ALREADY_BEEN_FINISHED));
      return ResponseEntity.badRequest().body(response);
    }

    currentUserChallenge.get().setFinished(true);
    updateScoreInFriendships(currentUser, currentUserChallenge.get().getGroupId());
    userRepo.save(currentUser);

    CustomSimpleChallenge challenge = customSimpleChallengeRepo.findById(challengeId).get();
    updateCustomSimpleChallengeOnUserFinished(challenge, currentUser);
    // Invalidate current user because it may have changed indirectly (by changing only the
    // database instance) after calling updateChallengeOnUserFinished.
    currentUser = userRepo.findById(currentUser.getId()).get();
    currentUser.setFinishedCustomSimpleChallengesCount(
        currentUser.getFinishedCustomSimpleChallengesCount() + 1);

    challengesService.sendNotificationOnFinishedCustomSimpleChallenge(getCurrentUser(userRepo),
        challenge);
    customSimpleChallengeRepo.save(challenge);
    userRepo.save(currentUser);

    return ResponseEntity.ok(new FinishCustomSimpleChallengeResponse());
  }

  @GetMapping("/finished-challenges-count")
  public ResponseEntity<GetFinishedChallengesCountResponse> getFinishedChallengesCount() {
    GetFinishedChallengesCountResponse response = new GetFinishedChallengesCountResponse();

    User user = getCurrentUser(userRepo);
    int finishedChallengesCount =
        user.getFinishedAzkarChallengesCount()
            + user.getFinishedMeaningChallengesCount()
            + user.getFinishedReadingQuranChallengesCount()
            + user.getFinishedMemorizationChallengesCount()
            + user.getFinishedCustomSimpleChallengesCount()
            + user.getFinishedPersonalChallengesCount();

    response.setData(finishedChallengesCount);
    return ResponseEntity.ok(response);
  }

  private ResponseEntity<GetChallengesResponse> validateGroupAndReturnError(
      Optional<Group> optionalGroup) {
    GetChallengesResponse response = new GetChallengesResponse();
    if (!optionalGroup.isPresent()) {
      response.setStatus(new Status(Status.GROUP_NOT_FOUND_ERROR));
      return ResponseEntity.badRequest().body(response);
    }
    if (!groupContainsCurrentUser(optionalGroup.get())) {
      response.setStatus(new Status(Status.NON_GROUP_MEMBER_ERROR));
      return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
    }
    return null;
  }

  private List<String> extractWords(ArrayList<WordMeaningPair> wordMeaningPairs) {
    return wordMeaningPairs.stream()
        .map(wordMeaningPair -> wordMeaningPair.getWord())
        .collect(Collectors.toList());
  }

  private List<String> extractMeanings(ArrayList<WordMeaningPair> wordMeaningPairs) {
    return wordMeaningPairs.stream()
        .map(wordMeaningPair -> wordMeaningPair.getMeaning())
        .collect(Collectors.toList());
  }


  private void updateAzkarChallengeOnUserFinished(AzkarChallenge challenge, User currentUser) {
    // Update the original copy of the challenge
    challenge.getUsersFinished().add(currentUser.getId());

    // Update users copies of the challenge
    groupRepo.findById(challenge.getGroupId()).get().getUsersIds().forEach(groupMember -> {
      User user = userRepo.findById(groupMember).get();
      user.getAzkarChallenges().forEach(userChallenge -> {
        if (userChallenge.getId().equals(challenge.getId())) {
          userChallenge.getUsersFinished().add(currentUser.getId());
        }
      });
      userRepo.save(user);
    });
  }

  private void updateMeaningChallengeOnUserFinished(MeaningChallenge challenge, User currentUser) {
    // Update the original copy of the challenge
    challenge.getUsersFinished().add(currentUser.getId());

    // Update users copies of the challenge
    groupRepo.findById(challenge.getGroupId()).get().getUsersIds().forEach(groupMember -> {
      User user = userRepo.findById(groupMember).get();
      user.getMeaningChallenges().forEach(userChallenge -> {
        if (userChallenge.getId().equals(challenge.getId())) {
          userChallenge.getUsersFinished().add(currentUser.getId());
        }
      });
      userRepo.save(user);
    });
  }

  private void updateReadingQuranChallengeOnUserFinished(ReadingQuranChallenge challenge,
      User currentUser) {
    // Update the original copy of the challenge
    challenge.getUsersFinished().add(currentUser.getId());

    // Update users copies of the challenge
    groupRepo.findById(challenge.getGroupId()).get().getUsersIds().forEach(groupMember -> {
      User user = userRepo.findById(groupMember).get();
      user.getReadingQuranChallenges().forEach(userChallenge -> {
        if (userChallenge.getId().equals(challenge.getId())) {
          userChallenge.getUsersFinished().add(currentUser.getId());
        }
      });
      userRepo.save(user);
    });
  }

  private HashSet<String> getUserFriends(User user) {
    Friendship friendship = friendshipRepo.findByUserId(user.getId());
    HashSet<String> friends = new HashSet<>();
    friendship.getFriends().forEach(friend -> friends.add(friend.getUserId()));
    return friends;
  }

  private void updateMemorizationChallengeOnUserFinished(MemorizationChallenge challenge,
      User currentUser) {
    // Update the original copy of the challenge
    challenge.getUsersFinished().add(currentUser.getId());

    // Update users copies of the challenge
    groupRepo.findById(challenge.getGroupId()).get().getUsersIds().forEach(groupMember -> {
      User user = userRepo.findById(groupMember).get();
      user.getMemorizationChallenges().forEach(userChallenge -> {
        if (userChallenge.getId().equals(challenge.getId())) {
          userChallenge.getUsersFinished().add(currentUser.getId());
        }
      });
      userRepo.save(user);
    });
  }

  private boolean groupContainsCurrentUser(Group group) {
    return group.getUsersIds().contains(getCurrentUser().getUserId());
  }

  private List<AzkarChallenge> filterOutSabeqChallenges(List<AzkarChallenge> challenges) {
    List<AzkarChallenge> filtered = challenges.stream().filter(challenge -> {
      Optional<Group> group = groupRepo.findById(challenge.getGroupId());
      if (!group.isPresent()) {
        return false;
      }
      return !group.get().getUsersIds().contains(User.SABEQ_ID);
    }).collect(Collectors.toList());
    return filtered;
  }

  private void updateCustomSimpleChallengeOnUserFinished(CustomSimpleChallenge challenge,
      User currentUser) {
    // Update the original copy of the challenge
    challenge.getUsersFinished().add(currentUser.getId());

    // Update users copies of the challenge
    groupRepo.findById(challenge.getGroupId()).get().getUsersIds().forEach(groupMember -> {
      User user = userRepo.findById(groupMember).get();
      user.getCustomSimpleChallenges().forEach(userChallenge -> {
        if (userChallenge.getId().equals(challenge.getId())) {
          userChallenge.getUsersFinished().add(currentUser.getId());
        }
      });
      userRepo.save(user);
    });
  }

  private MemorizationChallenge createMemorizationChallenge(AddMemorizationChallengeRequest request,
      User user, Group group) {
    MemorizationChallenge memorizationChallenge =
        MemorizationChallenge.builder()
            .id(new ObjectId().toString())
            .creatingUserId(user.getId())
            .groupId(group.getId())
            .expiryDate(request.getExpiryDate())
            .questions(new ArrayList<>())
            .difficulty(request.getDifficulty())
            .firstJuz(request.getFirstJuz())
            .lastJuz(request.getLastJuz())
            .firstSurah(request.getFirstSurah())
            .lastSurah(request.getLastSurah())
            .build();

    for (int i = 0; i < request.getNumberOfQuestions(); i++) {
      int juz;
      int ayah;
      if (request.getFirstJuz() == 0) {
        // Surah range specified
        ayah = quranService.getRandomAyahInSurahRange(request.getFirstSurah(),
            request.getLastSurah());
        juz = quranService.getJuzOfAya(ayah);
      } else {
        juz =
            quranService.getRandomJuzInRange(request.getFirstJuz(), request.getLastJuz());
        ayah = quranService.getRandomAyahInJuz(juz);
      }
      int surah = quranService.getSurahOfAyah(ayah);
      int firstAyahInJuz = quranService.getFirstAyahInJuz(juz);
      int rub = quranService.getRubOfAya(ayah);
      int firstAyahInRub = quranService.getFirstAyahInRub(rub);
      List<Integer> wrongPreviousAyahOptions = quranService.getRandomTwoWrongPreviousAyahs(ayah);
      List<Integer> wrongNextAyahOptions = quranService.getRandomTwoWrongNextAyahs(ayah);
      List<Integer> wrongFirstAyahsInRubOptions =
          quranService.getRandomTwoWrongFirstAyahsInRub(rub);
      List<Integer> wrongFirstAyahsInJuzOptions =
          quranService.getRandomTwoWrongFirstAyahsInJuz(juz);
      List<Integer> wrongSurahsOptions = quranService.getRandomTwoWrongSurahsOfAyah(ayah);

      Question question = Question.builder().build();
      question.setNumber(i);
      question.setJuz(juz);
      question.setAyah(ayah);
      question.setSurah(surah);
      question.setFirstAyahInJuz(firstAyahInJuz);
      question.setFirstAyahInRub(firstAyahInRub);
      question.setWrongPreviousAyahOptions(wrongPreviousAyahOptions);
      question.setWrongNextAyahOptions(wrongNextAyahOptions);
      question.setWrongFirstAyahInRubOptions(wrongFirstAyahsInRubOptions);
      question.setWrongFirstAyahInJuzOptions(wrongFirstAyahsInJuzOptions);
      question.setWrongSurahOptions(wrongSurahsOptions);
      question.setFinished(false);

      memorizationChallenge.getQuestions().add(question);
    }
    return memorizationChallenge;
  }

  private void updateScoreInFriendships(User user, String groupId) {
    Group group = groupRepo.findById(groupId).orElse(null);
    if (group == null) {
      logger.warn("Group with ID: %s not found will trying to update score for user: %s", groupId,
          user.getId());
      return;
    }

    Friendship friendship = friendshipRepo.findByUserId(user.getId());

    Set<String> friendsAndGroupMembers =
        friendship.getFriends().stream()
            .filter(friend -> group.getUsersIds().contains(friend.getUserId()))
            .map(friend -> friend.getUserId()).collect(
                Collectors.toSet());

    // Update user friendship
    friendship.getFriends().stream()
        .filter(friend -> friendsAndGroupMembers.contains(friend.getUserId()))
        .forEach(friend -> {
          friend.setUserTotalScore(friend.getUserTotalScore() + 1);
        });
    friendshipRepo.save(friendship);

    // Update friends' friendships
    friendsAndGroupMembers.stream().forEach(friendUserId -> {
      Friendship friendFriendship = friendshipRepo.findByUserId(friendUserId);

      friendFriendship.getFriends().stream()
          .filter(friend -> friend.getUserId().equals(user.getId()))
          .forEach(friend -> friend.setFriendTotalScore(friend.getFriendTotalScore() + 1));
      friendshipRepo.save(friendFriendship);
    });
  }
}
