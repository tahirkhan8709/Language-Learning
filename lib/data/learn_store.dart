import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/language.dart';
import '../models/lesson_item.dart';
import '../models/quiz_result.dart';
import 'content.dart';

/// Holds the learner's progress and saves it on the device
/// (shared_preferences): selected language, learned items, quiz results,
/// daily streak and daily-lesson status.
class LearnStore extends ChangeNotifier {
  static const String _kLanguage = 'learn_language_v1';
  static const String _kLearned = 'learn_learned_v1';
  static const String _kResults = 'learn_results_v1';
  static const String _kStreak = 'learn_streak_v1';
  static const String _kLastActive = 'learn_last_active_v1';
  static const String _kDailyDone = 'learn_daily_done_v1';

  static const int dailyCount = 5;
  static const int maxStoredResults = 50;

  Language _language = Language.spanish;
  final Set<String> _learned = {};
  final List<QuizResult> _results = []; // newest first
  int _streak = 0;
  String? _lastActive;
  String? _dailyDone;

  Language get language => _language;
  List<QuizResult> get results => List.unmodifiable(_results);

  // ---------------------------------------------------------------- load

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final lang = prefs.getString(_kLanguage);
    _language = Language.values.firstWhere(
      (l) => l.name == lang,
      orElse: () => Language.spanish,
    );

    _learned
      ..clear()
      ..addAll(prefs.getStringList(_kLearned) ?? const []);

    _results.clear();
    final rawResults = prefs.getString(_kResults);
    if (rawResults != null) {
      try {
        final decoded = jsonDecode(rawResults) as List<dynamic>;
        _results.addAll(
          decoded.map((e) => QuizResult.fromJson(e as Map<String, dynamic>)),
        );
      } catch (_) {
        // Corrupted data: start fresh instead of crashing.
      }
    }

    _streak = prefs.getInt(_kStreak) ?? 0;
    _lastActive = prefs.getString(_kLastActive);
    _dailyDone = prefs.getString(_kDailyDone);
    notifyListeners();
  }

  // ------------------------------------------------------------ language

  Future<void> setLanguage(Language language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    await _save();
  }

  // ------------------------------------------------------------- learned

  bool isLearned(String id) => _learned.contains(id);

  int learnedAmong(List<LessonItem> items) =>
      items.where((i) => _learned.contains(i.id)).length;

  int get learnedCountForLanguage =>
      learnedAmong(Content.forLanguage(_language));

  Future<void> setLearned(String id, bool value) async {
    if (value) {
      _learned.add(id);
      _registerActivity();
    } else {
      _learned.remove(id);
    }
    notifyListeners();
    await _save();
  }

  // --------------------------------------------------------- daily lesson

  /// Today's 5 items. Same items all day, different tomorrow.
  List<LessonItem> get dailyItems {
    final all = Content.forLanguage(_language);
    if (all.isEmpty) return const [];
    final now = DateTime.now();
    final day =
        DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/
            86400000;
    final start = (day * dailyCount) % all.length;
    return List.generate(dailyCount, (i) => all[(start + i) % all.length]);
  }

  bool get dailyDoneToday => _dailyDone == _dateKey(DateTime.now());

  Future<void> completeDaily() async {
    _dailyDone = _dateKey(DateTime.now());
    _registerActivity();
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------- quiz

  Future<void> addQuizResult(QuizResult result) async {
    _results.insert(0, result);
    if (_results.length > maxStoredResults) {
      _results.removeRange(maxStoredResults, _results.length);
    }
    _registerActivity();
    notifyListeners();
    await _save();
  }

  // -------------------------------------------------------------- streak

  /// Days in a row with some learning activity. Shows 0 if the streak
  /// was broken (nothing yesterday or today).
  int get currentStreak {
    final last = _lastActive;
    if (last == null) return 0;
    final now = DateTime.now();
    final today = _dateKey(now);
    final yesterday = _dateKey(DateTime(now.year, now.month, now.day - 1));
    return (last == today || last == yesterday) ? _streak : 0;
  }

  void _registerActivity() {
    final now = DateTime.now();
    final today = _dateKey(now);
    if (_lastActive == today) return;
    final yesterday = _dateKey(DateTime(now.year, now.month, now.day - 1));
    _streak = (_lastActive == yesterday) ? _streak + 1 : 1;
    _lastActive = today;
  }

  // --------------------------------------------------------------- reset

  Future<void> resetProgress() async {
    _learned.clear();
    _results.clear();
    _streak = 0;
    _lastActive = null;
    _dailyDone = null;
    notifyListeners();
    await _save();
  }

  // ------------------------------------------------------------- helpers

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, _language.name);
    await prefs.setStringList(_kLearned, _learned.toList());
    await prefs.setString(
      _kResults,
      jsonEncode(_results.map((r) => r.toJson()).toList()),
    );
    await prefs.setInt(_kStreak, _streak);
    if (_lastActive != null) {
      await prefs.setString(_kLastActive, _lastActive!);
    } else {
      await prefs.remove(_kLastActive);
    }
    if (_dailyDone != null) {
      await prefs.setString(_kDailyDone, _dailyDone!);
    } else {
      await prefs.remove(_kDailyDone);
    }
  }
}
