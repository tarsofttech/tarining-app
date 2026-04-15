import 'dart:convert';
import 'package:http/http.dart' as http;

import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://todo.ai.tarsoft.my/api';

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (auth) {
      final token = await StorageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, dynamic> _normalizeTodo(Map<String, dynamic> json) {
    return {
      'id': json['id'] as int? ?? 0,
      'title': json['title'] as String? ?? '',
      'description': json['description'] as String? ?? '',
      'isCompleted': json['is_completed'] as bool? ?? false,
      'dueDate': json['due_date'] as String?,
      'mediaUrl': json['media_url'] as String?,
    };
  }

  static String _extractMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'];
        if (message is String && message.isNotEmpty) return message;
        final errors = body['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }
      }
    } catch (_) {}
    return 'Request failed (${response.statusCode})';
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/login'),
      headers: {
        ...await _headers(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Login succeeded but token was missing.');
    }
    await StorageService.saveAuthToken(token);
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/register'),
      headers: {
        ...await _headers(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Registration succeeded but token was missing.');
    }
    await StorageService.saveAuthToken(token);
  }

  static Future<void> logout() async {
    try {
      await http.post(
        _uri('/logout'),
        headers: await _headers(auth: true),
      );
    } finally {
      await StorageService.clearAuthToken();
      await StorageService.clearTasks();
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    final response = await http.get(
      _uri('/todos'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['data'] as List<dynamic>? ?? const []);
    return items
        .map((item) => _normalizeTodo(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> task,
  ) async {
    final request = http.MultipartRequest('POST', _uri('/todos'))
      ..headers.addAll(await _headers(auth: true))
      ..fields['title'] = (task['title'] as String? ?? '').trim();

    final dueDate = task['dueDate'] as String?;
    if (dueDate != null && dueDate.isNotEmpty) {
      request.fields['due_date'] = dueDate.split('T').first;
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 201) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _normalizeTodo(Map<String, dynamic>.from(body['data'] as Map));
  }

  static Future<Map<String, dynamic>> updateTask(
    int id, {
    required String title,
    DateTime? dueDate,
    required bool isCompleted,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/todos/$id'))
      ..headers.addAll(await _headers(auth: true))
      ..fields['_method'] = 'PUT'
      ..fields['title'] = title.trim()
      ..fields['is_completed'] = isCompleted ? '1' : '0';

    if (dueDate != null) {
      request.fields['due_date'] = dueDate.toIso8601String().split('T').first;
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _normalizeTodo(Map<String, dynamic>.from(body['data'] as Map));
  }

  static Future<Map<String, dynamic>> toggleTaskCompletion(int id) async {
    final request = http.Request('PATCH', _uri('/todos/$id/complete'))
      ..headers.addAll(await _headers(auth: true));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _normalizeTodo(Map<String, dynamic>.from(body['data'] as Map));
  }

  static Future<void> deleteTask(int id) async {
    final response = await http.delete(
      _uri('/todos/$id'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode != 204) {
      throw Exception(_extractMessage(response));
    }

  }
}
