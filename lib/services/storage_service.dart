import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tasksKey = 'tasks_v1';
  static const _authTokenKey = 'auth_token';

  // Load tasks from shared_preferences. Returns empty list if none stored.
  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_tasksKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // Save tasks list to shared_preferences
  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks);
    await prefs.setString(_tasksKey, encoded);
  }

  static Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }
}
