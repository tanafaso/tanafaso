# Tanafaso

A social Islamic app for Muslims to challenge each other in doing good deeds, reading Quran, and maintaining daily azkar (remembrance of Allah).

## 🏗️ Architecture

This is a monorepo containing both the mobile application and backend API:

```
tanafaso/
├── mobile/          # Flutter mobile application (iOS & Android)
├── api/             # Spring Boot REST API
└── .github/         # CI/CD workflows
```

### System Architecture

```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
         │ HTTPS/REST
         │
┌────────▼────────┐
│  Backend API    │
│  (Spring Boot)  │
└────────┬────────┘
         │
         │
┌────────▼────────┐
│  MongoDB        │
│  (Database)     │
└─────────────────┘
```

## 🛠️ Technologies

### Mobile (`mobile/`)
- **Framework**: Flutter 2.5.3
- **Language**: Dart
- **Platforms**: iOS, Android
- **Key Features**: 
  - Social authentication (Google, Apple, Facebook)
  - Push notifications
  - Quran reading and memorization challenges
  - Friend leaderboards and groups

### API (`api/`)
- **Framework**: Spring Boot
- **Language**: Java
- **Database**: MongoDB
- **Key Features**:
  - RESTful API
  - JWT authentication
  - Social OAuth integration
  - Scheduled jobs for challenge cleanup
  - Docker support

## 🚀 Getting Started

### Prerequisites

**For Mobile Development:**
- Flutter SDK 2.5.3+
- Dart SDK
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

**For API Development:**
- Java JDK 11+
- Maven 3.6+
- MongoDB 4.4+
- Docker & Docker Compose (optional but recommended)

### Setting Up the Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

For detailed mobile setup, configuration, and development instructions, see [mobile/README.md](mobile/README.md).

### Setting Up the API

#### Using Docker (Recommended)
```bash
cd api
docker-compose up
```

#### Manual Setup
```bash
cd api
# Start MongoDB first
./mvnw spring-boot:run
```

For detailed API setup, environment variables, and development instructions, see [api/README.md](api/README.md).

## 🤝 Contributing

### Workflow

1. **Fork and clone** the repository
2. **Create a branch** for your feature: `git checkout -b feature/amazing-feature`
3. **Make your changes** in either `mobile/` or `api/` directory
4. **Test your changes** locally
5. **Commit** with clear messages: `git commit -m 'Add amazing feature'`
6. **Push** to your fork: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Code Style

- **Mobile**: Follow Dart style guide. Run `flutter format .` before committing
- **API**: Follow Google Java Style Guide (enforced by checkstyle)

### Testing

- **Mobile**: Ensure all tests pass with `flutter test`
- **API**: Run tests with `./mvnw test`

### CI/CD

GitHub Actions automatically run on pull requests:
- **Mobile workflows** trigger on `mobile/**` changes
- **API workflows** trigger on `api/**` changes

This ensures efficient CI runs - mobile changes won't trigger API builds and vice versa.

## 📁 Repository Structure

```
.
├── mobile/                          # Mobile application
│   ├── android/                     # Android-specific code
│   ├── ios/                         # iOS-specific code
│   ├── lib/                         # Dart application code
│   │   ├── models/                  # Data models
│   │   ├── views/                   # UI screens
│   │   ├── services/                # Business logic
│   │   └── net/                     # API integration
│   ├── assets/                      # Images, fonts, Quran text
│   └── pubspec.yaml                 # Flutter dependencies
│
├── api/                             # Backend API
│   ├── src/
│   │   ├── main/java/               # Java source code
│   │   │   └── com/azkar/           # Main application package
│   │   └── test/                    # Test files
│   ├── pom.xml                      # Maven dependencies
│   ├── docker-compose.yml           # Docker setup
│   └── docker-compose-test.yml      # Test environment
│
└── .github/
    └── workflows/                   # CI/CD pipelines
        ├── mobile-format-analyze.yml
        ├── mobile-notifications-check.yml
        └── api-build-test.yml
```

## 📱 Features

- **Azkar Challenges**: Daily remembrance challenges between friends
- **Quran Reading**: Track and challenge friends in Quran reading
- **Memorization**: Test Quran memorization with interactive quizzes
- **Meaning Challenges**: Learn and compete on Quran verse meanings
- **Social Features**: Friends, groups, leaderboards
- **Notifications**: Push notifications for challenges and completions
- **Multi-platform**: iOS and Android support

## 📄 License

See [mobile/LICENSE.md](mobile/LICENSE.md) for license information.

## 🔗 Links

- **Mobile README**: [mobile/README.md](mobile/README.md)
- **API README**: [api/README.md](api/README.md)
- **Issues**: [GitHub Issues](https://github.com/tanafaso/tanafaso-frontend/issues)

## 🙏 Acknowledgments

Built with ❤️ for the Muslim community to help each other grow spiritually.
