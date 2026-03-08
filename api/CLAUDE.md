# Tanafaso API - Project Knowledge

## About Tanafaso

**Tanafaso** (تنافسوا - "compete with each other") is a social Islamic mobile application that helps Muslims challenge and motivate each other in performing good deeds, particularly:

- **Azkar Challenges**: Daily remembrance of Allah (dhikr) with repetition tracking
- **Quran Reading**: Track and compete in reading Quran passages
- **Memorization Challenges**: Interactive Quran memorization quizzes
- **Meaning Challenges**: Learn and compete on understanding Quran verse meanings
- **Custom Simple Challenges**: User-defined spiritual goals

The backend is a Spring Boot REST API with MongoDB, serving Flutter mobile apps on iOS and Android.

### Core Entities

- **User**: Authenticated users with social login (Google, Apple, Facebook)
- **Friendship**: Bidirectional connections between users
- **Group**: Collections of users for group challenges
- **AzkarChallenge**: Challenges with multiple azkar (SubChallenge), each having a Zekr and repetitions
- **Challenge Types**: Reading, Memorization, Meaning, CustomSimple
- **Leaderboard**: Friend rankings based on completed challenges

### Key Features

- Friends can create challenges for each other with expiry dates
- Groups enable multi-user challenges
- Push notifications for challenge invites and completions
- Scheduled jobs clean up expired challenges
- Sabeq user (ID: `60d18088076b0b7d53e5a35a`) is auto-friended to all new users with starter challenges

## Local Development Setup

### Database Configuration (MongoDB)

Local MongoDB runs **without authentication**. Use this format in `docker-compose.yml`:
```
DATABASE_URI: mongodb://mongo:27017/tanafaso
```

**DO NOT use** `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME` separately - this causes "Database name must not contain slashes" errors.

In `application-dev.yml`:
```yaml
spring:
  data:
    mongodb:
      uri: ${DATABASE_URI}
```

### DatabaseSeeder (Dev Profile Only)

**Location**: `src/main/java/com/azkar/configs/DatabaseSeeder.java`

When `@Profile("dev")` is active, automatically seeds:
1. **Sabeq user** (ID: `60d18088076b0b7d53e5a35a`) - legendary companion who motivates all users
2. **Test users**: `test1@tanafaso.com` / `password123` and `test2@tanafaso.com` / `password123`
3. Friendship between test users
4. Each test user gets Sabeq as friend + initial challenges (via `UserService.buildNewUser()`)
