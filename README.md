<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=6875F5&height=180&section=header&text=Quiz%20App&fontSize=58&fontColor=FFFFFF&animation=fadeIn" alt="Quiz App banner" width="100%" />

### Test your knowledge. Beat the clock.

<p>A simple and fun Flutter app for playing trivia quizzes with questions from Open Trivia DB.</p>

<img src="https://img.shields.io/badge/Flutter-3.x-6875F5?logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-111827" alt="Platforms" />

</div>

<br />

## About

Quiz App lets you challenge yourself with trivia questions from many categories. Choose the number of questions, category, difficulty, and question type, answer before the timer runs out, and review your results in the history.

## Features

- Questions loaded from Open Trivia DB
- Multiple choice and True/False questions
- Choose category, difficulty, and number of questions
- 15-second timer for each question
- Skip button for hard questions
- Result screen with correct, wrong, and skipped answers
- Quiz history saved locally
- Delete a single result or clear the whole history
- Light and dark themes

## Built With

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- [Dio](https://pub.dev/packages/dio)
- [Hive](https://pub.dev/packages/hive_flutter)
- [Open Trivia DB](https://opentdb.com/)

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Xcode for mobile development
- Internet connection (questions are loaded from the API)

### Installation

```bash
git clone https://github.com/your-username/quiz_app.git
cd quiz_app
flutter pub get
flutter run
```

## Project Structure

```text
lib/
├── app/
│   ├── quiz_app.dart        # App configuration and themes
│   └── home_shell.dart      # Bottom navigation
├── core/
│   ├── theme/               # Colors and light/dark themes
│   └── widgets/
│       └── labeled_dropdown.dart  # Reusable dropdown field
├── features/
│   ├── quiz/
│   │   ├── data/
│   │   │   └── trivia_client.dart  # Open Trivia DB requests (Dio)
│   │   ├── domain/                 # Question, category, quiz settings
│   │   ├── logic/
│   │   │   ├── setup_cubit.dart    # Quiz settings and loading
│   │   │   └── quiz_cubit.dart     # Quiz progress and timer
│   │   └── ui/
│   │       ├── quiz_setup_page.dart # Main screen
│   │       ├── question_page.dart   # Multiple choice and True/False
│   │       └── result_page.dart     # Quiz result
│   ├── history/
│   │   ├── data/
│   │   │   └── history_repository.dart # Local storage (Hive)
│   │   ├── domain/
│   │   │   └── quiz_result.dart        # Result model
│   │   ├── logic/
│   │   │   └── history_cubit.dart      # History state management
│   │   └── ui/
│   │       └── history_page.dart       # History screen
│   └── settings/
│       ├── logic/
│       │   └── theme_cubit.dart        # Theme state management
│       └── ui/
│           └── settings_page.dart      # App settings screen
└── main.dart                # Application entry point
```

## Demo

<div align="center">
	<img src="docs/quiz-demo.svg" alt="Animated preview of Quiz App" width="640" />
</div>

## License

This project is for learning and personal use.

<br />

<img src="https://capsule-render.vercel.app/api?type=waving&color=6875F5&height=120&section=footer" alt="footer" width="100%" />
