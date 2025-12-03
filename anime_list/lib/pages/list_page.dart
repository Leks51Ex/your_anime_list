import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  final Function(String) onSelect;

  ListPage({super.key, required this.onSelect});

  final List<String> oursLists = [
    'Книги',
    'Фильмы',
    'Аниме',
    'Сериалы',
    'Презервативы',
  ];

  IconData _getIcon(String title) {
    switch (title) {
      case 'Книги':
        return Icons.menu_book_rounded;
      case 'Фильмы':
        return Icons.movie_rounded;
      case 'Аниме':
        return Icons.animation_rounded;
      case 'Сериалы':
        return Icons.tv_rounded;
      case 'Презервативы':
        return Icons.favorite_rounded;
      default:
        return Icons.list_rounded;
    }
  }

  Color _getColor(String title) {
    switch (title) {
      case 'Книги':
        return Colors.indigo;
      case 'Фильмы':
        return Colors.redAccent;
      case 'Аниме':
        return Colors.purple;
      case 'Сериалы':
        return Colors.teal;
      case 'Презервативы':
        return Colors.pinkAccent;
      default:
        return Colors.blueGrey;
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
                    onPressed: () {
                      print("Добавить новый список");
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: oursLists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final title = oursLists[index];
                    final color = _getColor(title);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelect(title),
                      child: Card(
                        color: Colors.white.withOpacity(0.7),
                        elevation: 3,
                        shadowColor: color.withOpacity(0.25),
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
                                  color: color.withOpacity(0.12),
                                ),
                                child: Icon(_getIcon(title), color: color),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  title,
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
