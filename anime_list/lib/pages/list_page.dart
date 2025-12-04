import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  final Function(String) onSelect;

  const ListPage({super.key, required this.onSelect});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<_ListItem> oursLists = [
    _ListItem('Книги', Icons.menu_book_rounded, Colors.indigo),
    _ListItem('Фильмы', Icons.movie_rounded, Colors.redAccent),
    _ListItem('Аниме', Icons.animation_rounded, Colors.purple),
    _ListItem('Сериалы', Icons.tv_rounded, Colors.teal),
    _ListItem('Презервативы', Icons.favorite_rounded, Colors.pinkAccent),
    _ListItem('Поездки', Icons.travel_explore, Colors.lightGreen),
  ];

  void _addNewList() async {
    final result = await showDialog<_ListItem>(
      context: context,
      builder: (context) => _AddListDialog(),
    );

    if (result != null) {
      setState(() => oursLists.add(result));
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
                child: ListView.separated(
                  itemCount: oursLists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final item = oursLists[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onSelect(item.title),
                      child: Card(
                        color: Colors.white.withOpacity(0.7),
                        elevation: 3,
                        shadowColor: item.color.withOpacity(0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.color.withOpacity(0.12),
                                ),
                                child: Icon(item.icon, color: item.color),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade500,
                              ),
                            ],
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
      ),
    );
  }
}

class _ListItem {
  final String title;
  final IconData icon;
  final Color color;

  _ListItem(this.title, this.icon, this.color);
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
                _ListItem(_controller.text, _selectedIcon!, _selectedColor!),
              );
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
