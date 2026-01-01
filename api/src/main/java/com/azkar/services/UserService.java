package com.azkar.services;

import com.azkar.configs.TafseerCacher;
import com.azkar.configs.TafseerCacher.WordMeaningPair;
import com.azkar.controllers.ChallengeController;
import com.azkar.entities.Friendship;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.entities.User.UserGroup;
import com.azkar.entities.Zekr;
import com.azkar.entities.challenges.AzkarChallenge;
import com.azkar.entities.challenges.AzkarChallenge.SubChallenge;
import com.azkar.entities.challenges.MeaningChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge;
import com.azkar.entities.challenges.ReadingQuranChallenge.SurahSubChallenge;
import com.azkar.repos.AzkarChallengeRepo;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.MeaningChallengeRepo;
import com.azkar.repos.ReadingQuranChallengeRepo;
import com.azkar.repos.UserRepo;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Optional;
import java.util.Random;
import java.util.stream.Collectors;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

  private static final String ENGLISH_CHARS_STRING_REGEX = "^[a-zA-Z]*$";
  @Autowired
  private UserRepo userRepo;
  @Autowired
  private FriendshipRepo friendshipRepo;
  @Autowired
  private GroupRepo groupRepo;
  @Autowired
  private AzkarChallengeRepo azkarChallengeRepo;
  @Autowired
  private MeaningChallengeRepo meaningChallengeRepo;
  @Autowired
  private ReadingQuranChallengeRepo readingQuranChallengeRepo;
  @Autowired
  private TafseerCacher tafseerCacher;

  public User loadUserById(String id) {
    Optional<User> user = userRepo.findById(id);
    if (user.isPresent()) {
      return user.get();
    }
    return null;
  }


  public User buildNewUser(String email, String firstName, String lastName) {
    return buildNewUser(email, firstName, lastName, /*encodedPassword=*/null);
  }

  public User buildNewUser(String email, String firstName, String lastName,
      String encodedPassword) {
    return User.builder()
        .email(email)
        .username(generateUsername(firstName, lastName))
        .firstName(firstName)
        .lastName(lastName)
        .encodedPassword(encodedPassword)
        .build();
  }

  /*
    Adds a new user to the database as well as adding all of the dependencies that should be created
    with a new user.
  */
  public User addNewUser(User user) {
    userRepo.save(user);
    Group userAndSabeqGroup = addSabeqAsFriend(user);
    addStartingChallengesWithSabeq(user, userAndSabeqGroup);
    return user;
  }

  private Group addSabeqAsFriend(User user) {
    Friendship friendship = Friendship.builder().userId(user.getId()).build();
    User sabeq = userRepo.findById(User.SABEQ_ID).get();

    // Create Group
    Group binaryGroup = Group.builder()
        .usersIds(Arrays.asList(user.getId(), sabeq.getId()))
        .creatorId(sabeq.getId())
        .build();
    groupRepo.save(binaryGroup);

    // Add sabeq to user friends
    Friend sabeqAsFriend = Friend.builder()
        .userId(sabeq.getId())
        .username(sabeq.getUsername())
        .firstName(sabeq.getFirstName())
        .lastName(sabeq.getLastName())
        .isPending(false)
        .groupId(binaryGroup.getId())
        .build();
    friendship.getFriends().add(sabeqAsFriend);
    friendshipRepo.save(friendship);

    // Add user to sabeq friends
    Friend userAsSabeqFriend = Friend.builder()
        .userId(user.getId())
        .username(user.getUsername())
        .firstName(user.getFirstName())
        .lastName(user.getLastName())
        .isPending(false)
        .groupId(binaryGroup.getId())
        .build();
    Friendship sabeqFriendship = friendshipRepo.findByUserId(User.SABEQ_ID);
    sabeqFriendship.getFriends().add(userAsSabeqFriend);
    friendshipRepo.save(friendship);

    // Add user group
    UserGroup userGroup = UserGroup.builder()
        .totalScore(0)
        .monthScore(0)
        .invitingUserId(sabeq.getId())
        .groupId(binaryGroup.getId())
        .groupName("")
        .build();
    userRepo.save(user);

    return binaryGroup;
  }

  private void addStartingChallengesWithSabeq(User user, Group userAndSabeqGroup) {
    addReadingQuranChallengeWithSabeq(user, userAndSabeqGroup);
    addMeaningChallengeWithSabeq(user, userAndSabeqGroup);
    addAzkarChallengeWithSabeq(user, userAndSabeqGroup);
  }

  private void addAzkarChallengeWithSabeq(User user, Group userAndSabeqGroup) {
    ArrayList<SubChallenge> subChallenges = new ArrayList<>();
    subChallenges
        .add(SubChallenge.builder().zekr(Zekr.builder().zekr("سبحان الله وبحمده").id(17).build())
            .repetitions(3).build());
    subChallenges.add(
        SubChallenge.builder().zekr(Zekr.builder().zekr("أستغفر الله").id(18).build())
            .repetitions(10).build());
    AzkarChallenge challenge = AzkarChallenge.builder()
        .id(new ObjectId().toString())
        .creatingUserId(user.getId())
        .groupId(userAndSabeqGroup.getId())
        .name("تحدي أذكار تجريبي")
        .subChallenges(subChallenges)
        .motivation("")
        .expiryDate(Instant.now().getEpochSecond() + /*hours=*/12 * 60 * 60)
        .build();

    userAndSabeqGroup.getChallengesIds().add(challenge.getId());

    User sabeq = userRepo.findById(User.SABEQ_ID).get();
    user.getAzkarChallenges().add(challenge);
    sabeq.getAzkarChallenges().add(challenge);

    userRepo.save(user);
    userRepo.save(sabeq);
    azkarChallengeRepo.save(challenge);
  }

  private void addMeaningChallengeWithSabeq(User user, Group userAndSabeqGroup) {
    ArrayList<WordMeaningPair> wordMeaningPairs =
        ChallengeController.getWordMeaningPairs(tafseerCacher, 3);
    MeaningChallenge challenge = MeaningChallenge.builder()
        .id(new ObjectId().toString())
        .creatingUserId(user.getId())
        .groupId(userAndSabeqGroup.getId())
        .meanings(wordMeaningPairs.stream().map(p -> p.getMeaning()).collect(Collectors.toList()))
        .words(wordMeaningPairs.stream().map(p -> p.getWord()).collect(Collectors.toList()))
        .finished(false)
        .expiryDate(Instant.now().getEpochSecond() + /*hours=*/12 * 60 * 60)
        .build();

    userAndSabeqGroup.getChallengesIds().add(challenge.getId());

    User sabeq = userRepo.findById(User.SABEQ_ID).get();
    user.getMeaningChallenges().add(challenge);
    sabeq.getMeaningChallenges().add(challenge);

    userRepo.save(user);
    userRepo.save(sabeq);
    meaningChallengeRepo.save(challenge);
  }

  private void addReadingQuranChallengeWithSabeq(User user,
      Group userAndSabeqGroup) {
    ArrayList<SurahSubChallenge> surahSubChallenges = new ArrayList<>();
    surahSubChallenges
        .add(SurahSubChallenge.builder().surahName("البَقَرَةِ").startingVerseNumber(284)
            .endingVerseNumber(286).build());
    surahSubChallenges.add(SurahSubChallenge.builder().surahName("يسٓ").startingVerseNumber(1)
        .endingVerseNumber(83).build());
    ReadingQuranChallenge challenge = ReadingQuranChallenge.builder()
        .id(new ObjectId().toString())
        .creatingUserId(user.getId())
        .groupId(userAndSabeqGroup.getId())
        .surahSubChallenges(surahSubChallenges)
        .finished(false)
        .expiryDate(Instant.now().getEpochSecond() + /*hours=*/12 * 60 * 60)
        .build();

    userAndSabeqGroup.getChallengesIds().add(challenge.getId());

    User sabeq = userRepo.findById(User.SABEQ_ID).get();
    user.getReadingQuranChallenges().add(challenge);
    sabeq.getReadingQuranChallenges().add(challenge);

    userRepo.save(user);
    userRepo.save(sabeq);
    readingQuranChallengeRepo.save(challenge);
  }

  // Note: Only this generator should be able to create usernames with the special character '-',
  // but users shouldn't be able to use this character while changing their usernames.
  private String generateUsername(String firstName, String lastName) {
    lastName = lastName == null ? "" : lastName;
    firstName = firstName.replace(" ", "");
    lastName = lastName.replace(" ", "");
    firstName = firstName.toLowerCase();
    lastName = lastName.toLowerCase();

    while (true) {
      boolean nameCanBePrefix = firstName.matches(ENGLISH_CHARS_STRING_REGEX) && lastName
          .matches(ENGLISH_CHARS_STRING_REGEX);
      String usernamePrefix = "";
      String randomUsernameSuffix;
      if (nameCanBePrefix) {
        usernamePrefix = firstName + "-" + lastName + "-";
        randomUsernameSuffix = generateRandomString(5);
      } else {
        randomUsernameSuffix = generateRandomString(8);
      }
      if (!userRepo.findByUsername(usernamePrefix + randomUsernameSuffix).isPresent()) {
        return usernamePrefix + randomUsernameSuffix;
      }
    }
  }

  private String generateRandomString(int length) {
    int minLimit = ('a');
    int maxLimit = ('z');
    Random random = new Random();

    return random.ints(minLimit, maxLimit + 1)
        .limit(length)
        .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
        .toString();
  }
}
