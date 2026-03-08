<h1 align="center">:fire: تنافسوا</h1>

[![Build, Test & Package](https://github.com/tanafaso/tanafaso-backend/actions/workflows/Build,%20Test%20&%20Package.yml/badge.svg)](https://github.com/tanafaso/tanafaso-backend/actions/workflows/Build,%20Test%20&%20Package.yml)

A Spring boot application that is a backend for a mobile application for Muslims to help them challenge and motivate themselves and their friends to read Azkar in a fun way.

[On Play Store](https://play.google.com/store/apps/details?id=com.tanafaso.azkar) & [On App Store](https://apps.apple.com/us/app/تنافسوا/id1564309117?platform=iphone)

Also, take a look at the [Frontend](https://github.com/challenge-azkar/tanafaso-frontend) repository.

| ![Screenshot_1639467611](https://user-images.githubusercontent.com/13997703/146137503-39447315-5f58-48f6-8e95-1e742f7a570e.png) | ![Screenshot_1639467257](https://user-images.githubusercontent.com/13997703/146137488-7f9c214f-859b-4eb3-90f2-9f688b02f7e2.png) | ![Screenshot_1639467166](https://user-images.githubusercontent.com/13997703/146137484-6a62dbde-70ca-4821-9e58-8268fbdfca73.png) |
|-|-|-|
| ![Screenshot_1639466941](https://user-images.githubusercontent.com/13997703/146137475-81d5589f-817b-46bd-9e01-42474394e4b9.png) | ![Screenshot_1639466636](https://user-images.githubusercontent.com/13997703/146137449-e061292a-4a03-4b92-abee-2c21ef164c48.png) | ![Screenshot_1639466561](https://user-images.githubusercontent.com/13997703/146137438-40b870e6-610a-4ae1-a2c5-2774ff863aef.png) |

## Code Structure
- [configs/](https://github.com/challenge-azkar/tanafaso-backend/tree/master/src/main/java/com/azkar/configs): Contains classes annotated with  [@Configuration](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/annotation/Configuration.html), which means that those classes declares beans. Those beans will either be used when needed throughout the code, e.g. in [CategoriesCacher](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/configs/CategoriesCacher.java) or will be scanned by a library and used on startup, e.g. in [MongobeeConfig](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/configs/MongobeeConfig.java).
- [controllers/](https://github.com/challenge-azkar/tanafaso-backend/tree/master/src/main/java/com/azkar/controllers): Contains the logic that is applied when every kind of request is received, e.g. [FriendshipController](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/controllers/FriendshipController.java) contains the logic for every endpoint related to friendship, like requesting/accepting/rejecting a friendship.
- [entities/](https://github.com/challenge-azkar/tanafaso-backend/tree/master/src/main/java/com/azkar/entities): Contains the definitions of all of the models used in the application, e.g. [User](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/entities/User.java). 
- [payload/](https://github.com/challenge-azkar/tanafaso-backend/tree/master/src/main/java/com/azkar/payload): Contains the definition of the structure of every request and every response, e.g. [UpdateChallengeRequest](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/payload/challengecontroller/requests/UpdateChallengeRequest.java) and [UpdateChallengeResponse](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/payload/challengecontroller/responses/UpdateChallengeResponse.java).
- [repos/](https://github.com/challenge-azkar/tanafaso-backend/tree/master/src/main/java/com/azkar/repos): Contains interfaces that are all annotated by [@Repository](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/stereotype/Repository.html) and will be scanned on startup to create beans for every repository that can later be [@Autowired](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/annotation/Autowired.html) and used throughout the code to interact with the Mongo database.
- [services/](https://github.com/challenge-azkar/tanafaso-backend/tree/master/src/main/java/com/azkar/services): Contains interfaces that are all annotated by [@Service](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/stereotype/Service.html) and can be used throughout the code to provide some utilities, e.g. [NotificationsService](https://github.com/challenge-azkar/tanafaso-backend/blob/master/src/main/java/com/azkar/services/NotificationsService.java) can be used to send a notification to a user.

## Get Started Guide
### Clone Repository
- Navigate to the location you want to save Tanafaso's backend at.
- Clone the repository: `git clone https://github.com/tanafaso/tanafaso-backend.git`
- Change directory: `cd tanafaso-backend/`

### Run the server using Docker
**Note** that docker may take a long time building images for the first time.
- Install [Docker](https://docs.docker.com/get-docker/)
- Run: `docker compose up`
- The server will be available at http://localhost:8080

## Contributing
(Optionally) join Tanafaso's [discord server](https://discord.gg/jSKsZdJcT5) to give feedback, propose new features or ask for help.

There are a lot of ways you can contribute to this project. You can filter issues by `good first issue` label to get started with an issue that is easy to fix.
- Suggest new features by filing an issue.
- Report bugs by filing an issue.
- Add code documentation, so that it is easier for future contributers to ramp-up.
- Add tests.
- Refactor the code to make it more readable, maintainable and scalable.
- Add pull requests with bug fixes.
- Add pull requests with new features.

## License
The application code is licensed under [MIT LICENSE](https://github.com/challenge-azkar/tanafaso-backend/blob/master/LICENSE.md).
