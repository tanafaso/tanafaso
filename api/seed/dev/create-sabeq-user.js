// Script to create the Sabeq user in MongoDB
// Run this with: docker exec -i mongo mongosh tanafaso -u tanafaso-db-username -p tanafaso-db-password < create-sabeq-user.js

db = db.getSiblingDB('tanafaso');

// Check if sabeq already exists
const existingSabeq = db.users.findOne({ _id: ObjectId("60d18088076b0b7d53e5a35a") });

if (existingSabeq) {
  print("Sabeq user already exists!");
} else {
  // Create the Sabeq user
  db.users.insertOne({
    _id: ObjectId("60d18088076b0b7d53e5a35a"),
    email: "sabeq@tanafaso.com",
    username: "sabeq",
    firstName: "سابق",
    lastName: "",
    personalChallenges: [],
    finishedPersonalChallengesCount: 0,
    userGroups: [],
    userChallenges: [],
    azkarChallenges: [],
    finishedAzkarChallengesCount: 0,
    meaningChallenges: [],
    finishedMeaningChallengesCount: 0,
    memorizationChallenges: [],
    finishedMemorizationChallengesCount: 0,
    readingQuranChallenges: [],
    finishedReadingQuranChallengesCount: 0,
    customSimpleChallenges: [],
    finishedCustomSimpleChallengesCount: 0,
    resetPasswordToken: "",
    createdAt: new Date().getTime(),
    updatedAt: new Date().getTime(),
    _class: "com.azkar.entities.User"
  });

  // Create friendship document for sabeq
  db.friendships.insertOne({
    userId: "60d18088076b0b7d53e5a35a",
    friends: [],
    _class: "com.azkar.entities.Friendship"
  });

  print("Sabeq user created successfully!");
}
