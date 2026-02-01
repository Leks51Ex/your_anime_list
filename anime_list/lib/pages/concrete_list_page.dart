import 'package:anime_list/services/api_service.dart';
import 'package:flutter/material.dart';

class ConcreteList extends StatefulWidget {
  final int listId;
  final String text;
  final VoidCallback onBack;

  const ConcreteList({
    super.key,
    required this.listId,
    required this.text,
    required this.onBack,
  });

  @override
  State<ConcreteList> createState() => _ConcreteListState();
}

class _ConcreteListState extends State<ConcreteList> {
  final List<_Item> items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.fetchItems(widget.listId);
      items
        ..clear()
        ..addAll(
          data.map(
            (e) => _Item(
              id: e['id'] as int,
              title: e['title'] as String,
              isChecked: e['isChecked'] as bool? ?? false,
            ),
          ),
        );
    } catch (e) {
      _error = 'Не удалось загрузить пункты списка';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> showEditDialog(
  BuildContext context,
  String initialText,
) {
  final controller = TextEditingController(text: initialText);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Изменить пункт'),
      content: TextField(
        controller: controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            Navigator.pop(context, text.isEmpty ? null : text);
          },
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}


  void _addNewItem() async {
    final result = await showDialog<_NewItemData>(
      context: context,
      builder: (context) => const _AddItemDialog(),
    );

    if (result != null) {
      try {
        final created =
            await ApiService.addItem(widget.listId, result.title);
        if (!mounted) return;
        setState(() {
          items.add(
            _Item(
              id: created['id'] as int,
              title: created['title'] as String,
              isChecked: created['isChecked'] as bool? ?? false,
            ),
          );
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка добавления пункта')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
         decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child:  Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold
                ),),

                    IconButton(
                    icon: const Icon(Icons.add_circle_rounded, size: 50),
                    color: Colors.lightBlue,
                    onPressed: _addNewItem,
                  )
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadItems,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadItems,
                          child: ListView.separated(
                            itemBuilder:
                                (BuildContext context, int index) {
                              final item = items[index];

                              return ListTile(
                                onLongPress: () async {
  final newTitle = await showEditDialog(context, item.title);
  if (newTitle != null && newTitle.isNotEmpty) {
    await ApiService.updateItem(
      widget.listId,
      item.id,
      title: newTitle,
      isChecked: item.isChecked,
    );

    setState(() {
      items[index] = item.copyWith(title: newTitle);
    });
  }
},
                                title: Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.w500),
                                ),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty
                                      .resolveWith<Color>((states) {
                                    if (states.contains(
                                        MaterialState.selected)) {
                                      return Colors.green;
                                    }
                                    return Colors.white;
                                  }),
                                  value: item.isChecked,
                                  onChanged: (bool? value) async {
                                    final newValue = value ?? false;
                                    try {
                                      await ApiService.updateItem(
                                        widget.listId,
                                        item.id,
                                        title: item.title,
                                        isChecked: newValue,
                                      );
                                      if (!mounted) return;
                                      setState(() {
                                        items[index] = item.copyWith(
                                          isChecked: newValue,
                                        );
                                      });
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Ошибка обновления пункта')),
                                      );
                                    }
                                  },
                                ),
                                trailing: IconButton(
                                  color: Colors.redAccent,
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    try {
                                      await ApiService.deleteItem(
                                          widget.listId, item.id);
                                      if (!mounted) return;
                                      setState(() {
                                        items.removeAt(index);
                                      });
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Ошибка удаления пункта')),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemCount: items.length,
                          ),
                        ),
            ),
          ],
                ),
        )),
    );
  }
}


class _Item {
  final int id;
  final String title;
  final bool isChecked;

  _Item({
    required this.id,
    required this.title,
    required this.isChecked,
  });

  _Item copyWith({
    int? id,
    String? title,
    bool? isChecked,
  }) {
    return _Item(
      id: id ?? this.id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class _NewItemData {
  final String title;

  _NewItemData({required this.title});
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({super.key});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(
                context,
                _NewItemData(title: _controller.text),
              );
            }
          },
          child: const Text('Добавить'),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(labelText: 'Добавить новый пункт'),
          ),
        ],
      ),
    );
  }
}
