<h1 align="center">:fire: تنافسوا</h1>

[![Code Formatter and Analayzer](https://github.com/tanafaso/tanafaso-frontend/actions/workflows/Code%20Formatter%20and%20Analayzer.yml/badge.svg)](https://github.com/tanafaso/tanafaso-frontend/actions/workflows/Code%20Formatter%20and%20Analayzer.yml)
[![Notifications Disabled (for ease of open source contributions)](https://github.com/tanafaso/tanafaso-frontend/actions/workflows/Notifications%20Disabled%20Check.yml/badge.svg)](https://github.com/tanafaso/tanafaso-frontend/actions/workflows/Notifications%20Disabled%20Check.yml)

A Flutter application for Muslims that help them challenge and motivate themselves and their friends to read Azkar in a fun way.

[On Play Store](https://play.google.com/store/apps/details?id=com.tanafaso.azkar) & [On App Store](https://apps.apple.com/us/app/تنافسوا/id1564309117?platform=iphone)

Also, take a look at the [Backend](https://github.com/tanafaso/tanafaso-backend) repository.

| ![Screenshot_1639467611](https://user-images.githubusercontent.com/13997703/146137503-39447315-5f58-48f6-8e95-1e742f7a570e.png) | ![Screenshot_1639467257](https://user-images.githubusercontent.com/13997703/146137488-7f9c214f-859b-4eb3-90f2-9f688b02f7e2.png) | ![Screenshot_1639467166](https://user-images.githubusercontent.com/13997703/146137484-6a62dbde-70ca-4821-9e58-8268fbdfca73.png) |
|-|-|-|
| ![Screenshot_1639466941](https://user-images.githubusercontent.com/13997703/146137475-81d5589f-817b-46bd-9e01-42474394e4b9.png) | ![Screenshot_1639466636](https://user-images.githubusercontent.com/13997703/146137449-e061292a-4a03-4b92-abee-2c21ef164c48.png) | ![Screenshot_1639466561](https://user-images.githubusercontent.com/13997703/146137438-40b870e6-610a-4ae1-a2c5-2774ff863aef.png) |

## Setting up a Development Environment
 ### Git
  To set up a local development environment, you have to do the following :
  - Fork [tanafaso-frontend](https://github.com/tanafaso/tanafaso-frontend)
  - Clone your fork using git clone `https://github.com/<your-github-username>/tanafaso-frontend`
  - Navigate to your local repository using your cmd/terminal based on your local environment
  - Check that your fork is the origin remote using `git remote -v`, if it is not then added using `git remote add origin https://github.com/<your-github-username>/tanafaso-frontend`
  - Add the original project as upstream remote using `git remote add upstream https://github.com/tanafaso/tanafaso-frontend`
  - Congratulations, you can start contribute now, but make sure you create branch for every proposed change you make.
 ### Test Accounts
 To get started quickly, you can sign in using Facebook with any of the following test accounts and feel free to add friendships or to create challenges with other test accounts.

Facebook Test Email | Password
--- | ---
qfgarmsuoy_1631511467@tfbnw.net | tanafasotestuser
jpspapvsle_1630996165@tfbnw.net | tanafasotestuser
ewwaeqgjsz_1622703110@tfbnw.net | tanafasotestuser
gblsxmnsle_1631558303@tfbnw.net | tanafasotestuser
 
 ### Note on Firebase Notifications Development
 Please note that if you don't intend to do changes regarding notifications, you have to comment the line `apply plugin: 'com.google.gms.google-services'` in file `android/app/build.gradle` so as to be able to build the android project.
 
 If you intend to do changes regarding notifications, please create a firebase cloud messaging testing project and then move the `google-services.json` file you will obtain from firebase to `android/app` directory.

## Dependencies
### Dependencies for Android
- Android Studio IDE
- Flutter SDK
- Java SDK

### Dependencies for IOS
- Xcode IDE

For more information about dependencies, you can check the [flutter documentation](https://flutter.dev/docs/get-started/install).

## Code GuideLines
- Use [snake case](https://www.theserverside.com/definition/Snake-case) for file names.
- The filename should correspond to the name of the primary class in the file.
- Names of files that contains widgets that take the whole screen should end with the suffix: `_screen.dart`, for example, signup or login takes up the whole screen for authentication.
- Names of files that contains widgets that don't take the whole screen should end with the suffix: `_widget.dart`, for example, invite friends from facebook or twitter is a widget since it is part of the screen widget, but does not take the whole screen.
- Use [Camel Case](https://techterms.com/definition/camelcase) convention for class and enum names.
- Name (classes, variables, functions, modules) in a meaningful name which describe its functionality.
- Make sure that all .dart files are formatted using `flutter format` command.

## Code Structure
Assets (pictures, fonts and certificates) can be found in the [assets/](https://github.com/tanafaso/tanafaso-frontend/tree/master/assets) folder.

As you may already know, the cool thing about flutter is that you write code once in dart and
 then flutter does the hard work of compiling it into native Android and iOS code. You can find
  the compiled native code in the following directories (**Note** that you would rarely need to
   change code in these
   directories):
  - [android/](https://github.com/tanafaso/tanafaso-frontend/tree/master/android)
  - [ios/](https://github.com/tanafaso/tanafaso-frontend/tree/master/ios)
  
All the dart code can be found in the [lib/](https://github.com/tanafaso/tanafaso-frontend/tree/master/lib) directory.
- [lib/models/](https://github.com/tanafaso/tanafaso-frontend/tree/master/lib/models
): Contains the definitions of all of the models used in the application (e.g. User, Challenge
, etc...) and also defines how every model should be encoded and decoded.
- [lib/net/](https://github.com/tanafaso/tanafaso-frontend/tree/master/lib/net
): Implements the wire between the frontend and the backend ([tanafaso/tanafas-backend](https://github.com/tanafaso/tanafaso-backend)).
    - [lib/net/endpoints.dart](https://github.com/tanafaso/tanafaso-frontend/blob/master/lib/net/endpoints.dart) contains all of the endpoints that the API is supporting for this
     frontend version.
- [lib/utils/](https://github.com/tanafaso/tanafaso-frontend/tree/master/lib/utils
): Contains classes that provide utilities that will be used throughout the application code.
- [lib/views/](https://github.com/tanafaso/tanafaso-frontend/tree/master/lib/views
): Contains all of the declarations of the user interface.
  - *Screen.dart: Classes that end with the suffix "Screen" are declaring a whole screen that the
   user will see.
  - *Widget.dart: Classes that end with the suffix "Widget" are declaring a widget that will be
   part of the user screen.

## Contributing
(Optionally) join Tanafaso's [discord server](https://discord.gg/jSKsZdJcT5) to give feedback, propose new features or ask for help.

There are a lot of ways you can contribute to this project. You can filter issues by `good first issue` label to get started with an issue that is easy to fix.
- Suggest new features by filing an issue.
- Report bugs by filing an issue.
- Add code documentation, so that it is easier for future contributers to ramp-up.
- Add unit tests (Read [The Testing Strategy](https://github.com/tanafaso/tanafaso-frontend/blob/master/test/README.md)).
- Add widget tests (Read [The Testing Strategy](https://github.com/tanafaso/tanafaso-frontend/blob/master/test/README.md)).
- Refactor the code to make it more readable, maintainable and scalable.
- Add pull requests with bug fixes.
- Add pull requests with new features.

## License
The application code is licensed under [MIT LICENSE](https://github.com/tanafaso/tanafaso-frontend/blob/master/LICENSE.md).
