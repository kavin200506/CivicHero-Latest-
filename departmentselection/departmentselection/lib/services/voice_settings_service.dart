import 'package:shared_preferences/shared_preferences.dart';

/// Voice Settings Service
/// Manages voice command activation mode preferences
class VoiceSettingsService {
  static const String _keyVoiceMode = 'voice_mode'; // 'continuous' or 'push_to_talk'
  static const String _keyAutoStart = 'voice_auto_start'; // bool

  /// Get current voice activation mode
  /// Returns 'continuous' or 'push_to_talk'
  static Future<String> getVoiceMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVoiceMode) ?? 'push_to_talk'; // Default to push-to-talk
  }

  /// Set voice activation mode
  static Future<void> setVoiceMode(String mode) async {
    if (mode != 'continuous' && mode != 'push_to_talk') {
      throw ArgumentError('Mode must be "continuous" or "push_to_talk"');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVoiceMode, mode);
  }

  /// Check if auto-start is enabled (for continuous mode)
  static Future<bool> isAutoStartEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoStart) ?? false; // Default to false
  }

  /// Set auto-start enabled/disabled
  static Future<void> setAutoStartEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoStart, enabled);
  }

  /// Get all voice settings
  static Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'mode': await getVoiceMode(),
      'autoStart': await isAutoStartEnabled(),
    };
  }
}



