# CodeAlpha_LanguageLearningApp

An interactive Language Learning app built with Flutter for the CodeAlpha App Development Internship (Task 4).

## Features

- Learn **Spanish, French or German** (switch language any time)
- **Categories:** Vocabulary, Phrases and Grammar
- **Flashcards** with the translation, an easy pronunciation guide and a usage/grammar tip
- **Listen** button: the device reads the word aloud (text-to-speech)
- **Daily lesson:** 5 new items every day, with a **daily streak**
- **Quizzes / practice tests:** 10 multiple-choice questions, by topic or all topics, with instant feedback and a final score
- **Progress screen:** items learned per topic, average and best quiz score, quiz history
- All learning data and progress are stored locally on the device (shared_preferences), no internet needed
- Clean Material 3 interface with light and dark mode

## Project structure

```
lib/
  main.dart                      App entry point and themes
  models/                        Language, LessonCategory, LessonItem, QuizResult
  data/content.dart              All lesson content (3 languages)
  data/learn_store.dart          Progress, streak, daily lesson + local storage
  services/speaker.dart          Text-to-speech wrapper
  screens/home_shell.dart        Bottom navigation (Learn / Practice / Progress)
  screens/home_screen.dart       Language, streak, daily lesson, topics
  screens/lesson_screen.dart     Flashcards
  screens/practice_screen.dart   Choose a topic and start a quiz
  screens/quiz_screen.dart       Multiple-choice quiz and result
  screens/progress_screen.dart   Statistics and history
  widgets/language_sheet.dart    Language picker
```

## Run it

```bash
flutter create codealpha_languagelearning
cd codealpha_languagelearning
flutter pub add shared_preferences flutter_tts
flutter run
```


## Tech

Flutter, Dart, Material 3, shared_preferences, flutter_tts
