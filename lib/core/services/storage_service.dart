import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _progressKey = 'puzzle_progress';

  Future<void> saveProgress(String payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, payload);
  }

  Future<String?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_progressKey);
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
