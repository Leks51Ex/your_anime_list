import 'package:anime_list/services/api_service.dart';
import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  final void Function(int id, String title) onSelect;

  const ListPage({super.key, required this.onSelect});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<_ListItem> oursLists = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.fetchLists();
      oursLists
        ..clear()
        ..addAll(
          data.map(
            (l) => _ListItem(
              id: l['id'] as int,
              title: l['title'] as String,
              icon: Icons.list_rounded,
              color: Colors.indigo,
            ),
          ),
        );
    } catch (e) {
      _error = 'Не удалось загрузить списки';
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
  String initial,
) {
  final controller = TextEditingController(text: initial);

  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Изменить название'),
      content: TextField(controller: controller),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, controller.text.trim());
          },
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}


  void _addNewList() async {
    final result = await showDialog<_NewListData>(
      context: context,
      builder: (context) => _AddListDialog(),
    );

    if (result != null) {
      try {
        final created = await ApiService.createList(result.title);
        setState(() {
          oursLists.add(
            _ListItem(
              id: created['id'] as int,
              title: created['title'] as String,
              icon: result.icon,
              color: result.color,
            ),
          );
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка создания списка')),
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Списочки',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded, size: 50),
                    color: Colors.lightBlue,
                    onPressed: _addNewList,
                  ),
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
                                  onPressed: _loadLists,
                                  child: const Text('Повторить'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadLists,
                            child: ListView.separated(
                              itemCount: oursLists.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (BuildContext context, int index) {
                                final item = oursLists[index];

                                return InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () =>
                                      widget.onSelect(item.id, item.title),
                                  child: Card(
                                    color: Colors.white.withOpacity(0.7),
                                    elevation: 3,
                                    shadowColor:
                                        item.color.withOpacity(0.25),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      height: 80,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: item.color
                                                  .withOpacity(0.12),
                                            ),
                                            child: Icon(item.icon,
                                                color: item.color),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                      'Удалить список?'),
                                                  content: Text(
                                                      '«${item.title}» и все его пункты будут удалены.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, false),
                                                      child:
                                                          const Text('Отмена'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, true),
                                                      child: const Text(
                                                          'Удалить'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await ApiService.deleteList(
                                                      item.id);
                                                  if (!mounted) return;
                                                  setState(() {
                                                    oursLists
                                                        .removeAt(index);
                                                  });
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Ошибка удаления списка')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                          IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () async {
    final newTitle = await showEditDialog(context, item.title);
    if (newTitle != null && newTitle.isNotEmpty) {
      await ApiService.updateListTitle(item.id, newTitle);
      setState(() {
        oursLists[index] = _ListItem(
          id: item.id,
          title: newTitle,
          icon: item.icon,
          color: item.color,
        );
      });
    }
  },
),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListItem {
  final int id;
  final String title;
  final IconData icon;
  final Color color;

  _ListItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _NewListData {
  final String title;
  final IconData icon;
  final Color color;

  _NewListData({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _AddListDialog extends StatefulWidget {
  @override
  State<_AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends State<_AddListDialog> {
  final TextEditingController _controller = TextEditingController();
  IconData? _selectedIcon;
  Color? _selectedColor;

  final List<IconData> icons = [
    Icons.list_rounded,
    Icons.favorite,
    Icons.star,
    Icons.work,
    Icons.home,
    Icons.book,
    Icons.movie,
    Icons.pets,
  ];

  final List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.white,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый список'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 12),
          const Text('Иконка'),
          Wrap(
            children: icons
                .map(
                  (e) => IconButton(
                    icon: Icon(
                      e,
                      color: _selectedIcon == e ? Colors.blueAccent : null,
                    ),
                    onPressed: () => setState(() => _selectedIcon = e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Цвет'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors
                .map(
                  (c) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: _selectedColor == c
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty &&
                _selectedIcon != null &&
                _selectedColor != null) {
              Navigator.pop(
                context,
                _NewListData(
                  title: _controller.text,
                  icon: _selectedIcon!,
                  color: _selectedColor!,
                ),
              );
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
