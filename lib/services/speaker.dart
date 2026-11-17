import 'package:flutter_tts/flutter_tts.dart';

/// Reads text aloud with the device's text-to-speech engine.
/// Never throws: returns false when audio is not available.
class Speaker {
  Speaker._();

  static final FlutterTts _tts = FlutterTts();
  static bool _configured = false;

  static Future<bool> speak(String text, String locale) async {
    try {
      if (!_configured) {
        await _tts.setSpeechRate(0.4); // slower = easier for learners
        _configured = true;
      }
      await _tts.setLanguage(locale);
      await _tts.stop();
      await _tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }
}
