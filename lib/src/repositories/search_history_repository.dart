import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryRepository {
  static const _historyKey = 'search_history_v1';

  Future<List<String>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? <String>[];
  }

  Future<void> saveHistory(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, items);
  }
}
