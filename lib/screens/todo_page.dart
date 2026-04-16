import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../services/api_service.dart';

class TodoPage extends StatefulWidget {
  static const routeName = '/todos';

  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> _todos = [];
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Load cached tasks first so UI is responsive
    try {
      final raw = prefs.getString('todos') ?? '[]';
      final List decoded = json.decode(raw) as List;
      setState(() {
        _todos = decoded.cast<Map<String, dynamic>>();
      });
    } catch (_) {}

    // Then try to fetch from remote API and replace cache if successful
    try {
      final remote = await ApiService.fetchTasks();
      final mapped = remote
          .map((t) => {
                'title': t['title'] as String? ?? '',
                'done': t['isCompleted'] as bool? ?? false,
              })
          .toList();
      setState(() {
        _todos = mapped.cast<Map<String, dynamic>>();
      });
      await prefs.setString('todos', json.encode(_todos));
    } catch (_) {
      // ignore remote errors and keep cache
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', json.encode(_todos));
  }

  Future<void> _addTodo(String title) async {
    if (title.trim().isEmpty) return;
    setState(() {
      _todos.add({'title': title.trim(), 'done': false});
    });
    await _saveTodos();
    _inputController.clear();
  }

  Future<void> _toggle(int index) async {
    setState(() {
      _todos[index]['done'] = !_todos[index]['done'];
    });
    await _saveTodos();
  }

  Future<void> _remove(int index) async {
    setState(() {
      _todos.removeAt(index);
    });
    await _saveTodos();
  }

  Future<void> _showAddDialog() async {
    // Keep the dialog available but prefer inline input; still provide dialog fallback.
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter todo title'),
          onSubmitted: (v) {
            Navigator.of(context).pop();
            _addTodo(v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text;
              Navigator.of(context).pop();
              _addTodo(text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _todos.length;
    final done = _todos.where((t) => t['done'] == true).length;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddDialog,
            tooltip: 'Add',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Progress', style: TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            color: kPrimary,
                            backgroundColor: kPrimary.withOpacity(0.12),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$done / $total done', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.checklist_rtl, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              decoration: const InputDecoration(
                                hintText: 'What needs to be done?',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (v) => _addTodo(v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                    onPressed: () => _addTodo(_inputController.text),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'lib/assets/Not Found.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text('No tasks yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('Add your first task above', style: TextStyle(color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 6),
                      itemCount: _todos.length,
                      itemBuilder: (context, i) {
                        final item = _todos[i];
                        return Dismissible(
                          key: ValueKey(item['title'] + i.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 18),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _remove(i),
                          child: Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: item['done'] as bool,
                                onChanged: (_) => _toggle(i),
                              ),
                              title: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  decoration: (item['done'] as bool)
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _remove(i),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
