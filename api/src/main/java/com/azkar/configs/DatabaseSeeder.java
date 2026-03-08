package com.azkar.configs;

import com.azkar.entities.Friendship;
import com.azkar.entities.Friendship.Friend;
import com.azkar.entities.Group;
import com.azkar.entities.User;
import com.azkar.repos.FriendshipRepo;
import com.azkar.repos.GroupRepo;
import com.azkar.repos.UserRepo;
import com.azkar.services.UserService;
import java.util.ArrayList;
import java.util.Arrays;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Seeds the database with initial data for development environments.
 * This component only runs when the 'dev' profile is active.
 */
@Component
@Profile("dev")  // Only runs in development
public class DatabaseSeeder implements ApplicationRunner {

  private static final Logger logger = LoggerFactory.getLogger(DatabaseSeeder.class);

  @Autowired
  private UserRepo userRepo;

  @Autowired
  private FriendshipRepo friendshipRepo;

  @Autowired
  private GroupRepo groupRepo;

  @Autowired
  private PasswordEncoder passwordEncoder;

  @Autowired
  private UserService userService;

  @Override
  public void run(ApplicationArguments args) {
    logger.info("Running database seeder for development environment...");
    seedSabeqUser();
    seedTestUsers();
    logger.info("Database seeding completed.");
  }

  private void seedSabeqUser() {
    // Check if sabeq user already exists
    if (userRepo.findById(User.SABEQ_ID).isPresent()) {
      logger.info("Sabeq user already exists, skipping seed.");
      return;
    }

    logger.info("Creating Sabeq user...");

    // Create the Sabeq user
    User sabeq = User.builder()
        .id(User.SABEQ_ID)
        .email("sabeq@tanafaso.com")
        .username("sabeq")
        .firstName("سابق")
        .lastName("")
        .personalChallenges(new ArrayList<>())
        .finishedPersonalChallengesCount(0)
        .userGroups(new ArrayList<>())
        .userChallenges(new ArrayList<>())
        .azkarChallenges(new ArrayList<>())
        .finishedAzkarChallengesCount(0)
        .meaningChallenges(new ArrayList<>())
        .finishedMeaningChallengesCount(0)
        .memorizationChallenges(new ArrayList<>())
        .finishedMemorizationChallengesCount(0)
        .readingQuranChallenges(new ArrayList<>())
        .finishedReadingQuranChallengesCount(0)
        .customSimpleChallenges(new ArrayList<>())
        .finishedCustomSimpleChallengesCount(0)
        .resetPasswordToken("")
        .build();

    userRepo.save(sabeq);

    // Create friendship document for sabeq
    Friendship sabeqFriendship = Friendship.builder()
        .userId(User.SABEQ_ID)
        .friends(new ArrayList<>())
        .id(new ObjectId().toString())
        .build();

    friendshipRepo.save(sabeqFriendship);

    logger.info("Sabeq user created successfully!");
  }

  /**
   * Creates two test users that are friends with each other.
   * Uses userService.addNewUser() to ensure they get Sabeq as a friend automatically.
   * User 1: test1@tanafaso.com / password123
   * User 2: test2@tanafaso.com / password123
   */
  private void seedTestUsers() {
    String user1Email = "test1@tanafaso.com";
    String user2Email = "test2@tanafaso.com";

    // Check if users already exist
    if (userRepo.findByEmail(user1Email).isPresent()) {
      logger.info("Test users already exist, skipping seed.");
      return;
    }

    logger.info("Creating test users...");

    // Common password for test accounts: "password123"
    String encodedPassword = passwordEncoder.encode("password123");

    // Create User 1 using UserService
    // (this automatically adds Sabeq as friend and creates challenges)
    User user1 = userService.buildNewUser(user1Email, "Ahmed", "Ali", encodedPassword);
    user1 = userService.addNewUser(user1);

    // Create User 2 using UserService
    // (this automatically adds Sabeq as friend and creates challenges)
    User user2 = userService.buildNewUser(user2Email, "Fatima", "Hassan", encodedPassword);
    user2 = userService.addNewUser(user2);

    // Now make User 1 and User 2 friends with each other
    makeFriends(user1, user2);
    
    logger.info("Test users created successfully!");
    logger.info("  - {} / password123 (ID: {})", user1Email, user1.getId());
    logger.info("  - {} / password123 (ID: {})", user2Email, user2.getId());
    logger.info("Users have Sabeq as a friend, starting challenges, "
        + "and are friends with each other");
  }

  /**
   * Creates a friendship between two users, mimicking the
   * sendFriendRequest + acceptFriendRequest flow.
   * This creates a binary group and adds both users as non-pending friends
   * to each other.
   */
  private void makeFriends(User user1, User user2) {
    // Create binary group for these two users
    Group binaryGroup = Group.builder()
        .usersIds(Arrays.asList(user1.getId(), user2.getId()))
        .creatorId(user1.getId())
        .challengesIds(new ArrayList<>())
        .build();
    groupRepo.save(binaryGroup);

    // Get existing friendships
    Friendship user1Friendship = friendshipRepo.findByUserId(user1.getId());
    Friendship user2Friendship = friendshipRepo.findByUserId(user2.getId());

    // Add user2 as friend to user1
    Friend user2AsFriend = Friend.builder()
        .userId(user2.getId())
        .username(user2.getUsername())
        .firstName(user2.getFirstName())
        .lastName(user2.getLastName())
        .isPending(false)
        .groupId(binaryGroup.getId())
        .build();
    user1Friendship.getFriends().add(user2AsFriend);

    // Add user1 as friend to user2
    Friend user1AsFriend = Friend.builder()
        .userId(user1.getId())
        .username(user1.getUsername())
        .firstName(user1.getFirstName())
        .lastName(user1.getLastName())
        .isPending(false)
        .groupId(binaryGroup.getId())
        .build();
    user2Friendship.getFriends().add(user1AsFriend);

    // Save friendships
    friendshipRepo.save(user1Friendship);
    friendshipRepo.save(user2Friendship);

    logger.info("Created friendship between {} and {}", user1.getUsername(), user2.getUsername());
  }
}
