import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // поменяй на IP своего компа в локальной сети
  static const String baseUrl = 'http://192.168.0.105:8000';

  /// Получение всех списков (каждый список содержит свои items)
  static Future<List<dynamic>> fetchLists() async {
    final uri = Uri.parse('$baseUrl/lists');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Ошибка загрузки списков: ${response.statusCode}');
  }

  /// Создать новый список и вернуть его JSON
  static Future<Map<String, dynamic>> createList({
  required String title,
  required String icon,
  required int color,
}) async {
  final uri = Uri.parse('$baseUrl/lists');
  final id = DateTime.now().millisecondsSinceEpoch;

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': id,
      'title': title,
      'icon': icon,
      'color': color,
      'items': [],
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception('Ошибка создания списка');
}

  /// Удалить список по id
  static Future<void> deleteList(int id) async {
    final uri = Uri.parse('$baseUrl/lists/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка удаления списка: ${response.statusCode}');
    }
  }

  /// Получить items конкретного списка по его id
  static Future<List<dynamic>> fetchItems(int listId) async {
    final lists = await fetchLists();
    final list = lists.firstWhere(
      (l) => l['id'] == listId,
      orElse: () => null,
    );

    if (list == null) {
      throw Exception('Список не найден');
    }

    final items = list['items'] as List<dynamic>?;
    return items ?? <dynamic>[];
  }

  /// Добавить пункт в список
  static Future<Map<String, dynamic>> addItem(
    int listId,
    String title,
  ) async {
    final uri = Uri.parse('$baseUrl/lists/$listId/items');
    final id = DateTime.now().millisecondsSinceEpoch;

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'title': title,
        'isChecked': false,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Ошибка добавления пункта: ${response.statusCode}');
  }

  /// Обновить пункт (например, галочку)
  static Future<void> updateItem(
    int listId,
    int itemId, {
    required String title,
    required bool isChecked,
  }) async {
    final uri = Uri.parse('$baseUrl/lists/$listId/items/$itemId');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': itemId,
        'title': title,
        'isChecked': isChecked,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления пункта: ${response.statusCode}');
    }
  }


  static Future<void> updateListTitle(int listId, String title) async {
  final uri = Uri.parse('$baseUrl/lists/$listId');

  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'title': title}),
  );

  if (response.statusCode != 200) {
    throw Exception('Ошибка обновления списка');
  }
}

  /// Удалить пункт из списка
  static Future<void> deleteItem(int listId, int itemId) async {
    final uri = Uri.parse('$baseUrl/lists/$listId/items/$itemId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка удаления пункта: ${response.statusCode}');
    }
  }
}

